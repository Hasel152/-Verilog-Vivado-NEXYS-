# 4-Digit Digital Password Lock on FPGA (基于FPGA的四位密码锁)

A digital password lock implemented on a NEXYS 4 DDR FPGA board. This project was developed for the Digital System Design course at the Southeast University (SEU) Summer School.

本项目是一个基于 **NEXYS 4** DDR 开发板实现的四位数字密码锁。它是为**东南大学(SEU)**暑期学校的《数字系统设计》课程而设计的。

---

## 🚀 主要功能 (Features)

*   **多模式操作**:
    *   **用户模式**: 用于正常的密码输入和开锁。
    *   **管理员模式**: 允许管理员安全地设置新密码。
*   **直观的独热码输入**: 使用板载的10个滑动开关 (`SW0`-`SW9`) 分别对应数字`0`-`9`，输入方式清晰直观，并有防多键误触的“独热码有效性”检测。
*   **实时4位密码显示**: 在输入和设置过程中，右侧4位数码管会实时显示当前已输入的密码。
*   **完善的错误处理机制**:
    *   密码错误时，会有明确的LED和数码管提示。
    *   连续输入错误**3次**后，系统将自动进入**报警状态**并锁定。
*   **健壮的超时机制**:
    *   在输入或设置密码时，**10秒**无操作，系统将自动返回等待状态。
    *   在开锁成功后，**20秒**无操作，系统将自动上锁返回等待状态。
*   **清晰的多状态LED指示**:
    *   **等待状态 (`S_IDLE`)**: LD0 亮起。
    *   **用户输入模式 (`S_INPUT`)**: LD1 亮起。
    *   **管理员设置模式 (`S_SET`)**: LD2 亮起。
    *   **密码错误 (`S_ERROR`)**: LD3 短暂闪烁。
    *   **开锁成功 (`S_OPEN`)**: **所有16个LED灯**全部亮起，提供强烈的视觉反馈。
    *   **报警状态 (`S_ALARM`)**: LD15 持续闪烁。
*   **人性化交互**:
    *   支持**退格键**，方便修改输入错误。
    *   密码错误后，用户可选择**手动修改**错误密码，或按**退格键**重新输入。
    *   管理员可通过专用按键**解除报警**。

## 🛠️ 硬件与软件环境 (Hardware and Software)

*   **硬件平台 (Hardware Platform)**: Digilent **NEXYS 4 DDR** (Artix-7 FPGA, XC7A100T)
*   **开发工具 (Development Tool)**: **Vivado** 2023.2 (或更高版本)
*   **开发语言 (Language)**: **Verilog** HDL

## ⚙️ 系统设计 (System Design)

本设计的核心是一个**职责分离、高度模块化**的系统，由以下几个关键模块构成：

*   **`password_lock_top` (顶层模块)**: 负责所有子模块的实例化和连接，以及顶层I/O的定义和LED显示逻辑的实现。
*   **`fsm_controller` (核心状态机)**: **项目的大脑**。采用**三段式状态机**实现，精确控制7个状态（`S_IDLE`, `S_INPUT`, `S_SET`, `S_VERIFY`, `S_OPEN`, `S_ERROR`, `S_ALARM`）之间的跳转和业务逻辑。
*   **`debounce` (按键消抖)**: 一个通用的按键消抖模块，为5个功能按键提供干净、无抖动的单周期脉冲信号，确保FSM能可靠地接收指令。
*   **`timer` (定时器)**: 提供两个独立的定时器（10秒和20秒），用于实现超时功能。
*   **`seg_display` (数码管驱动)**: 负责将32位数据通过**动态扫描**的方式，稳定地显示在8位数码管上，内部包含经过验证的4位转7位译码器。

### 端口与管脚分配 (I/O Mapping)

| 端口 (Port) | 功能 (Function) | NEXYS 4 管脚 (Pin) | 物理器件 (Device) |
| :--- | :--- | :--- | :--- |
| `clk` | 系统时钟 (100MHz) | `E3` | Crystal Oscillator |
| `rst_n` | 全局复位 (低有效) | `C12` | **CPU_RESETN** (红色按钮) |
| `sw_nums[9:0]` | 数字输入 (独热码) | `J15`-`U8` (详见XDC) | `SW0` - `SW9` |
| `open_sw_raw` | 请求开锁 | `P18` | BTND (下按钮) |
| `set_btn_raw` | 管理员模式 | `M18` | BTNU (上按钮) |
| `confirm_btn_raw`| 确认 | `N17` | BTNC (中央按钮) |
| `backspace_btn_raw`| 退格 | `P17` | BTNL (左按钮) |
| `admin_rst_btn_raw`| 解除报警 | `M17` | BTNR (右按钮) |
| `led[15:0]` | 状态指示灯 | `H17`-`R12` (详见XDC) | `LD0` - `LD15` |
| `an[7:0]` | 数码管位选 | `J17`-`U13` (详见XDC) | 7-Segment Anodes |
| `seg[6:0]` | 数码管段选 | `T10`-`L18` (详见XDC) | 7-Segment Segments |

## 🔧 如何使用 (Getting Started)

1.  **克隆/下载仓库**: 获取所有 `.v` (Verilog源文件) 和 `.xdc` (约束文件)。
2.  **创建工程**: 在Vivado中创建一个新工程，目标器件选择 **NEXYS 4 DDR**。
3.  **添加源文件**: 将所有 `.v` 文件添加到 "Design Sources"，将 `.xdc` 文件添加到 "Constraints"。
4.  **生成比特流**: 依次执行 "Run Synthesis" -> "Run Implementation" -> "Generate Bitstream"。
5.  **烧录并操作**:
    *   将生成的 `.bit` 文件烧录到开发板。
    *   **按下红色的 `CPU_RESETN` 按钮**进行系统初始化。
    *   参照上文的“主要功能”描述和“端口分配”进行操作。

## 🎥 效果演示 (Demonstration)

*  板子还回去了

## 👤 作者 (Author)

*  (https://github.com/Hasel152)
