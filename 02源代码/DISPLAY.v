`timescale 1ns / 1ps


module DISPLAY(
    input CLK,
    input [2:0] Current_State,             //当前状态
    input [2:0] Error_Times,               //错误次数
    input [3:0] Code0,input [3:0] Code1,input [3:0] Code2,input [3:0] Code3,   //输入的密码
    output reg [7:0] AN,            //数码管位选
    output reg [7:0] SEG            //数码管段选
    );
     reg [2:0] num4 = 3'd0;        //两个num用于扫描
     reg [2:0] num5 = 3'd0;
     reg [3:0] Disp = 4'h0;        //要显示的具体内容
    
     parameter WAIT = 3'b000;
     parameter INPUT = 3'b001;
     parameter UNLOCK = 3'b010;
     parameter ERROR = 3'b011;
     parameter ALARM = 3'b100;
     parameter ADMIN = 3'b101;
     
    reg[31:0] count_num = 32'd0;     //用于分频
    always @(posedge CLK)
      begin 
        if(count_num == 32'd99999)       //1ms为周期
          begin
            count_num <= 32'd0;
          end
        else
          begin
            count_num <= count_num + 1;
          end
      end
        
        always @(posedge CLK)
          begin
            if(count_num == 32'd99999)         //以1ms为周期扫描
              begin
                if(num4 == 3'd3)              //num4用于四位的显示
                  begin
                    num4 <= 3'd0;
                  end
                else begin
                  num4 <= num4 + 1'd1;
                end
              end
            end        
        always @(posedge CLK)
          begin
            if(count_num == 32'd99999)
              begin
                if(num5 == 3'd4)           //num5用于5位的显示
                  begin
                    num5 <= 3'd0;
                  end
                else begin
                  num5 <= num5 + 1'd1;
                end
              end
            end   
                      
     
     always @(posedge CLK)
       begin
         if(Current_State == WAIT)         //等待状态下的显示
           begin
           case(num4)
             0:begin
                 AN <= 8'b01111111;
                 Disp <= 4'ha;              //a表示显示_
               end
             1:begin
                 AN <= 8'b10111111;
                 Disp <= 4'ha;
               end
             2:begin
                 AN <= 8'b11011111;
                 Disp <= 4'ha;
               end 
             3:begin
                 AN <= 8'b11101111;
                 Disp <= 4'ha;
               end                       
             endcase
           end
         else if(Current_State == INPUT)                  //输入状态下的显示
           begin
           case(num5)
             0:begin
                 AN <= 8'b01111111;
                 Disp <= Code0;
               end
             1:begin
                 AN <= 8'b10111111;
                 Disp <= Code1;
               end
             2:begin
                 AN <= 8'b11011111;
                 Disp <= Code2;
               end 
             3:begin
                 AN <= 8'b11101111;
                 Disp <= Code3;
               end    
             4:begin
                 AN <= 8'b11111110;
                 Disp <= Error_Times;           //最右侧一位显示错误次数
               end                
             endcase
           end
         
         else if(Current_State == UNLOCK)       //开锁状态下的显示
           begin
             case(num5)
               0:begin
                 AN <= 8'b01111111;
                 Disp <= 4'hb;                    //b表示显示H
               end            
               1:begin
                 AN <= 8'b10111111;
                 Disp <= 4'hc;                    //c表示显示E
               end
             2:begin
                 AN <= 8'b11011111;
                 Disp <= 4'hd;                    //d表示显示L
               end 
             3:begin
                 AN <= 8'b11101111;
                 Disp <= 4'hd; 
               end     
             4:begin
                 AN <= 8'b11110111;
                 Disp <= 4'h0; 
               end                  
             endcase
           end
           
           else if(Current_State == ERROR)    //错误状态下的显示
             begin
             case(num5)
               0:begin
                 AN <= 8'b01111111;        
                  Disp <= 4'hc;             //c表示显示E
               end            
               1:begin
                 AN <= 8'b10111111;
                  Disp <= 4'he;              //e表示显示R
               end
             2:begin
                 AN <= 8'b11011111;
                  Disp <= 4'he; 
               end 
             3:begin
                 AN <= 8'b11101111;
                  Disp <= 4'h0; 
               end     
             4:begin
                 AN <= 8'b11110111;
                  Disp <= 4'he; 
               end                  
             endcase
           end
               
           else if(Current_State == ALARM)     //报警状态下的显示
             begin
             case(num4)
               0:begin
                 AN <= 8'b01111111;
                 Disp <= 4'hc;             //c表示显示e
               end            
               1:begin
                 AN <= 8'b10111111;
                 Disp <= 4'hc; 
               end
              2:begin
                 AN <= 8'b11011111;
                 Disp <= 4'hc; 
               end 
              3:begin
                 AN <= 8'b11101111;
                 Disp <= 4'hc; 
               end                      
             endcase
           end
         
           else if(Current_State == ADMIN)          //管理员状态下的显示    
             begin
               case(num4)
                 0:begin
                     AN <= 8'b01111111;
                     Disp <= Code0;
                   end
                1:begin
                    AN <= 8'b10111111;
                    Disp <= Code1;
                  end
                2:begin
                    AN <= 8'b11011111;
                    Disp <= Code2;
                  end 
                3:begin
                    AN <= 8'b11101111;
                    Disp <= Code3;
                  end                    
               endcase
           end
       end
       
      always @(posedge CLK)
        begin
          case(Disp)
            4'h0: SEG <= 8'b00000011;         //0表示显示0
            4'h1: SEG <= 8'b10011111;         //1表示显示1
            4'h2: SEG <= 8'b00100101;         //2表示显示2
            4'h3: SEG <= 8'b00001101;         //3表示显示3
            4'h4: SEG <= 8'b10011001;         //4表示显示4
            4'h5: SEG <= 8'b01001001;         //5表示显示5
            4'h6: SEG <= 8'b01000001;         //6表示显示6
            4'h7: SEG <= 8'b00011111;         //7表示显示7
            4'h8: SEG <= 8'b00000001;         //8表示显示8
            4'h9: SEG <= 8'b00001001;         //9表示显示9
            4'ha: SEG <= 8'b11101111;         //a表示显示_
            4'hb: SEG <= 8'b10010001;         //b表示显示H
            4'hc: SEG <= 8'b01100001;         //c表示显示E
            4'hd: SEG <= 8'b11100011;         //d表示显示L
            4'he: SEG <= 8'b00010001;         //e表示显示R
            default: SEG <= 8'b11111111;      //其他不显示
          endcase
        end
             
endmodule

