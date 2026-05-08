`timescale 1ns / 1ps

module BLUETOOTH_INTERFACE(
    input CLK,
    input RESET,
    input RX,
    output TX,
    
    // 输出单脉冲信号
    output reg BACKSPACE_BT,
    output reg OK_BT,
    output reg MANAGER_BT,
    output reg START_BT,
    output reg SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT,
    output reg SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT,
    
    // 状态输入（用于反馈）
    input [2:0] CURRENT_STATE,
    input [2:0] ERROR_TIMES,
    input [9:0] LED_STATUS,
    
    // 调试输出
    output reg [7:0] DEBUG_LAST_DATA,
    output DEBUG_RX_DONE
);

    // UART参数
    parameter BAUD_DIV = 10417;  // 100MHz/9600 ≈ 10417
    
    // 接收状态机
    reg [3:0] rx_state;
    reg [15:0] rx_counter;
    reg [3:0] rx_bit_count;
    reg [7:0] rx_data;
    reg [7:0] rx_data_reg;
    reg rx_done;
    
    // 同步寄存器
    reg rx_sync1, rx_sync2, rx_sync3;
    
    // UART接收状态定义
    parameter RX_IDLE = 4'b0000;
    parameter RX_START = 4'b0001;
    parameter RX_DATA = 4'b0010;
    parameter RX_STOP = 4'b0011;
    
    assign TX = 1'b1;
    assign DEBUG_RX_DONE = rx_done;
    
    // 三级同步
    always @(posedge CLK) begin
        if (RESET) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
            rx_sync3 <= 1'b1;
        end else begin
            rx_sync1 <= RX;
            rx_sync2 <= rx_sync1;
            rx_sync3 <= rx_sync2;
        end
    end
    
    // UART接收逻辑
    always @(posedge CLK) begin
        if (RESET) begin
            rx_state <= RX_IDLE;
            rx_counter <= 0;
            rx_bit_count <= 0;
            rx_data <= 0;
            rx_data_reg <= 0;
            rx_done <= 0;
            DEBUG_LAST_DATA <= 0;
        end else begin
            rx_done <= 0;
            
            case (rx_state)
                RX_IDLE: begin
                    rx_counter <= 0;
                    if (!rx_sync3) begin
                        rx_state <= RX_START;
                        rx_counter <= 0;
                    end
                end
                
                RX_START: begin
                    rx_counter <= rx_counter + 1;
                    if (rx_counter >= (BAUD_DIV/2)) begin
                        if (!rx_sync3) begin
                            rx_state <= RX_DATA;
                            rx_counter <= 0;
                            rx_bit_count <= 0;
                            rx_data <= 8'h00;
                        end else begin
                            rx_state <= RX_IDLE;
                        end
                    end
                end
                
                RX_DATA: begin
                    rx_counter <= rx_counter + 1;
                    if (rx_counter >= BAUD_DIV) begin
                        rx_counter <= 0;
                        if (rx_bit_count >= 7) begin
                            rx_state <= RX_STOP;
                        end else begin
                            rx_bit_count <= rx_bit_count + 1;
                        end
                    end else if (rx_counter == (BAUD_DIV/2)) begin
                        rx_data[rx_bit_count] <= rx_sync3;
                    end
                end
                
                RX_STOP: begin
                    rx_counter <= rx_counter + 1;
                    if (rx_counter == (BAUD_DIV/2)) begin
                        if (rx_sync3) begin
                            rx_data_reg <= rx_data;
                            DEBUG_LAST_DATA <= rx_data;
                            rx_done <= 1;  // 单周期脉冲
                        end
                    end
                    
                    if (rx_counter >= BAUD_DIV) begin
                        rx_state <= RX_IDLE;
                        rx_counter <= 0;
                    end
                end
                
                default: rx_state <= RX_IDLE;
            endcase
        end
    end
    
    // 单脉冲生成 - 关键改进
    always @(posedge CLK) begin
        if (RESET) begin
            {BACKSPACE_BT, OK_BT, MANAGER_BT, START_BT} <= 4'b0;
            {SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT} <= 5'b0;
            {SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT} <= 5'b0;
        end else begin
            // 默认清零所有输出（确保只有单周期脉冲）
            {BACKSPACE_BT, OK_BT, MANAGER_BT, START_BT} <= 4'b0;
            {SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT} <= 5'b0;
            {SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT} <= 5'b0;
            
            // 只在接收完成的那一个时钟周期输出脉冲
            if (rx_done) begin
                case (rx_data_reg)
                    8'h53, 8'h73: START_BT <= 1;      // 'S' or 's' - 单周期脉冲
                    8'h4F, 8'h6F: OK_BT <= 1;         // 'O' or 'o'
                    8'h4D, 8'h6D: MANAGER_BT <= 1;    // 'M' or 'm'
                    8'h42, 8'h62: BACKSPACE_BT <= 1;  // 'B' or 'b'
                    8'h30: SW0_BT <= 1;        // '0'
                    8'h31: SW1_BT <= 1;        // '1'
                    8'h32: SW2_BT <= 1;        // '2'
                    8'h33: SW3_BT <= 1;        // '3'
                    8'h34: SW4_BT <= 1;        // '4'
                    8'h35: SW5_BT <= 1;        // '5'
                    8'h36: SW6_BT <= 1;        // '6'
                    8'h37: SW7_BT <= 1;        // '7'
                    8'h38: SW8_BT <= 1;        // '8'
                    8'h39: SW9_BT <= 1;        // '9'
                    default: begin
                        // 无效命令，保持清零状态
                    end
                endcase
            end
        end
    end
    
endmodule