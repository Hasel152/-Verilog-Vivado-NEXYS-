# 4-Digit Digital Password Lock on FPGA (基于FPGA的四位密码锁)

A digital password lock implemented on a NEXYS 4 DDR FPGA board. This project was developed for the Digital System Design course at the Southeast University (SEU) Summer School.

本项目是一个基于 **NEXYS 4** DDR 开发板实现的四位数字密码锁。它是为**东南大学(SEU)**暑期学校的《数字系统设计》课程而设计的。
（笔者还没打磨好ＲＥＡＤＭＥ）
---

## 🚀 主要功能 (Features)

*   **四位密码输入**: 通过板载按键输入一个四位数的密码。
*   **实时数码管显示**: 在输入过程中，7段数码管会实时显示当前输入的数字。
*   **密码验证**: 输入完成后，系统会自动与预设的密码进行比对。
*   **状态指示**:
    *   密码正确时，亮起，表示解锁成功。
    *   密码错误时，红灯(LED)亮起，表示验证失败。
*   **系统复位**: 可以随时通过复位按钮清空输入，返回初始状态。

## 🛠️ 硬件与软件环境 (Hardware and Software)

*   **硬件平台 (Hardware Platform)**: Digilent **NEXYS 4** DDR (Artix-7 FPGA)
*   **开发工具 (Development Tool)**: **Vivado** 2019.1 (或更高版本)
*   **开发语言 (Language)**: **Verilog** HDL

## ⚙️ 系统设计 (System Design)

本设计的核心是一个有限状态机 (FSM)，用于控制密码锁的整个逻辑流程。状态机包含以下几个主要状态：

1.  **IDLE (空闲状态)**: 系统上电或复位后的初始状态，等待用户输入第一位密码。
2.  **INPUT (输入状态)**: 用户每按下一个数字键，状态机就会记录该数字并等待下一位输入，直到四位密码全部输入完毕。
3.  **CHECK (验证状态)**: 四位密码输入完成后，系统将输入密码与内部预设的密码 (`1234`) 进行比较。
4.  **UNLOCK (解锁状态)**: 如果密码匹配，系统进入解锁状态，点亮代表成功的绿色LED。
5.  **FAIL (失败状态)**: 如果密码不匹配，系统进入失败状态，点亮代表失败的红色LED。

### 端口与管脚分配 (I/O Mapping)

| 端口 (Port)         | 功能 (Function)         | NEXYS 4 管脚 (Pin)      |
| --------------------- | ----------------------- | ----------------------- |
| `clk`                 | 系统时钟 (100MHz)       | `E3`                    |
| `rst`                 | 复位按钮                | `C12`                   |
| `btn[3:0]`            | 密码输入按键 (0-9)      | *(根据你的设计填写)*        |
| `led_success`         | 解锁成功指示灯          | *(根据你的设计填写)*        |
| `led_fail`            | 解锁失败指示灯          | *(根据你的设计填写)*        |
| `seg_an[3:0]`         | 数码管位选              | *(根据你的设计填写)*        |
| `seg_data[6:0]`       | 数码管段选              | *(根据你的设计填写)*        |

**注意**: 你需要根据你的 Vivado 工程中的 `.xdc` 约束文件来填写具体的管脚号。

## 🔧 如何使用 (Getting Started)

1.  **克隆仓库 (Clone Repository)**
    ```bash
    git clone [你的仓库SSH或HTTPS链接]
    ```
2.  **打开工程 (Open Project)**
    使用 Vivado 打开项目中的 `.xpr` 文件。

3.  **生成比特流 (Generate Bitstream)**
    在 Vivado 中依次执行 "Run Synthesis" -> "Run Implementation" -> "Generate Bitstream"。

4.  **烧录程序 (Program Device)**
    将生成的 `.bit` 文件烧录到你的 NEXYS 4 开发板中。

5.  **操作 (Operate)**
    *   按下复位键初始化。
    *   使用按键输入预设的四位密码 (例如: `1234`)。
    *   观察LED灯和数码管的状态。

## 🎥 效果演示 (Demonstration)

*(这里是一个非常好的地方，可以放一张照片或者一个GIF动图来展示你的密码锁实际工作的样子)*

![Demo GIF](https://example.com/your_demo_gif.gif)

## 👤 作者 (Author)

*   [你的名字] - [你的GitHub主页链接 (可选)]

---
