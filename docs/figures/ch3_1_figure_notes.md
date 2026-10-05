# 第 3.1 节配图建议

## 主图

- 文件：`docs/figures/processor_overall_architecture_paper.svg`
- 建议图题：`图 3-1 处理器总体架构图`
- 建议放置位置：第 3.1 节第一段后，或第 3.1 节最后一段后

可直接对应正文中的这些描述：

- 处理器由处理器核心、指令存储模块、数据存储模块、总线桥接模块和 UART 外设模块构成
- 处理器核心采用五级流水线结构
- 核心内部集成分支预测、数据前递、CSR 控制和多周期乘除法单元
- UART 外设通过 AXI4-Lite 接口挂接在 MMIO 通路上

## 补充图

- 文件：`docs/figures/core_pipeline_architecture_paper.svg`
- 建议图题：`图 3-2 CPU 五级流水内部结构图`
- 建议用途：放在 3.2 节或讲解流水级、分支预测、前递机制的小节前

## 源文件

- `docs/figures/processor_overall_architecture.dot`
- `docs/figures/core_pipeline_architecture.dot`

如果后续需要改成黑白论文风格、英文版图题，或需要导出为 PNG/PDF，可以继续在这些文件基础上调整。

  绘制一张“RISC-V 处理器总体架构图”，用于毕业论文第 3.1 节后的系统结构图，风格为学术论文中的清晰矢量框图，白色背景，蓝灰色配色，布局简
  洁、对齐工整、线条清晰、适合 A4 论文排版。

  整体结构为一个顶层 SoC / Processor System 框图，中心是 CPU Core，外围包含：
  1. Instruction Memory
  2. Data Memory
  3. AXI4-Lite Bridge
  4. UART Peripheral

  CPU Core 内部需要明确包含这些模块：
  1. PC
  2. IF
  3. ID
  4. EX
  5. MEM/WB
  6. Register File
  7. ALU
  8. Branch Predictor
  9. CSR
  10. Mul/Div Unit

  图中要体现：
  - 五级流水结构：IF -> ID -> EX -> MEM -> WB
  - 指令通路：PC 到 Instruction Memory，再到 IF/ID
  - 数据通路：EX/MEM 到 Data Memory，再到 WB
  - 分支预测器与 PC、EX 的连接
  - Register File 与 ID、WB 的连接
  - ALU、Mul/Div Unit、CSR 与 EX 的连接
  - AXI4-Lite Bridge 位于 CPU 和 UART Peripheral 之间
  - UART Peripheral 再连接外部 UART RXD/TXD 引脚
  - 用箭头表示地址通路、数据通路、控制通路
  - 重点标出：address path、data path、control path、AXI4-Lite interface
  - 图风格专业、规整、工程论文风，不要卡通，不要 3D，不要装饰性背景

  文字标签要求：
  - 使用英文模块名为主，可在下方附中文小字
  - 标题为：Overall Processor Architecture
  - 图像比例横向，适合论文单栏或双栏插图
  - 所有模块边框统一、圆角矩形、层次分明

  如果你想要“更像论文图、少出错字”的版本

  Create a clean academic vector block diagram of a 5-stage pipelined RISC-V processor system for a thesis. White background, blue-
  gray engineering style, precise alignment, readable labels, horizontal layout.

  Main top-level blocks:
  CPU Core, Instruction Memory, Data Memory, AXI4-Lite Bridge, UART Peripheral, External UART RXD/TXD.

  Inside CPU Core:
  PC, IF, ID, EX, MEM/WB, Register File, ALU, Branch Predictor, CSR, Mul/Div Unit.

  Show clear arrows for:
  instruction path, data path, control path, branch prediction update path, PC redirection path, AXI4-Lite interface path.

  Emphasize:
  5-stage pipeline, branch prediction, register write-back, memory access, MMIO path to UART through AXI4-Lite bridge.

  Style:
  thesis-quality system architecture figure, vector diagram, clean typography, no artistic effects, no 3D, no icons, no shadow-heavy
  UI, no decorative background.
  Title: Overall Processor Architecture

  反向提示词

  no 3D, no photorealistic style, no futuristic HUD, no neon, no complex background, no glowing effects, no cartoon, no messy wiring,
  no extra modules, no distorted text


  绘制一张“RISC-V 处理器总体架构图”，用于毕业论文第 3.1 节后的系统结构图。风格为学术论文中的清晰矢量框图，白色背景，蓝灰色配色，线条规
  整，适合 A4 论文排版。

  该处理器系统不是独立的 Instruction Memory 和 Data Memory，而是“统一物理存储 + 分离访问接口”结构。请严格按照这一点出图。

  顶层模块包含：
  1. CPU Core
  2. Unified Banked Memory
  3. AXI4-Lite Bridge
  4. UART Peripheral
  5. External UART RXD/TXD

  其中 Unified Banked Memory 需要明确标注：
  - shared physical memory
  - instruction fetch interface
  - data access interface
  - banked BRAM organization

  CPU Core 内部包含：
  1. PC
  2. IF
  3. ID
  4. EX
  5. MEM/WB
  6. Register File
  7. ALU
  8. Branch Predictor
  9. CSR
  10. Mul/Div Unit

  图中必须体现以下关系：
  - PC 向 Unified Banked Memory 发出取指地址
  - Unified Banked Memory 通过 instruction fetch interface 向 IF 返回指令
  - EX/MEM 或 MEM/WB 通过 data access interface 访问 Unified Banked Memory
  - CPU 的数据访存请求中，RAM 地址访问 Unified Banked Memory
  - MMIO 地址访问走 AXI4-Lite Bridge，而不是进入 Unified Banked Memory
  - AXI4-Lite Bridge 连接 UART Peripheral
  - UART Peripheral 连接外部 UART RXD/TXD 引脚
  - Branch Predictor 与 PC、EX 相连，体现预测和更新
  - Register File 与 ID、WB 相连
  - ALU、Mul/Div Unit、CSR 与 EX 相连
  - 用箭头清楚区分 instruction path、data path、control path、MMIO path、AXI4-Lite path

  图的重点不是 Harvard 双存储器，而是：
  “共享物理存储器上的取指与数据访问分离，以及 UART 通过 AXI4-Lite 挂接在 MMIO 通路上”。

  文字要求：
  - 标题：Overall Processor Architecture
  - 模块名称用英文，必要时下方附中文小字
  - 横向布局
  - 不要画成两块完全独立的 Instruction Memory 和 Data Memory
  - 不要画成缓存系统
  - 不要 3D，不要发光，不要装饰背景，不要复杂电子风 UI


