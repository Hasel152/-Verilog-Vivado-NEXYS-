`timescale 1ns / 1ps
//==============================================================
// Module: fsm_controller (ȫ���ع��� v5.0)
// Description: ����ɿ��ĵ�һ��ԭ���������д����״̬��
//==============================================================
module fsm_controller(
    input         clk,
    input         rst_n,
    
    // ԭʼ����
    input  [9:0]  nums_onehot_in,
    input         set_btn, open_sw, admin_rst_btn, confirm_btn, backspace_btn,
    
    // ���
    output        unlock_success, error_pulse, is_alarm,
    output        idle_led, set_mode_led, input_mode_led,
    output [6:0]  seg, output [7:0]  an
);

    //---------------------------------------------------------
    // 1. ������״̬����
    //---------------------------------------------------------
    parameter S_IDLE=0, S_SET=1, S_INPUT=2, S_VERIFY=3, S_OPEN=4, S_ERROR=5, S_ALARM=6;

    //---------------------------------------------------------
    // 2. ������������� - �������ⲿ����"�Ŀ���"
    //---------------------------------------------------------
    // �Զ������������һ���Ĵ�
    reg [9:0] nums_onehot_sampled;
    // �����а�ť����Ҳ����һ���Ĵ棬ȷ�������Ǹɾ���ͬ���ź�
    reg set_btn_sampled, open_sw_sampled, admin_rst_btn_sampled, confirm_btn_sampled, backspace_btn_sampled;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            nums_onehot_sampled <= 0;
            set_btn_sampled <= 0; open_sw_sampled <= 0; admin_rst_btn_sampled <= 0; 
            confirm_btn_sampled <= 0; backspace_btn_sampled <= 0;
        end else begin
            nums_onehot_sampled <= nums_onehot_in;
            set_btn_sampled <= set_btn;
            open_sw_sampled <= open_sw;
            admin_rst_btn_sampled <= admin_rst_btn;
            confirm_btn_sampled <= confirm_btn;
            backspace_btn_sampled <= backspace_btn;
        end
    end

    //---------------------------------------------------------
    // 3. ���źŴ������� - ����"����"���м���
    //---------------------------------------------------------
    // ��������Ч�Լ�� (ֻ����ֻ��һ�����ذ��µ����)
    //---------------------------------------------------------
    // 3. �����ռ��ݰ桿���봦���߼�
    //---------------------------------------------------------
    
    // ���ǲ���ʹ�� $countones��������������ļӷ�����
    // ��δ���100%�������κ�Verilogģʽ�¹�����
    wire [3:0] num_of_ones;
    assign num_of_ones = nums_onehot_in[0] + nums_onehot_in[1] + 
                         nums_onehot_in[2] + nums_onehot_in[3] + 
                         nums_onehot_in[4] + nums_onehot_in[5] + 
                         nums_onehot_in[6] + nums_onehot_in[7] + 
                         nums_onehot_in[8] + nums_onehot_in[9];
                         
    wire is_onehot_valid = (num_of_ones == 1);
    
    // �����ؼ�� (�ⲿ��Ҳ�ǻ���Verilog��û������)
    reg [9:0] nums_onehot_d0, nums_onehot_d1;
    always @(posedge clk) begin
        nums_onehot_d0 <= nums_onehot_in;
        nums_onehot_d1 <= nums_onehot_d0;
    end
    wire key_pressed_event = |( ~nums_onehot_d1 & nums_onehot_d0 );

    
    // ���յ���Ч�����¼�
    assign key_valid_event = key_pressed_event && is_onehot_valid;

    // �����뵽�����Ƶ�ת���� (��Ƕ����Ԫ����������������������߼�)
    reg [3:0] key_num_binary;
   always @(*) begin
        key_num_binary = 4'hF; 
        case (nums_onehot_in)
            10'b0000000001: key_num_binary = 4'd0;
            10'b0000000010: key_num_binary = 4'd1;
            10'b0000000100: key_num_binary = 4'd2;
            10'b0000001000: key_num_binary = 4'd3;
            10'b0000010000: key_num_binary = 4'd4;
            10'b0000100000: key_num_binary = 4'd5;
            10'b0001000000: key_num_binary = 4'd6;
            10'b0010000000: key_num_binary = 4'd7;
            10'b0100000000: key_num_binary = 4'd8;
            10'b1000000000: key_num_binary = 4'd9;
        endcase
    end

    // 4. �����ľ������� - ״̬��
    //---------------------------------------------------------
    reg [2:0]  current_state,next_state;
    reg [15:0] password = 16'h0000;
    reg [15:0] input_buffer;
    reg [2:0]  input_count;
    reg [1:0]  error_count;
    reg        timer_10s_start, timer_20s_start;
    wire       timer_10s_done,  timer_20s_done;

     //---------------------------------------------------------
    // 4. ����ʽ״̬��
    //---------------------------------------------------------
    // ��һ��: ״̬�Ĵ��� (ͬ��ʱ��)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= S_IDLE;
        else        current_state <= next_state;
    end

    // �ڶ���: ��һ״̬���� (����߼�)
    always @(*) begin
        next_state = current_state;
        case (current_state)
            S_IDLE: begin
              next_state = S_IDLE;
              if (open_sw) begin 
                    next_state = S_INPUT;
              end
              else if (set_btn) begin
                 next_state = S_SET;
              end

            end
            S_SET:    if ((input_count == 4 && confirm_btn) || timer_10s_done) next_state = S_IDLE;
            S_INPUT: 
             if (input_count == 4 && confirm_btn) begin 
                 next_state = S_VERIFY;
                 end
             else if(timer_10s_done) begin
                 next_state = S_IDLE;
              end
            S_VERIFY: if (input_buffer == password) next_state = S_OPEN;
                      else if (error_count >= 2)    next_state = S_ALARM;
                      else                          next_state = S_ERROR;
            S_OPEN:   if (confirm_btn || timer_20s_done) next_state = S_IDLE;
            S_ERROR: begin
             if(confirm_btn)begin 
                next_state = S_INPUT; // �����ֱ�ӷ���
             end
            end
            S_ALARM:  if (admin_rst_btn) next_state = S_IDLE;
        endcase
    end

    // ������: ҵ���߼������ (ͬ��ʱ��)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_buffer <= 0; input_count <= 0; error_count <= 0;
            timer_10s_start <= 0; timer_20s_start <= 0;
        end else begin
            timer_10s_start <= 1'b0; timer_20s_start <= 1'b0;

        if (current_state == S_SET && next_state == S_IDLE && input_count == 4 && confirm_btn) begin
            password <= input_buffer;
        end

            // ֻҪ�ص�IDLE״̬������մ������
        if ( (current_state == S_ALARM && next_state == S_IDLE) || (current_state == S_VERIFY && next_state == S_OPEN) ) begin
            error_count <= 0;
        end
            case (current_state)
                S_IDLE:
                   if (next_state == S_SET || next_state == S_INPUT) begin
                     timer_10s_start <= 1'b1;
                     input_buffer    <= 0;     // ��ջ���
                     input_count     <= 0;     // ���λ��
                   end
                S_SET: begin
                    if (key_valid_event || backspace_btn || confirm_btn) timer_10s_start <= 1'b1;
                    if (key_valid_event && input_count < 4) begin
                        input_buffer <= (input_buffer << 4) | key_num_binary;
                        input_count  <= input_count + 1;
                    end
                    else if (backspace_btn && input_count > 0) begin
                        input_buffer <= input_buffer >> 4;
                        input_count  <= input_count - 1;
                    end
                    if (current_state == S_SET && input_count == 4 && confirm_btn) begin
                        password <= input_buffer;
                    end
                end
                S_INPUT: begin
                   if (key_valid_event || backspace_btn || confirm_btn) timer_10s_start <= 1'b1;
                    if (key_valid_event && input_count < 4) begin
                        input_buffer <= (input_buffer << 4) | key_num_binary;
                        input_count  <= input_count + 1;
                    end
                    else if (backspace_btn && input_count > 0) begin
                        input_buffer <= input_buffer >> 4;
                        input_count  <= input_count - 1;
                    end
                end
                S_VERIFY: begin
                    if (input_buffer != password) begin
                        error_count <= error_count + 1;
                    end else if  (next_state == S_OPEN) begin
                        timer_20s_start <= 1'b1;
                    end
                 end
                S_OPEN:  ;
            endcase
        end
    end

    //---------------------------------------------------------
    // 5. �������������
    //---------------------------------------------------------
  reg [24:0] blink_cnt;
    always @(posedge clk) blink_cnt <= blink_cnt + 1;
    assign unlock_success = (current_state == S_OPEN);
    assign error_pulse    = (current_state == S_ERROR);
    assign is_alarm       = (current_state == S_ALARM) && blink_cnt[24];
    assign idle_led       = (current_state == S_IDLE);
    assign set_mode_led   = (current_state == S_SET);
    assign input_mode_led = (current_state == S_INPUT);
    
   timer u_timer(
        .clk(clk), .rst_n(rst_n),
        .start_10s(timer_10s_start), .done_10s(timer_10s_done),
        .start_20s(timer_20s_start), .done_20s(timer_20s_done)
    );
    
    // --- ʵ���� seg_display ---
    reg [31:0] seg_data;
    always@(*) begin
        seg_data = 32'hFFFFFFFF;
        case(current_state)
            S_SET, S_INPUT:
                case(input_count)
                    3'd1: seg_data[3:0]   = input_buffer[3:0];
                    3'd2: seg_data[7:0]   = input_buffer[7:0];
                    3'd3: seg_data[11:0]  = input_buffer[11:0];
                    3'd4: seg_data[15:0]  = input_buffer[15:0];
                    default: seg_data = 32'hFFFFFFFF;
                endcase
            S_OPEN:   seg_data[15:0] = {4'h0, 4'hE, 4'd0, 4'hE}; // "OPEN"
            S_ERROR:  seg_data[15:0] = {4'hE, 4'hA, 4'hA, 4'h0};     // "Err"
            S_ALARM:  seg_data[15:0] = {4'hA, 4'h1, 4'hA, 4'h7}; // "ALAr"
            default:  seg_data = 32'hFFFFFFFF;
        endcase
    end
    
    seg_display u_seg_display (
        .clk(clk), .rst_n(rst_n),
        .data(seg_data),
        .seg(seg), .an(an)
    );
    
endmodule

// ����Ҫ���뽫����ʡ�Ժ�(...)�Ĳ��֣�����֮ǰ��ȷ�Ĵ�����䣡
// ���� $countones ���Ի��ɼӷ�����timer��seg_display��ʵ����Ҫд����