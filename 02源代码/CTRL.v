`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////


module CTRL(
    input CLK,
    input RESET,
    input BACKSPACE,
    input OK,
    input MANAGER,
    input START,
    input SW0,input SW1,input SW2,input SW3,input SW4,input SW5,input SW6,input SW7,input SW8,input SW9, 
    output [2:0] STATE,
    output reg [9:0] LED,
    output [7:0] AN,
    output [7:0] SEG,
    output RGB1_RED,output RGB1_GREEN,output RGB1_BLUE,
    output RGB2_RED,output RGB2_GREEN,output RGB2_BLUE,
    
    output BUZZER  // 新增蜂鸣器输出
    );
    reg [31:0] Count_CLK;               //实现LED的倒计时显示效果
    reg [31:0] Count_LED;               //实现LED在报警状态下的闪烁效果
    reg [2:0] Current_State;
   //设置7个状态
    parameter WAIT = 3'b000;          //等待状态
    parameter INPUT = 3'b001;         //输入状态
    parameter UNLOCK = 3'b010;        //开锁状态 
    parameter ERROR = 3'b011;         //错误状态
    parameter ALARM = 3'b100;         //报警状态
    parameter ADMIN = 3'b101;         //管理员状态
    parameter COMPARE = 3'b110;       //比较状态
 
    reg [3:0] Code[3:0];                 //存放输入的四位密码
    reg [2:0] Code_Bit;                  //存放输入密码位数

    parameter tens = 1000000000;         //10s倒计时的计数上限
    parameter twentys = 2000000000;      //20s倒计时的计数上限
   
    reg [2:0] Error_Times;               //存放错误的次数
    reg [3:0] Key[3:0];                  //存放正确的密码
    
    reg [31:0] Count_ALARM;          // 用于蜂鸣器5秒计时
    reg buzzer_enable;               // 蜂鸣器使能信号
    
    DISPLAY i_DISPLAY(
    .CLK(CLK),
    .Current_State(Current_State),
    .Error_Times(Error_Times),
    .Code0(Code[0]),.Code1(Code[1]),.Code2(Code[2]),.Code3(Code[3]),
    .AN(AN),
    .SEG(SEG)
    );
    
    RGB i_RGB(
    .CLK(CLK),
    .Current_State(Current_State),
    .RGB1_RED(RGB1_RED),
    .RGB1_GREEN(RGB1_GREEN),
    .RGB1_BLUE(RGB1_BLUE),
    .RGB2_RED(RGB2_RED),
    .RGB2_GREEN(RGB2_GREEN),
    .RGB2_BLUE(RGB2_BLUE)
    );
    
    always @(posedge CLK)
     begin
       if(Current_State == UNLOCK)                      //开锁状态下的倒计时显示
         begin               
           if(Count_CLK > 1800000000) LED <= 10'b1111111111;
           else if(Count_CLK < 1800000000 & Count_CLK > 1600000000) LED <= 10'b0111111111;
           else if(Count_CLK < 1600000000 & Count_CLK > 1400000000) LED <= 10'b0011111111;
           else if(Count_CLK < 1400000000 & Count_CLK > 1200000000) LED <= 10'b0001111111;
           else if(Count_CLK < 1200000000 & Count_CLK > 1000000000) LED <= 10'b0000111111;
           else if(Count_CLK < 1000000000 & Count_CLK > 800000000) LED <= 10'b0000011111;
           else if(Count_CLK < 800000000 & Count_CLK > 600000000) LED <= 10'b0000001111;
           else if(Count_CLK < 600000000 & Count_CLK > 400000000) LED <= 10'b0000000111;
           else if(Count_CLK < 400000000 & Count_CLK > 200000000) LED <= 10'b0000000011;
           else if(Count_CLK < 200000000 & Count_CLK > 0) LED <= 10'b0000000001;
           else LED <= 10'b0000000000;
         end
       else                                          //未开锁状态下的倒计时显示（除报警状态）
         begin            
           if(Count_CLK > 900000000) LED <= 10'b1111111111;
           else if(Count_CLK < 900000000 & Count_CLK > 800000000) LED <= 10'b0111111111;
           else if(Count_CLK < 800000000 & Count_CLK > 700000000) LED <= 10'b0011111111;
           else if(Count_CLK < 700000000 & Count_CLK > 600000000) LED <= 10'b0001111111;
           else if(Count_CLK < 600000000 & Count_CLK > 500000000) LED <= 10'b0000111111;
           else if(Count_CLK < 500000000 & Count_CLK > 400000000) LED <= 10'b0000011111;
           else if(Count_CLK < 400000000 & Count_CLK > 300000000) LED <= 10'b0000001111;
           else if(Count_CLK < 300000000 & Count_CLK > 200000000) LED <= 10'b0000000111;
           else if(Count_CLK < 200000000 & Count_CLK > 100000000) LED <= 10'b0000000011;
           else if(Count_CLK < 100000000 & Count_CLK > 0) LED <= 10'b0000000001;
           else LED <= 10'b0000000000;
         end                     
          
         if(Count_CLK == 0)                        //倒计时清0回到等待状态
         begin
           Current_State <= WAIT;
         end
 
       if(RESET)                                    //重置按钮，密码清0
         begin
           Key[0] <= 0;
           Key[1] <= 0;
           Key[2] <= 0;
           Key[3] <= 0;
           Current_State <= WAIT;
	       Error_Times <= 0;
         end

       if(Current_State == WAIT)                     //等待状态下的操作及状态转换
       begin
         LED <= 10'b0000000000;
         Code[0] <= 10;
         Code[1] <= 10;
         Code[2] <= 10;
         Code[3] <= 10;
         Code_Bit <= 0;
         
         if(MANAGER)                           //按下管理员按键改密码
         begin
           Current_State <= ADMIN;
           Count_CLK <= tens;                 //有操作就给LED计时器重新赋值，重新计数（下同）
         end
         
         if(START)                           //按下开始键开始输入密码
	     begin
	       Current_State <= INPUT;
	       Count_CLK <= tens;
	     end

       end

       if(Current_State == INPUT)           //输入状态下的操作及状态转换
        begin    
          if(MANAGER)                        //修改密码按键
            begin
              Code_Bit <= 0;
              Code[0] <= 10;
              Code[1] <= 10;
              Code[2] <= 10;
              Code[3] <= 10;
              Current_State <= ADMIN;
              Count_CLK <= tens;           
            end
             
            if(SW0)                            //检测到相应的开关拨上，输入密码
               begin
                  Code[Code_Bit] <= 0;          //赋值
                if(Code_Bit <= 3)
                  begin
                    Code_Bit <= Code_Bit + 1;   //指向下一位密码
                    Count_CLK <= tens;
                  end
                else
                  begin
                    Code[Code_Bit] <= 10;         //如果已输满四位，下一位置10（肯定错误的值）
                    Code_Bit <= 4;                //位数置4，便于退格操作
                  end
                end
            
             else if(SW1)
               begin
                 Code[Code_Bit] <= 1;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
                 else
                   begin
                     Code[Code_Bit] <= 10; 
                     Code_Bit <= 4;
                   end
             end          
         
            else if(SW2)
              begin
                Code[Code_Bit] <= 2;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
           
            else if(SW3)
              begin
                Code[Code_Bit] <= 3;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end     
          
            else if(SW4)
              begin
                Code[Code_Bit] <= 4;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end               
          
            else if(SW5)
              begin
                Code[Code_Bit] <= 5;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
        
            else if(SW6)
              begin
                Code[Code_Bit] <= 6;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
          
            else if(SW7)
              begin
                Code[Code_Bit] <= 7;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
         
            else if(SW8)
              begin
                Code[Code_Bit] <= 8;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end              
          
            else if(SW9)
              begin
                Code[Code_Bit] <= 9;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end          
               end 
          
         else if(BACKSPACE)                       //退格按键的相应操作
           begin
             if(Code_Bit == 4)
             begin
               Code_Bit <= 3;                  //退格指向上一位
               Code[3] <= 10;                  //将原本输入的数置10，显示_
               Count_CLK <= tens;
             end
              else if(Code_Bit == 3)
                begin
                  Code_Bit <= 2;
                  Code[2] <= 10;
                  Count_CLK <= tens;
                end
              else if(Code_Bit == 2)
                begin
                  Code_Bit <= 1;
                  Code[1] <= 10;
                  Count_CLK <= tens;
                end
              else if(Code_Bit == 1)
                begin
                  Code_Bit <= 0;
                  Code[0] <= 10;
                  Count_CLK <= tens;
                end 
              else  
                begin
                  Code[0] <= 10;                  //如果已退完，则一直将第一位置10即可
                  Count_CLK <= tens;
                end
              
             end 
             
             else if(OK)                            //按下确认按键，开始进行比较
               begin
                 Current_State <= COMPARE;
                 Count_CLK <= tens;
               end
             else
                 Count_CLK <= Count_CLK - 1;     //倒计时操作
               
            end    
            
            
            
          if(Current_State == ERROR)              //错误状态下的操作及状态转换
            begin
              if(MANAGER)                     //若修改密码
                begin
                  Code_Bit <= 0;
                  Code[0] <= 10;
                  Code[1] <= 10;
                  Code[2] <= 10;
                  Code[3] <= 10;
                  Current_State <= ADMIN;
                  Count_CLK <= tens;
                end
              if(Error_Times == 3)             //错误次数为3，进入报警状态
                begin
                  Current_State <= ALARM;
                end
              else if(START)                  //按下开始，重新输入密码
                begin
                  Code[0] <= 10;
                  Code[1] <= 10;   
                  Code[2] <= 10;
                  Code[3] <= 10;        
                  Code_Bit <= 0;
                  Count_CLK <= tens;
                  Current_State <= INPUT;
                end
              else 
                begin
                  Count_CLK <= Count_CLK - 1;   //倒计时操作
                end
             end           
            
            if(Current_State == COMPARE)         //比较状态下的操作及状态转换
            begin
              if(Code[0] == Key[0] & Code[1] == Key[1] & Code[2] == Key[2] & Code[3] == Key[3])  //输入与正确的密码一致
                begin
                  Count_CLK <= twentys;
                  Current_State <= UNLOCK;
                end
              else 
                begin                     //输入错误，错误次数+1
                  Error_Times <= Error_Times + 1;
                  Current_State <= ERROR;
                end
              end
            
            if(Current_State == UNLOCK)          //开锁状态下的操作及状态转换
              begin 
                Count_CLK <= Count_CLK - 1;
                Error_Times <= 0;
                if(MANAGER)                 //若修改密码
                  begin
                    Code_Bit <= 0;
                    Code[0] <= 10;
                    Code[1] <= 10;
                    Code[2] <= 10;
                    Code[3] <= 10;
                    Current_State <= ADMIN;
                    Count_CLK <= tens;
                  end
                if(OK)                       //按下确认回到等待状态
                  begin
                    Current_State <= WAIT;
                  end
                if(Count_CLK == 0)              //计时归0
                  begin
                    Current_State <= WAIT;
                  end
                end
            
             if(Current_State == ALARM)
             begin
                  buzzer_enable <= 1;
                   Count_ALARM <= 0;
               Count_LED <= 0;                      //LED闪烁效果的实现
               if(Count_LED < 50000000)             //0-500ms LED全亮
                 begin
                   LED <= 10'b1111111111;
                   Count_LED <= Count_LED + 1;
                 end
               else if(Count_LED == 100000000)      //计满1s，清0，循环闪烁
                 Count_LED <= 0;
               else
                 begin                              //500ms-1s LED全灭
                   LED <= 10'b0000000000;     
                   Count_LED <= Count_LED + 1;
                 end      
               // 蜂鸣器控制逻辑
         if(Count_ALARM < 500000000)  // 5秒计时（假设时钟频率为100MHz）
           Count_ALARM <= Count_ALARM + 1;
         else
           buzzer_enable <= 0;        // 5秒后关闭蜂鸣器
           
                 if(MANAGER)                      //按下管理员按键，报警解除
                 begin
                   Error_Times <= 0;
                   Current_State <=  WAIT;
                   buzzer_enable <= 0;      // 立即关闭蜂鸣器
                   Count_ALARM <= 0;        // 重置计时器
                 end
             end 

             
             
                
            if(Current_State == ADMIN)          //管理员状态的操作与状态转换
             begin     
            if(SW0)                              //相应输入操作同INPUT
               begin
                  Code[Code_Bit] <= 0;
                if(Code_Bit <= 3)
                  begin
                    Code_Bit <= Code_Bit + 1;
                    Count_CLK <= tens;
                  end
                else
                  begin
                    Code[Code_Bit] <= 10;
                    Code_Bit <= 4;
                  end
                end
            
             else if(SW1)
               begin
                 Code[Code_Bit] <= 1;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
                 else
                   begin
                     Code[Code_Bit] <= 10; 
                     Code_Bit <= 4;
                   end
             end          
          
            else if(SW2)
              begin
                Code[Code_Bit] <= 2;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
            
            else if(SW3)
              begin
                Code[Code_Bit] <= 3;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end     
          
            else if(SW4)
              begin
                Code[Code_Bit] <= 4;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end               
           
            else if(SW5)
              begin
                Code[Code_Bit] <= 5;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
            
            else if(SW6)
              begin
                Code[Code_Bit] <= 6;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
         
            else if(SW7)
              begin
                Code[Code_Bit] <= 7;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end             
          
            else if(SW8)
              begin
                Code[Code_Bit] <= 8;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end
              end              
         
            else if(SW9)
              begin
                Code[Code_Bit] <= 9;
               if(Code_Bit <= 3)
                 begin
                   Code_Bit <= Code_Bit + 1;
                   Count_CLK <= tens;
                 end
               else
                 begin
                   Code[Code_Bit] <= 10;
                   Code_Bit <= 4;
                 end          
               end                             
                
         else if(BACKSPACE)                       //退格操作也同INPUT状态
           begin
             if(Code_Bit == 4)
             begin
               Code_Bit <= 3;
               Code[3] <= 10;
               Count_CLK <= tens;
             end
              else if(Code_Bit == 3)
                begin
                  Code_Bit <= 2;
                  Code[2] <= 10;
                  Count_CLK <= tens;
                end
              else if(Code_Bit == 2)
                begin
                  Code_Bit <= 1;
                  Code[1] <= 10;
                  Count_CLK <= tens;
                end
              else if(Code_Bit == 1)
                begin
                  Code_Bit <= 0;
                  Code[0] <= 10;
                  Count_CLK <= tens;
                end 
              else  
                begin
                  Code[0] <= 10;
                  Count_CLK <= tens;
                end
             end            
                
           else if(OK)                          //按下确认，将输入的数字置为密码
             begin
               Key[0] <= Code[0];
               Key[1] <= Code[1];
               Key[2] <= Code[2];
               Key[3] <= Code[3];
               Current_State <= WAIT;
             end

           else 
             begin
               Count_CLK <= Count_CLK - 1;
             end           
           end           
              
       end     
       
       assign STATE = Current_State;
       assign BUZZER = ~buzzer_enable;
                   
endmodule