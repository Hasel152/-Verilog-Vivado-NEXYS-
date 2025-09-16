`timescale 1ns / 1ps
//==============================================================
// Module: password_lock_top (���հ� v4.1 - ƥ�����µ�FSM)
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
    
    // ���޸ġ����ֻ��һ��16λ��led����
    output reg [15:0] led,
    
    output [6:0]  seg,
    output [7:0]  an
);
    //---------------------------------------------------------
    // �ڲ�����
    //---------------------------------------------------------
    // ����debounceģ��ĸɾ������ź�
    wire set_btn_pulse, open_sw_pulse, admin_rst_btn_pulse, confirm_btn_pulse, backspace_btn_pulse;
    // ����fsm_controllerģ���״̬�ź�
    wire unlock_success_signal, error_pulse_signal, is_alarm_signal;
    wire idle_led_signal, set_mode_led_signal, input_mode_led_signal;
    
    //---------------------------------------------------------
    // ��ģ��ʵ����
    //---------------------------------------------------------
    // ʵ����5������ģ��
    debounce u_debounce_set     ( .clk(clk), .rst_n(rst_n), .btn_in(set_btn_raw),       .btn_pulse(set_btn_pulse) );
    debounce u_debounce_open    ( .clk(clk), .rst_n(rst_n), .btn_in(open_sw_raw),      .btn_pulse(open_sw_pulse) );
    debounce u_debounce_admin   ( .clk(clk), .rst_n(rst_n), .btn_in(admin_rst_btn_raw),.btn_pulse(admin_rst_btn_pulse) );
    debounce u_debounce_confirm ( .clk(clk), .rst_n(rst_n), .btn_in(confirm_btn_raw),  .btn_pulse(confirm_btn_pulse) );
    debounce u_debounce_backspace( .clk(clk), .rst_n(rst_n), .btn_in(backspace_btn_raw),.btn_pulse(backspace_btn_pulse) );

    // ʵ����FSM�����ӵ�����ȷ���Ľӿ�
    fsm_controller u_fsm_controller (
        .clk              (clk),
        .rst_n            (rst_n),
        .nums_onehot_in   (sw_nums),
        .set_btn          (set_btn_pulse),
        .open_sw          (open_sw_pulse),
        .admin_rst_btn    (admin_rst_btn_pulse),
        .confirm_btn      (confirm_btn_pulse),
        .backspace_btn    (backspace_btn_pulse),
        
        // FSM����������ӵ��ڲ���wire��
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
    // LED�����߼�
    //---------------------------------------------------------
    reg [24:0] blink_cnt;
    always @(posedge clk) blink_cnt <= blink_cnt + 1;
    wire blink_1hz = blink_cnt[24];
    
    always @(*) begin
        if (unlock_success_signal) begin
            led = 16'hFFFF; // �����ɹ���ȫ����
        end else begin
            // Ĭ�����е���Ϩ��
            led = 16'b0; 
            // �ٸ���״̬������Ӧ��ָʾ��
            led[0]  = idle_led_signal;       // LD0 ��ʾIDLE״̬
            led[1]  = input_mode_led_signal; // LD1 ��ʾ�û�����״̬
            led[2]  = set_mode_led_signal;   // LD2 ��ʾ����Ա����״̬
            led[3]  = error_pulse_signal;    // LD3 ���ݵ���һ�£���ʾ�������
            led[15] = is_alarm_signal & blink_1hz; // LD15 ��˸����
        end
    end 
endmodule