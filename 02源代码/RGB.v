`timescale 1ns / 1ps


module RGB(
    input CLK,
    input [2:0] Current_State,
    output reg RGB1_RED,
    output reg RGB1_GREEN,
    output reg RGB1_BLUE,
    output reg RGB2_RED,
    output reg RGB2_GREEN,
    output reg RGB2_BLUE    
    );
    
    reg [31:0] Count_RGBW;                  //等待状态下的计数器，用于呼吸显示
    reg [31:0] Count_RGBA;                  //报警状态下的计数器，用于闪烁显示
    
    parameter WAIT = 3'b000;
    parameter INPUT = 3'b001;
    parameter UNLOCK = 3'b010;
    parameter ERROR = 3'b011;
    parameter ALARM = 3'b100;
    parameter ADMIN = 3'b101;
    
    always @(posedge CLK)
      begin
        if(Current_State == WAIT)           //等待状态两个均为蓝色
          begin
            Count_RGBW <= 0;
            if(Count_RGBW < 500000000)       //利用计数器实现呼吸显示
              begin
                Count_RGBW <= Count_RGBW + 1;
                RGB1_RED <= 1'b0;
                RGB1_GREEN <= 1'b0;
                RGB1_BLUE <= 1'b1;
                RGB2_RED <= 1'b0;
                RGB2_GREEN <= 1'b0;
                RGB2_BLUE <= 1'b1;   
              end
            else if(Count_RGBW == 800000000)
              Count_RGBW <= 0;
            else 
              begin
                Count_RGBW <= Count_RGBW + 1;
                RGB1_RED <= 1'b0;
                RGB1_GREEN <= 1'b0;
                RGB1_BLUE <= 1'b0;
                RGB2_RED <= 1'b0;
                RGB2_GREEN <= 1'b0;
                RGB2_BLUE <= 1'b0;                 
              end            
          end   
          
        else if(Current_State == INPUT)        //输入状态一个为红色，一个为绿色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;   
          end       
            
        else if(Current_State == UNLOCK)       //开锁状态两个均为绿色
          begin
            RGB1_RED <= 1'b0;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;
          end
          
        else if(Current_State == ERROR)        //错误状态两个均为黄色
          begin
                RGB1_RED <= 1'b1;
                RGB1_GREEN <= 1'b1;
                RGB1_BLUE <= 1'b0;
                RGB2_RED <= 1'b1;
                RGB2_GREEN <= 1'b1;
                RGB2_BLUE <= 1'b0;              
          end
          
        else if(Current_State == ALARM)        //报警状态两个均为红色
          begin
            Count_RGBA <= 0;                    //利用计数器实现闪烁显示
              if(Count_RGBA < 50000000)
                begin
                  Count_RGBA <= Count_RGBA + 1;
                  RGB1_RED <= 1'b1;
                  RGB1_GREEN <= 1'b0;
                  RGB1_BLUE <= 1'b0;
                  RGB2_RED <= 1'b1;
                  RGB2_GREEN <= 1'b0;
                  RGB2_BLUE <= 1'b0; 
                end
              else if(Count_RGBA == 100000000)
                Count_RGBA <= 0;
              else
                begin
                  Count_RGBA <= Count_RGBA + 1;
                  RGB1_RED <= 1'b0;
                  RGB1_GREEN <= 1'b0;
                  RGB1_BLUE <= 1'b0;
                  RGB2_RED <= 1'b0;
                  RGB2_GREEN <= 1'b0;
                  RGB2_BLUE <= 1'b0;       
                end           
          end
          
          
        else if(Current_State == ADMIN)      //管理员状态两个均为白色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b1;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b1;
          end
      end
endmodule
