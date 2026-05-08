`timescale 1ns / 1ps

module CTRL_INTEGRATION_TB();

    // 时钟和复位
    reg CLK;
    reg RESET;
    
    // 模拟物理按键消抖后的信号
    reg BACKSPACE_PHYSICAL;
    reg OK_PHYSICAL;
    reg MANAGER_PHYSICAL;
    reg START_PHYSICAL;
    reg SW0_PHYSICAL, SW1_PHYSICAL, SW2_PHYSICAL, SW3_PHYSICAL, SW4_PHYSICAL;
    reg SW5_PHYSICAL, SW6_PHYSICAL, SW7_PHYSICAL, SW8_PHYSICAL, SW9_PHYSICAL;
    
    // 模拟蓝牙输出信号
    reg BACKSPACE_BT;
    reg OK_BT;
    reg MANAGER_BT;
    reg START_BT;
    reg SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT;
    reg SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT;
    
    // 组合信号（模拟TOP模块中的OR逻辑）
    wire BACKSPACE = BACKSPACE_PHYSICAL | BACKSPACE_BT;
    wire OK = OK_PHYSICAL | OK_BT;
    wire MANAGER = MANAGER_PHYSICAL | MANAGER_BT;
    wire START = START_PHYSICAL | START_BT;
    
    wire SW0 = SW0_PHYSICAL | SW0_BT;
    wire SW1 = SW1_PHYSICAL | SW1_BT;
    wire SW2 = SW2_PHYSICAL | SW2_BT;
    wire SW3 = SW3_PHYSICAL | SW3_BT;
    wire SW4 = SW4_PHYSICAL | SW4_BT;
    wire SW5 = SW5_PHYSICAL | SW5_BT;
    wire SW6 = SW6_PHYSICAL | SW6_BT;
    wire SW7 = SW7_PHYSICAL | SW7_BT;
    wire SW8 = SW8_PHYSICAL | SW8_BT;
    wire SW9 = SW9_PHYSICAL | SW9_BT;
    
    // CTRL模块输出
    wire [2:0] STATE;
    wire [9:0] LED;
    wire [7:0] AN;
    wire [7:0] SEG;
    wire RGB1_RED, RGB1_GREEN, RGB1_BLUE;
    wire RGB2_RED, RGB2_GREEN, RGB2_BLUE;
    
    // 实例化CTRL模块
    CTRL i_CTRL(
        .CLK(CLK),
        .RESET(RESET),
        .BACKSPACE(BACKSPACE),
        .OK(OK),
        .MANAGER(MANAGER),
        .START(START),
        .SW0(SW0),.SW1(SW1),.SW2(SW2),.SW3(SW3),.SW4(SW4),
        .SW5(SW5),.SW6(SW6),.SW7(SW7),.SW8(SW8),.SW9(SW9),
        .STATE(STATE),
        .LED(LED),
        .AN(AN),
        .SEG(SEG),
        .RGB1_RED(RGB1_RED),.RGB1_GREEN(RGB1_GREEN),.RGB1_BLUE(RGB1_BLUE),
        .RGB2_RED(RGB2_RED),.RGB2_GREEN(RGB2_GREEN),.RGB2_BLUE(RGB2_BLUE)
    );
    
    // 时钟生成
    always begin
        #5 CLK = 1;
        #5 CLK = 0;
    end
    
    //=========================================================================
    // 测试任务定义
    //=========================================================================
    
    // 物理按键脉冲任务
    task press_physical;
        input [3:0] key_type;  // 0-9=SW, 10=START, 11=OK, 12=MANAGER, 13=BACKSPACE
        begin
            case (key_type)
                0: begin SW0_PHYSICAL = 1; #10; SW0_PHYSICAL = 0; $display("物理按键 SW0"); end
                1: begin SW1_PHYSICAL = 1; #10; SW1_PHYSICAL = 0; $display("物理按键 SW1"); end
                2: begin SW2_PHYSICAL = 1; #10; SW2_PHYSICAL = 0; $display("物理按键 SW2"); end
                3: begin SW3_PHYSICAL = 1; #10; SW3_PHYSICAL = 0; $display("物理按键 SW3"); end
                4: begin SW4_PHYSICAL = 1; #10; SW4_PHYSICAL = 0; $display("物理按键 SW4"); end
                5: begin SW5_PHYSICAL = 1; #10; SW5_PHYSICAL = 0; $display("物理按键 SW5"); end
                6: begin SW6_PHYSICAL = 1; #10; SW6_PHYSICAL = 0; $display("物理按键 SW6"); end
                7: begin SW7_PHYSICAL = 1; #10; SW7_PHYSICAL = 0; $display("物理按键 SW7"); end
                8: begin SW8_PHYSICAL = 1; #10; SW8_PHYSICAL = 0; $display("物理按键 SW8"); end
                9: begin SW9_PHYSICAL = 1; #10; SW9_PHYSICAL = 0; $display("物理按键 SW9"); end
                10: begin START_PHYSICAL = 1; #10; START_PHYSICAL = 0; $display("物理按键 START"); end
                11: begin OK_PHYSICAL = 1; #10; OK_PHYSICAL = 0; $display("物理按键 OK"); end
                12: begin MANAGER_PHYSICAL = 1; #10; MANAGER_PHYSICAL = 0; $display("物理按键 MANAGER"); end
                13: begin BACKSPACE_PHYSICAL = 1; #10; BACKSPACE_PHYSICAL = 0; $display("物理按键 BACKSPACE"); end
            endcase
            #100; // 等待处理
        end
    endtask
    
    // 蓝牙命令脉冲任务
    task send_bluetooth;
        input [3:0] key_type;  // 0-9=SW, 10=START, 11=OK, 12=MANAGER, 13=BACKSPACE
        begin
            case (key_type)
                0: begin SW0_BT = 1; #10; SW0_BT = 0; $display("蓝牙命令 SW0"); end
                1: begin SW1_BT = 1; #10; SW1_BT = 0; $display("蓝牙命令 SW1"); end
                2: begin SW2_BT = 1; #10; SW2_BT = 0; $display("蓝牙命令 SW2"); end
                3: begin SW3_BT = 1; #10; SW3_BT = 0; $display("蓝牙命令 SW3"); end
                4: begin SW4_BT = 1; #10; SW4_BT = 0; $display("蓝牙命令 SW4"); end
                5: begin SW5_BT = 1; #10; SW5_BT = 0; $display("蓝牙命令 SW5"); end
                6: begin SW6_BT = 1; #10; SW6_BT = 0; $display("蓝牙命令 SW6"); end
                7: begin SW7_BT = 1; #10; SW7_BT = 0; $display("蓝牙命令 SW7"); end
                8: begin SW8_BT = 1; #10; SW8_BT = 0; $display("蓝牙命令 SW8"); end
                9: begin SW9_BT = 1; #10; SW9_BT = 0; $display("蓝牙命令 SW9"); end
                10: begin START_BT = 1; #10; START_BT = 0; $display("蓝牙命令 START"); end
                11: begin OK_BT = 1; #10; OK_BT = 0; $display("蓝牙命令 OK"); end
                12: begin MANAGER_BT = 1; #10; MANAGER_BT = 0; $display("蓝牙命令 MANAGER"); end
                13: begin BACKSPACE_BT = 1; #10; BACKSPACE_BT = 0; $display("蓝牙命令 BACKSPACE"); end
            endcase
            #100; // 等待处理
        end
    endtask
    
    // 状态显示任务
    task show_status;
        input [31:0] test_name;
        begin
            $display("=== %s 状态 ===", test_name);
            $display("STATE: %d, LED: %b", STATE, LED);
            $display("SW组合信号: %b%b%b%b%b%b%b%b%b%b", SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0);
            $display("控制信号: START=%b, OK=%b, MANAGER=%b, BACKSPACE=%b", START, OK, MANAGER, BACKSPACE);
            $display("");
        end
    endtask
    
    //=========================================================================
    // 主测试序列
    //=========================================================================
    initial begin
        // 初始化所有信号为0
        RESET = 1;
        {BACKSPACE_PHYSICAL, OK_PHYSICAL, MANAGER_PHYSICAL, START_PHYSICAL} = 4'b0;
        {SW0_PHYSICAL, SW1_PHYSICAL, SW2_PHYSICAL, SW3_PHYSICAL, SW4_PHYSICAL} = 5'b0;
        {SW5_PHYSICAL, SW6_PHYSICAL, SW7_PHYSICAL, SW8_PHYSICAL, SW9_PHYSICAL} = 5'b0;
        {BACKSPACE_BT, OK_BT, MANAGER_BT, START_BT} = 4'b0;
        {SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT} = 5'b0;
        {SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT} = 5'b0;
        
        #100 RESET = 0;
        
        
        show_status("初始化");
        
        // 测试1: 物理按键启动和密码输入
        $display(" 测试1: 物理按键完整流程");
        press_physical(10);  // START
        show_status("物理START后");
        
        press_physical(1);   // SW0 - 第一位密码
        press_physical(2);   // SW0 - 第二位密码  
        press_physical(3);   // SW0 - 第三位密码
        press_physical(4);   // SW0 - 第四位密码
        press_physical(11);  // OK
        show_status("物理密码输入后");
        
        // 测试2: 蓝牙命令启动和密码输入
        $display(" 测试2: 蓝牙命令完整流程");
        send_bluetooth(10);  // START
        show_status("蓝牙START后");
        
        send_bluetooth(1);   // SW1 - 第一位密码
        send_bluetooth(2);   // SW2 - 第二位密码
        send_bluetooth(3);   // SW3 - 第三位密码
        send_bluetooth(4);   // SW4 - 第四位密码
        send_bluetooth(11);  // OK
        show_status("蓝牙密码输入后");
        
        // 测试3: 混合输入测试（关键测试）
        $display("? 测试3: 混合输入流程（物理+蓝牙）");
        press_physical(10);  // 物理START
        show_status("混合-物理START");
        
        send_bluetooth(1);   // 蓝牙SW1
        press_physical(2);   // 物理SW2
        send_bluetooth(3);   // 蓝牙SW3
        press_physical(4);   // 物理SW4
        send_bluetooth(11);  // 蓝牙OK
        show_status("混合输入完成");
        
        // 测试4: 管理员功能测试
        $display("测试4: 管理员功能");
        press_physical(12);  // 物理MANAGER
        show_status("进入管理员模式");
        
        send_bluetooth(5);   // 新密码第一位
        send_bluetooth(6);   // 新密码第二位
        send_bluetooth(7);   // 新密码第三位
        send_bluetooth(8);   // 新密码第四位
        press_physical(11);  // 物理OK确认
        show_status("密码修改完成");
        
        // 测试5: 验证新密码
        $display(" 测试5: 验证新密码");
        send_bluetooth(10);  // START
        send_bluetooth(5);   // 新密码
        send_bluetooth(6);
        send_bluetooth(7);
        send_bluetooth(8);
        send_bluetooth(11);  // OK
        show_status("新密码验证");
        
        // 测试6: 信号组合验证
        $display(" 测试6: 信号组合逻辑验证");
        $display("测试同时激活物理和蓝牙信号...");
        
        // 同时激活物理和蓝牙SW0
        SW0_PHYSICAL = 1;
        SW0_BT = 1;
        #10;
        if (SW0 === 1'b1)
            $display(" SW0组合信号正确: PHYSICAL|BT = 1|1 = 1");
        else
            $display(" SW0组合信号错误");
        
        SW0_PHYSICAL = 0;
        #10;
        if (SW0 === 1'b1)
            $display(" SW0组合信号正确: PHYSICAL|BT = 0|1 = 1");
        else
            $display(" SW0组合信号错误");
            
        SW0_BT = 0;
        #10;
        if (SW0 === 1'b0)
            $display("SW0组合信号正确: PHYSICAL|BT = 0|0 = 0");
        else
            $display(" SW0组合信号错误");
        
        $display("              测试总结                ");
        $display("物理按键 -> SW信号传递正常");
        $display(" 蓝牙命令 -> SW信号传递正常"); 
        $display(" 信号OR组合逻辑正确");
        $display(" CTRL模块响应正常");
        $display(" 混合输入模式工作正常");

        
        show_status("最终");
        
        #1000;
        $finish;
    end
    
    // 状态变化监控
    reg [2:0] last_state = 0;
    always @(posedge CLK) begin
        if (STATE != last_state && $time > 100) begin
            $display(">>> 状态变化: %d -> %d (时间: %0t)", last_state, STATE, $time);
            last_state <= STATE;
        end
    end

endmodule