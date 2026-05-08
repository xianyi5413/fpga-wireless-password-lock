`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 完善的TOP模块 - 蓝牙集成版本
// 集成了物理按键和蓝牙双重输入方式
//////////////////////////////////////////////////////////////////////////////////

module TOP(
    input CLK,
    
    // 物理输入信号
    input SW0_IN,input SW1_IN,input SW2_IN,input SW3_IN,input SW4_IN,
    input SW5_IN,input SW6_IN,input SW7_IN,input SW8_IN,input SW9_IN,
    input RESET,
    input BACKSPACE_IN,
    input OK_IN,
    input MANAGER_IN,
    input START_IN,
    
    // 蓝牙接口信号
    input BT_RX,
    output BT_TX,
    
    // 输出信号
    output [2:0] STATE,
    output [7:0] AN,
    output [7:0] SEG,
    output [9:0] LED,
    output RGB1_RED, output RGB1_BLUE, output RGB1_GREEN,
    output RGB2_RED, output RGB2_BLUE, output RGB2_GREEN,
   
    output BUZZER  // 新增蜂鸣器输出
);

    // 物理按键消抖后的信号
    wire BACKSPACE_PHYSICAL;
    wire OK_PHYSICAL;
    wire MANAGER_PHYSICAL;
    wire START_PHYSICAL;
    wire SW0_PHYSICAL, SW1_PHYSICAL, SW2_PHYSICAL, SW3_PHYSICAL, SW4_PHYSICAL;
    wire SW5_PHYSICAL, SW6_PHYSICAL, SW7_PHYSICAL, SW8_PHYSICAL, SW9_PHYSICAL;
    
    // 蓝牙输出信号
    wire BACKSPACE_BT;
    wire OK_BT;
    wire MANAGER_BT;
    wire START_BT;
    wire SW0_BT, SW1_BT, SW2_BT, SW3_BT, SW4_BT;
    wire SW5_BT, SW6_BT, SW7_BT, SW8_BT, SW9_BT;
    
    // 最终组合信号（物理输入 OR 蓝牙输入）
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
    
    // 内部状态线 - 用于蓝牙模块的状态反馈
    wire [2:0] error_count;  // 如果CTRL模块有错误计数，连接此线
    
    // 蓝牙活动指示 - 任何蓝牙信号激活时为高
    assign BT_ACTIVE = BACKSPACE_BT | OK_BT | MANAGER_BT | START_BT |
                       SW0_BT | SW1_BT | SW2_BT | SW3_BT | SW4_BT |
                       SW5_BT | SW6_BT | SW7_BT | SW8_BT | SW9_BT;
    
    //=========================================================================
    // 物理按键消抖模块实例化
    //=========================================================================
    KEY_JITTER i0_KEY_JITTER(
        .CLK(CLK),
        .key_in(START_IN),
        .key_posedge(START_PHYSICAL)
    );
    
    KEY_JITTER i1_KEY_JITTER(
        .CLK(CLK),
        .key_in(BACKSPACE_IN),
        .key_posedge(BACKSPACE_PHYSICAL)
    );    
    
    KEY_JITTER i2_KEY_JITTER(
        .CLK(CLK),
        .key_in(OK_IN),
        .key_posedge(OK_PHYSICAL)
    );    
    
    KEY_JITTER i3_KEY_JITTER(
        .CLK(CLK),
        .key_in(MANAGER_IN),
        .key_posedge(MANAGER_PHYSICAL)
    );    
    
    KEY_JITTER S0_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW0_IN),
        .key_posedge(SW0_PHYSICAL)
    );       
    
    KEY_JITTER S1_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW1_IN),
        .key_posedge(SW1_PHYSICAL)
    );     
    
    KEY_JITTER S2_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW2_IN),
        .key_posedge(SW2_PHYSICAL)
    );     
    
    KEY_JITTER S3_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW3_IN),
        .key_posedge(SW3_PHYSICAL)
    );     
    
    KEY_JITTER S4_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW4_IN),
        .key_posedge(SW4_PHYSICAL)
    );     
    
    KEY_JITTER S5_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW5_IN),
        .key_posedge(SW5_PHYSICAL)
    );     
    
    KEY_JITTER S6_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW6_IN),
        .key_posedge(SW6_PHYSICAL)
    );     
    
    KEY_JITTER S7_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW7_IN),
        .key_posedge(SW7_PHYSICAL)
    );     
    
    KEY_JITTER S8_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW8_IN),
        .key_posedge(SW8_PHYSICAL)
    );     
    
    KEY_JITTER S9_KEY_JITTER(
        .CLK(CLK),
        .key_in(SW9_IN),
        .key_posedge(SW9_PHYSICAL)
    ); 
    
    //=========================================================================
    // 蓝牙接口模块实例化
    //=========================================================================
    BLUETOOTH_INTERFACE bt_interface (
        .CLK(CLK),
        .RESET(RESET),
        .RX(BT_RX),
        .TX(BT_TX),
        
        // 蓝牙输出信号 - 连接到组合逻辑
        .BACKSPACE_BT(BACKSPACE_BT),
        .OK_BT(OK_BT),
        .MANAGER_BT(MANAGER_BT),
        .START_BT(START_BT),
        .SW0_BT(SW0_BT), .SW1_BT(SW1_BT), .SW2_BT(SW2_BT), .SW3_BT(SW3_BT), .SW4_BT(SW4_BT),
        .SW5_BT(SW5_BT), .SW6_BT(SW6_BT), .SW7_BT(SW7_BT), .SW8_BT(SW8_BT), .SW9_BT(SW9_BT),
        
        // 状态反馈 - 从CTRL模块获取当前状态
        .CURRENT_STATE(STATE),
        .ERROR_TIMES(error_count),    // 如果CTRL有错误计数则连接，否则保持3'b0
        .LED_STATUS(LED)
    );
    
    //=========================================================================
    // 主控制模块 - 使用组合后的信号作为输入
    //=========================================================================
    CTRL i_CTRL(
        .CLK(CLK),
        .RESET(RESET),
        
        // 使用组合后的信号（物理输入 OR 蓝牙输入）
        .BACKSPACE(BACKSPACE),
        .OK(OK),
        .MANAGER(MANAGER),
        .START(START),
        .SW0(SW0),.SW1(SW1),.SW2(SW2),.SW3(SW3),.SW4(SW4),
        .SW5(SW5),.SW6(SW6),.SW7(SW7),.SW8(SW8),.SW9(SW9),
        
        // 输出信号
        .STATE(STATE),
        .LED(LED),
        .AN(AN),
        .SEG(SEG),
        .RGB1_RED(RGB1_RED),.RGB1_GREEN(RGB1_GREEN),.RGB1_BLUE(RGB1_BLUE),
        .RGB2_RED(RGB2_RED),.RGB2_GREEN(RGB2_GREEN),.RGB2_BLUE(RGB2_BLUE),
        
        // 如果CTRL模块有错误计数输出，可以在这里添加
        // .ERROR_COUNT(error_count)
        .BUZZER(BUZZER)  // 连接蜂鸣器输出
    );

endmodule