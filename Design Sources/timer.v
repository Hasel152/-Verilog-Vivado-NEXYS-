`timescale 1ns / 1ps

//==============================================================
// Module: timer (极简命名版)
//==============================================================
module timer(
    input         clk,             // 输入：系统主时钟 (100MHz)
    input         rst_n,           // 输入：复位信号

    input         start_10s,       // 输入："开始10秒计时"命令
    output        done_10s,        // 输出："10秒到了！"报告

    input         start_20s,       // 输入："开始20秒计时"命令
    output        done_20s         // 输出："20秒到了！"报告
);

    //---------------------------------------------------------
    // 1. 定义常量 (目标值)
    //---------------------------------------------------------
    parameter TARGET_10S = 30'd1_000_000_000;
    parameter TARGET_20S = 31'd2_000_000_000;
    
    //---------------------------------------------------------
    // 2. 内部变量 (秒表的核心部件)
    //---------------------------------------------------------
    reg [29:0] counter_10s;        // 10秒定时器的计数器
    reg        is_running_10s;     // 10秒定时器是否在运行？(是/否)
    
    reg [30:0] counter_20s;        // 20秒定时器的计数器
    reg        is_running_20s;     // 20秒定时器是否在运行？(是/否)

    //---------------------------------------------------------
    // 3. 核心逻辑 (秒表如何工作)
    //---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时，把所有东西都初始化
            counter_10s <= 0;
            is_running_10s <= 0; // 0 代表"否"
            counter_20s <= 0;
            is_running_20s <= 0;
        end
        else begin
            // --- 10秒秒表的逻辑 ---
            if (start_10s) begin              // 如果"开始"按钮被按下...
                is_running_10s <= 1;          // ...就设置状态为"是，正在运行"...
                counter_10s <= 0;             // ...并且计数器从0开始。
            end 
            else if (counter_10s == TARGET_10S - 1) begin // 如果计数器数满了...
                is_running_10s <= 0;          // ...就设置状态为"否，已停止"...
                counter_10s <= 0;             // ...并且计数器归零。
            end 
            else if (is_running_10s == 1) begin // 如果状态是"正在运行"...
                counter_10s <= counter_10s + 1; // ...那么计数器就加一。
            end

            // --- 20秒秒表的逻辑 (和上面完全一样) ---
            if (start_20s) begin
                is_running_20s <= 1;
                counter_20s <= 0;
            end 
            else if (counter_20s == TARGET_20S - 1) begin
                is_running_20s <= 0;
                counter_20s <= 0;
            end 
            else if (is_running_20s == 1) begin
                counter_20s <= counter_20s + 1;
            end
        end
    end

    //---------------------------------------------------------
    // 4. 输出信号
    //---------------------------------------------------------
    // "完成"信号 = (计数器的值 == 目标值 - 1)
    assign done_10s = (counter_10s == TARGET_10S - 1);
    assign done_20s = (counter_20s == TARGET_20S - 1);

endmodule