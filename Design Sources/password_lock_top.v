`timescale 1ns / 1ps
//==============================================================
// Module: password_lock_top (最终版 v4.1 - 匹配最新的FSM)
//==============================================================
module password_lock_top(
    input         clk,
    input         rst_n,
    input  [9:0]  sw_nums,
    input         set_btn_raw,
    input         open_sw_raw,
    input         admin_rst_btn_raw,
    input         confirm_btn_raw,
    input         backspace_btn_raw,
    
    // 【修改】输出只有一个16位的led总线
    output reg [15:0] led,
    
    output [6:0]  seg,
    output [7:0]  an
);
    //---------------------------------------------------------
    // 内部连线
    //---------------------------------------------------------
    // 来自debounce模块的干净脉冲信号
    wire set_btn_pulse, open_sw_pulse, admin_rst_btn_pulse, confirm_btn_pulse, backspace_btn_pulse;
    // 来自fsm_controller模块的状态信号
    wire unlock_success_signal, error_pulse_signal, is_alarm_signal;
    wire idle_led_signal, set_mode_led_signal, input_mode_led_signal;
    
    //---------------------------------------------------------
    // 子模块实例化
    //---------------------------------------------------------
    // 实例化5个消抖模块
    debounce u_debounce_set     ( .clk(clk), .rst_n(rst_n), .btn_in(set_btn_raw),       .btn_pulse(set_btn_pulse) );
    debounce u_debounce_open    ( .clk(clk), .rst_n(rst_n), .btn_in(open_sw_raw),      .btn_pulse(open_sw_pulse) );
    debounce u_debounce_admin   ( .clk(clk), .rst_n(rst_n), .btn_in(admin_rst_btn_raw),.btn_pulse(admin_rst_btn_pulse) );
    debounce u_debounce_confirm ( .clk(clk), .rst_n(rst_n), .btn_in(confirm_btn_raw),  .btn_pulse(confirm_btn_pulse) );
    debounce u_debounce_backspace( .clk(clk), .rst_n(rst_n), .btn_in(backspace_btn_raw),.btn_pulse(backspace_btn_pulse) );

    // 实例化FSM，连接到【正确】的接口
    fsm_controller u_fsm_controller (
        .clk              (clk),
        .rst_n            (rst_n),
        .nums_onehot_in   (sw_nums),
        .set_btn          (set_btn_pulse),
        .open_sw          (open_sw_pulse),
        .admin_rst_btn    (admin_rst_btn_pulse),
        .confirm_btn      (confirm_btn_pulse),
        .backspace_btn    (backspace_btn_pulse),
        
        // FSM的输出，连接到内部的wire上
        .unlock_success   (unlock_success_signal),
        .error_pulse      (error_pulse_signal),
        .is_alarm         (is_alarm_signal),
        .idle_led         (idle_led_signal),
        .set_mode_led     (set_mode_led_signal),
        .input_mode_led   (input_mode_led_signal),
        
        .seg              (seg),
        .an               (an)
    );

    //---------------------------------------------------------
    // LED控制逻辑
    //---------------------------------------------------------
    reg [24:0] blink_cnt;
    always @(posedge clk) blink_cnt <= blink_cnt + 1;
    wire blink_1hz = blink_cnt[24];
    
    always @(*) begin
        if (unlock_success_signal) begin
            led = 16'hFFFF; // 开锁成功，全亮！
        end else begin
            // 默认所有灯先熄灭
            led = 16'b0; 
            // 再根据状态点亮对应的指示灯
            led[0]  = idle_led_signal;       // LD0 显示IDLE状态
            led[1]  = input_mode_led_signal; // LD1 显示用户输入状态
            led[2]  = set_mode_led_signal;   // LD2 显示管理员设置状态
            led[3]  = error_pulse_signal;    // LD3 短暂地亮一下，表示密码错误
            led[15] = is_alarm_signal & blink_1hz; // LD15 闪烁报警
        end
    end 
endmodule