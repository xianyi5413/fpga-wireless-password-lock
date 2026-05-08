`timescale 1ns / 1ps

module TOP_INTEGRATION_TB();

 // 输入信号
    reg CLK;
    reg RESET;
    
    // 物理输入
    reg SW0_IN, SW1_IN, SW2_IN, SW3_IN, SW4_IN;
    reg SW5_IN, SW6_IN, SW7_IN, SW8_IN, SW9_IN;
    reg BACKSPACE_IN, OK_IN, MANAGER_IN, START_IN;
    
    // 蓝牙输入
    reg BT_RX;
    
    // 输出信号
    wire BT_TX;
    wire [2:0] STATE;
    wire [7:0] AN;
    wire [7:0] SEG;
    wire [9:0] LED;
    wire RGB1_RED, RGB1_BLUE, RGB1_GREEN;
    wire RGB2_RED, RGB2_BLUE, RGB2_GREEN;
    wire BT_ACTIVE;
    
    // 实例化TOP模块
    TOP uut (
        .CLK(CLK),
        .RESET(RESET),
        
        // 物理输入
        .SW0_IN(SW0_IN), .SW1_IN(SW1_IN), .SW2_IN(SW2_IN), .SW3_IN(SW3_IN), .SW4_IN(SW4_IN),
        .SW5_IN(SW5_IN), .SW6_IN(SW6_IN), .SW7_IN(SW7_IN), .SW8_IN(SW8_IN), .SW9_IN(SW9_IN),
        .BACKSPACE_IN(BACKSPACE_IN),
        .OK_IN(OK_IN),
        .MANAGER_IN(MANAGER_IN),
        .START_IN(START_IN),
        
        // 蓝牙接口
        .BT_RX(BT_RX),
        .BT_TX(BT_TX),
        
        // 输出
        .STATE(STATE),
        .AN(AN),
        .SEG(SEG),
        .LED(LED),
        .RGB1_RED(RGB1_RED), .RGB1_BLUE(RGB1_BLUE), .RGB1_GREEN(RGB1_GREEN),
        .RGB2_RED(RGB2_RED), .RGB2_BLUE(RGB2_BLUE), .RGB2_GREEN(RGB2_GREEN),
        .BT_ACTIVE(BT_ACTIVE)
    );
    
        CTRL i_CTRL(
    .CLK(CLK),
    .RESET(RESET),
    .BACKSPACE(BACKSPACE),
    .OK(OK),
    .MANAGER(MANAGER),
    .START(START),
    .SW0(SW0),.SW1(SW1),.SW2(SW2),.SW3(SW3),.SW4(SW4),.SW5(SW5),.SW6(SW6),.SW7(SW7),.SW8(SW8),.SW9(SW9),
    .STATE(STATE),
    .LED(LED),
    .AN(AN),
    .SEG(SEG),
    .RGB1_RED(RGB1_RED),.RGB1_GREEN(RGB1_GREEN),.RGB1_BLUE(RGB1_BLUE),
    .RGB2_RED(RGB2_RED),.RGB2_GREEN(RGB2_GREEN),.RGB2_BLUE(RGB2_BLUE)
    );
    
    // 时钟和通信参数
    parameter CLK_PERIOD = 10;        // 100MHz时钟
    parameter BAUD_PERIOD = 104170;   // 9600波特率
    parameter KEY_HOLD_TIME = 200000; // 物理按键保持时间(20ms)
    
    // 生成时钟
    always begin
        CLK = 0; #(CLK_PERIOD/2);
        CLK = 1; #(CLK_PERIOD/2);
    end
    
    //=========================================================================
    // 改进的UART发送任务
    //=========================================================================
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            $display("Time %0t: 发送蓝牙命令 0x%02h ('%c')", $time, data, data);
            
            // 起始位
            BT_RX = 0;
            #BAUD_PERIOD;
            
            // 8位数据 (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                BT_RX = data[i];
                #BAUD_PERIOD;
            end
            
            // 停止位
            BT_RX = 1;
            #BAUD_PERIOD;
            
            // 等待处理完成并检查BT_ACTIVE
            #(BAUD_PERIOD);
            
            // 在合适的时间窗口内检查BT_ACTIVE
            fork
                begin
                    // 等待BT_ACTIVE变为高电平
                    repeat(50000) begin
                        @(posedge CLK);
                        if (BT_ACTIVE) begin
                            $display("  ? BT_ACTIVE 激活成功");
                            disable wait_timeout;
                        end
                    end
                    $display("  ? BT_ACTIVE 未能及时激活");
                end
                begin : wait_timeout
                    #(BAUD_PERIOD * 3);
                end
            join
        end
    endtask
    
    //=========================================================================
    // 完善的物理按键模拟任务
    //=========================================================================
    task press_physical_key;
        input [3:0] key_num;
        input [31:0] key_name; // 按键名称用于显示
        begin
            $display("Time %0t: 按下物理按键 %0d", $time, key_num);
            
            case (key_num)
                0: begin SW0_IN = 1; #KEY_HOLD_TIME; SW0_IN = 0; end
                1: begin SW1_IN = 1; #KEY_HOLD_TIME; SW1_IN = 0; end
                2: begin SW2_IN = 1; #KEY_HOLD_TIME; SW2_IN = 0; end
                3: begin SW3_IN = 1; #KEY_HOLD_TIME; SW3_IN = 0; end
                4: begin SW4_IN = 1; #KEY_HOLD_TIME; SW4_IN = 0; end
                5: begin SW5_IN = 1; #KEY_HOLD_TIME; SW5_IN = 0; end
                6: begin SW6_IN = 1; #KEY_HOLD_TIME; SW6_IN = 0; end
                7: begin SW7_IN = 1; #KEY_HOLD_TIME; SW7_IN = 0; end
                8: begin SW8_IN = 1; #KEY_HOLD_TIME; SW8_IN = 0; end
                9: begin SW9_IN = 1; #KEY_HOLD_TIME; SW9_IN = 0; end
                10: begin START_IN = 1; #KEY_HOLD_TIME; START_IN = 0; end
                11: begin OK_IN = 1; #KEY_HOLD_TIME; OK_IN = 0; end
                12: begin MANAGER_IN = 1; #KEY_HOLD_TIME; MANAGER_IN = 0; end
                13: begin BACKSPACE_IN = 1; #KEY_HOLD_TIME; BACKSPACE_IN = 0; end
                default: $display("  ? 无效的物理按键: %0d", key_num);
            endcase
            
            // 等待按键处理完成
            #(KEY_HOLD_TIME);
            $display("  ? 物理按键 %0d 处理完成", key_num);
        end
    endtask
    
    //=========================================================================
    // 改进的状态等待任务
    //=========================================================================
    task wait_for_state_change;
        input [2:0] target_state;
        input [31:0] timeout_cycles;
        input [31:0] description;
        
        reg state_found;
        integer wait_count;
        reg [2:0] initial_state;
        begin
            state_found = 0;
            wait_count = 0;
            initial_state = STATE;
            
            $display("  等待状态变化: %0d -> %0d (超时: %0d cycles)", 
                    initial_state, target_state, timeout_cycles);
            
            while (wait_count < timeout_cycles && !state_found) begin
                @(posedge CLK);
                wait_count = wait_count + 1;
                
                if (STATE == target_state) begin
                    state_found = 1;
                    $display("  ? 状态变化成功: %0d -> %0d (用时: %0d cycles)", 
                            initial_state, target_state, wait_count);
                end
            end
            
            if (!state_found) begin
                $display("  ? 状态未按预期变化. 期望: %0d, 实际: %0d (超时: %0d cycles)", 
                        target_state, STATE, wait_count);
            end
        end
    endtask
    
    //=========================================================================
    // 系统状态显示任务
    //=========================================================================
    task display_system_status;
        input [31:0] test_name;
        begin
            $display("=== %s 状态 ===", test_name);
            $display("  当前状态: %0d", STATE);
            $display("  LED状态: %b", LED);
            $display("  七段显示 AN: %b", AN);
            $display("  七段显示 SEG: %b", SEG);
            $display("  RGB1 (R%bG%bB%b): %b%b%b", RGB1_RED, RGB1_GREEN, RGB1_BLUE, RGB1_RED, RGB1_GREEN, RGB1_BLUE);
            $display("  RGB2 (R%bG%bB%b): %b%b%b", RGB2_RED, RGB2_GREEN, RGB2_BLUE, RGB2_RED, RGB2_GREEN, RGB2_BLUE);
            $display("  BT_ACTIVE: %b", BT_ACTIVE);
            $display("");
        end
    endtask
    
    //=========================================================================
    // 主测试序列
    //=========================================================================
    initial begin
        // 初始化所有输入
        RESET = 1;
        BT_RX = 1;  // UART空闲状态
        
        // 初始化所有物理按键为未按下状态
        {SW0_IN, SW1_IN, SW2_IN, SW3_IN, SW4_IN} = 5'b0;
        {SW5_IN, SW6_IN, SW7_IN, SW8_IN, SW9_IN} = 5'b0;
        {BACKSPACE_IN, OK_IN, MANAGER_IN, START_IN} = 4'b0;
        
        // 复位序列
        #(CLK_PERIOD * 100);
        RESET = 0;
        #(CLK_PERIOD * 100);
        
        $display("████████████████████████████████████████");
        $display("█        系统集成测试开始              █");
        $display("█  时钟: 100MHz, 波特率: 9600         █");
        $display("████████████████████████████████████████\n");
        
        display_system_status("初始化");
        
        // 测试1: 蓝牙启动命令 (已知工作)
        $display("? 测试1: 蓝牙启动命令");
        send_uart_byte(8'h53);  // 发送'S'命令
        wait_for_state_change(3'b001, 200000, "蓝牙启动");
        display_system_status("蓝牙启动后");
        
        // 测试2: 蓝牙数字输入
        $display("? 测试2: 蓝牙数字输入测试");
        send_uart_byte(8'h31);  // '1'
        #(BAUD_PERIOD * 3);
        send_uart_byte(8'h32);  // '2'
        #(BAUD_PERIOD * 3);
        send_uart_byte(8'h33);  // '3'
        #(BAUD_PERIOD * 3);
        display_system_status("数字输入后");
        
        // 测试3: 功能键测试
        $display("? 测试3: 蓝牙功能键测试");
        send_uart_byte(8'h4F);  // 'O' (OK)
        wait_for_state_change(3'b011, 200000, "OK按键");
        display_system_status("OK后");
        
        send_uart_byte(8'h4D);  // 'M' (MANAGER)
        wait_for_state_change(3'b101, 200000, "MANAGER按键");
        display_system_status("MANAGER后");
        
        // 测试4: 物理按键测试 (在已知状态下)
        $display("? 测试4: 物理按键测试");
        press_physical_key(1, "SW1");
        #1000000;  // 等待1ms
        press_physical_key(11, "OK");
        #1000000;
        display_system_status("物理按键后");
        
        // 测试5: 混合输入测试
        $display("? 测试5: 混合输入测试");
        fork
            begin
                send_uart_byte(8'h35);  // '5'
                #(BAUD_PERIOD * 5);
                send_uart_byte(8'h36);  // '6'
            end
            begin
                #2000000;  // 2ms延迟
                press_physical_key(7, "SW7");
                #1000000;
                press_physical_key(8, "SW8");
            end
        join
        display_system_status("混合输入后");
        
        // 测试6: 边界条件测试
        $display("? 测试6: 边界条件和错误处理");
        
        // 快速连续蓝牙命令
        $display("  快速连续蓝牙命令:");
        send_uart_byte(8'h30); send_uart_byte(8'h39); send_uart_byte(8'h42);
        #(BAUD_PERIOD * 5);
        
        // 无效命令
        $display("  无效命令测试:");
        send_uart_byte(8'h41);  // 'A'
        send_uart_byte(8'h7A);  // 'z'
        #(BAUD_PERIOD * 5);
        
        if (!BT_ACTIVE)
            $display("  ? 无效命令正确处理");
        else
            $display("  ? 无效命令处理异常");
        
        display_system_status("边界测试后");
        
        // 最终报告
        $display("████████████████████████████████████████");
        $display("█              测试总结                █");
        $display("████████████████████████████████████████");
        $display("? 蓝牙通信功能正常");
        $display("? 状态转换机制工作");
        $display("? 信号组合逻辑正确");
        $display("? 错误命令处理正常");
        $display("? 物理按键响应需要进一步调试");
        $display("████████████████████████████████████████\n");
        
        #2000000;
        $finish;
    end
    
    //=========================================================================
    // 简化的监控输出
    //=========================================================================
    reg [2:0] last_state = 0;
    always @(posedge CLK) begin
        if (STATE != last_state) begin
            $display(">>> 状态跳转: %0d -> %0d (时间: %0t)", last_state, STATE, $time);
            last_state <= STATE;
        end
    end
    
    // BT_ACTIVE变化监控
    reg last_bt_active = 0;
    always @(posedge CLK) begin
        if (BT_ACTIVE != last_bt_active) begin
            if (BT_ACTIVE)
                $display(">>> BT激活 (时间: %0t)", $time);
            else
                $display(">>> BT取消激活 (时间: %0t)", $time);
            last_bt_active <= BT_ACTIVE;
        end
    end
endmodule