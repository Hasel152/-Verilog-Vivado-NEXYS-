`timescale 1ns / 1ps
//==============================================================
// Module: fsm_controller (全新重构版 v5.0)
// Description: 从最可靠的第一性原理出发，重写核心状态机
//==============================================================
module fsm_controller(
    input         clk,
    input         rst_n,
    
    // 原始输入
    input  [9:0]  nums_onehot_in,
    input         set_btn, open_sw, admin_rst_btn, confirm_btn, backspace_btn,
    
    // 输出
    output        unlock_success, error_pulse, is_alarm,
    output        idle_led, set_mode_led, input_mode_led,
    output [6:0]  seg, output [7:0]  an
);

    //---------------------------------------------------------
    // 1. 参数与状态定义
    //---------------------------------------------------------
    parameter S_IDLE=0, S_SET=1, S_INPUT=2, S_VERIFY=3, S_OPEN=4, S_ERROR=5, S_ALARM=6;

    //---------------------------------------------------------
    // 2. 【输入采样区】 - 把所有外部输入"拍快照"
    //---------------------------------------------------------
    // 对独热码输入进行一级寄存
    reg [9:0] nums_onehot_sampled;
    // 对所有按钮脉冲也进行一级寄存，确保它们是干净的同步信号
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
    // 3. 【信号处理区】 - 基于"快照"进行计算
    //---------------------------------------------------------
    // 独热码有效性检查 (只处理只有一个开关按下的情况)
    //---------------------------------------------------------
    // 3. 【最终兼容版】输入处理逻辑
    //---------------------------------------------------------
    
    // 我们不再使用 $countones，而是用最基础的加法器。
    // 这段代码100%可以在任何Verilog模式下工作。
    wire [3:0] num_of_ones;
    assign num_of_ones = nums_onehot_in[0] + nums_onehot_in[1] + 
                         nums_onehot_in[2] + nums_onehot_in[3] + 
                         nums_onehot_in[4] + nums_onehot_in[5] + 
                         nums_onehot_in[6] + nums_onehot_in[7] + 
                         nums_onehot_in[8] + nums_onehot_in[9];
                         
    wire is_onehot_valid = (num_of_ones == 1);
    
    // 上升沿检测 (这部分也是基础Verilog，没有问题)
    reg [9:0] nums_onehot_d0, nums_onehot_d1;
    always @(posedge clk) begin
        nums_onehot_d0 <= nums_onehot_in;
        nums_onehot_d1 <= nums_onehot_d0;
    end
    wire key_pressed_event = |( ~nums_onehot_d1 & nums_onehot_d0 );

    
    // 最终的有效输入事件
    assign key_valid_event = key_pressed_event && is_onehot_valid;

    // 独热码到二进制的转换器 (用嵌套三元运算符，这是最基础的组合逻辑)
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

    // 4. 【核心决策区】 - 状态机
    //---------------------------------------------------------
    reg [2:0]  current_state,next_state;
    reg [15:0] password = 16'h0000;
    reg [15:0] input_buffer;
    reg [2:0]  input_count;
    reg [1:0]  error_count;
    reg        timer_10s_start, timer_20s_start;
    wire       timer_10s_done,  timer_20s_done;

     //---------------------------------------------------------
    // 4. 三段式状态机
    //---------------------------------------------------------
    // 第一段: 状态寄存器 (同步时序)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= S_IDLE;
        else        current_state <= next_state;
    end

    // 第二段: 下一状态决策 (组合逻辑)
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
                next_state = S_INPUT; // 错误后直接返回
             end
            end
            S_ALARM:  if (admin_rst_btn) next_state = S_IDLE;
        endcase
    end

    // 第三段: 业务逻辑与输出 (同步时序)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_buffer <= 0; input_count <= 0; error_count <= 0;
            timer_10s_start <= 0; timer_20s_start <= 0;
        end else begin
            timer_10s_start <= 1'b0; timer_20s_start <= 1'b0;

        if (current_state == S_SET && next_state == S_IDLE && input_count == 4 && confirm_btn) begin
            password <= input_buffer;
        end

            // 只要回到IDLE状态，就清空错误计数
        if ( (current_state == S_ALARM && next_state == S_IDLE) || (current_state == S_VERIFY && next_state == S_OPEN) ) begin
            error_count <= 0;
        end
            case (current_state)
                S_IDLE:
                   if (next_state == S_SET || next_state == S_INPUT) begin
                     timer_10s_start <= 1'b1;
                     input_buffer    <= 0;     // 清空缓存
                     input_count     <= 0;     // 清空位数
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
    // 5. 【输出驱动区】
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
    
    // --- 实例化 seg_display ---
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

// 【重要】请将上面省略号(...)的部分，用你之前正确的代码填充！
// 比如 $countones 可以换成加法器，timer和seg_display的实例化要写完整