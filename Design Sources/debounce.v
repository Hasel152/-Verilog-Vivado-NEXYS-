`timescale 1ns / 1ps
//==============================================================
// Module: debounce (按键消抖)
// Description: 通用按键消抖模块。
//              输入一个有抖动的、低电平有效的按键信号，
//              输出一个干净的、单周期有效的脉冲事件。
//==============================================================
module debounce(
    input        clk,          // 输入：系统主时钟 (100MHz)
    input        rst_n,        // 输入：全局复位
    input        btn_in,       // 输入：原始的、带抖动的按键信号
    output       btn_pulse     // 输出：消抖后产生的单周期脉冲
);
    // 定义消抖时间，通常10-20ms即可。我们选择10ms。
    // 10ms @ 100MHz clk = 1,000,000 个时钟周期
    parameter DEBOUNCE_CNT_MAX = 20'd1_000_000;

    // 内部寄存器
    reg [1:0]  state;          // 一个迷你的内部状态机
    reg [19:0] counter;        // 消抖延时计数器
    reg        btn_in_sync;    // 同步后的按键输入信号

    // FSM 状态定义
    parameter IDLE    = 2'b00; // 状态0：等待按键按下
    parameter DEBOUNCE = 2'b01; // 状态1：正在延时消抖
    parameter WAIT_RELEASE = 2'b10; // 状态2：确认按下，等待按键释放

    //---------------------------------------------------------
    // 1. 输入同步器 (Input Synchronizer)
    //---------------------------------------------------------
    // 为了防止来自异步世界的btn_in信号导致亚稳态，
    // 我们先用一个触发器把它"同步"到我们的clk时钟域。
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            btn_in_sync <= 1'b1; // 默认按键是没按下的(高电平)
        else
            btn_in_sync <= btn_in;
    end

    //---------------------------------------------------------
    // 2. 核心消抖逻辑 (用一个迷你状态机实现)
    //---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            counter <= 0;
        end else begin
            case(state)
                IDLE: begin // 在"等待"状态
                    if(btn_in_sync == 1'b0) begin // 如果检测到按键被按下...
                        state <= DEBOUNCE;       // ...就进入"消抖延时"状态...
                        counter <= 0;            // ...并启动计数器。
                    end
                end
                
                DEBOUNCE: begin // 在"延时"状态
                    if(counter == DEBOUNCE_CNT_MAX) begin // 如果10ms延时结束...
                        if(btn_in_sync == 1'b0) begin // ...并且再次确认按键【仍然】是按下的...
                            state <= WAIT_RELEASE;   // ...那么就确认为一次有效按下，进入"等待释放"状态。
                        end else begin
                            state <= IDLE; // 否则认为是干扰，返回"等待"状态。
                        end
                    end else begin
                        counter <= counter + 1; // 延时没结束，继续数数。
                    end
                end

                WAIT_RELEASE: begin // 在"等待释放"状态
                    if(btn_in_sync == 1'b1) begin // 如果检测到按键被松开了...
                        state <= IDLE;           // ...就返回最初的"等待"状态，准备下一次按键。
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
    
    //---------------------------------------------------------
    // 3. 输出逻辑
    //---------------------------------------------------------
    // 当且仅当，状态机从"延时"状态【刚刚跳转】到"等待释放"状态的那一瞬间，
    // 我们才产生一个单周期的脉冲。
    assign btn_pulse = (state == DEBOUNCE) && (counter == DEBOUNCE_CNT_MAX) && (btn_in_sync == 1'b0);

endmodule