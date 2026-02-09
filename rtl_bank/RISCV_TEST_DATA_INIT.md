# RISC-V Tests 数据内存初始化指南

## 问题背景

RISC-V官方测试套件（riscv-tests）中的某些测试需要预初始化的数据内存。这些测试的ELF文件包含 `.data` 段，需要在仿真开始前加载到数据内存中。

## 解决方案概述

我们采用类似 `instrom.v` 的方法，使用 `$readmemh` 从hex文件加载数据段到 `dataram.v` 中。

### 关键文件

1. **extract_data.sh** - 从ELF文件提取 `.data` 段并转换为hex格式
2. **prepare_test.sh** - 自动化脚本，同时准备指令和数据内存
3. **dataram.v** - 修改后支持从 `dataram.hex` 加载初始数据

## 使用方法

### 方法1：使用自动化脚本（推荐）

```bash
# 从项目根目录运行
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-lw

# 然后编译和运行仿真
cd rtl
make comp
```

### 方法2：手动步骤

```bash
cd rtl/vsrc/instrom

# 1. 提取指令内存
riscv32-unknown-elf-objcopy -O binary -j .text.init \
    ../../../verification/riscv-tests/isa/rv32ui-p-lw instrom.bin
hexdump -v -e '1/4 "%08x\n"' instrom.bin > instrom.hex

# 2. 提取数据内存
./extract_data.sh ../../../verification/riscv-tests/isa/rv32ui-p-lw dataram.hex

# 3. 编译和运行
cd ../..
make comp
```

## 工作原理

### 地址映射

RISC-V测试使用以下内存布局：
- **指令内存**: `0x80000000` - `0x80001FFF` (8KB)
- **数据内存**: `0x80002000` - `0x80009FFF` (32KB)

在 `dataram.v` 中：
- 数据段起始地址 `0x80002000`
- 相对于基地址 `0x80000000` 的偏移为 `0x2000`
- 字地址偏移 = `0x2000 / 4 = 2048`
- 因此 `$readmemh` 从 `mem[2048]` 开始加载

### dataram.hex 格式

hex文件格式为每行一个32位字（小端序）：
```
00ff00ff
ff00ff00
0ff00ff0
f00ff00f
```

这些数据会被加载到：
- `mem[2048]` = `0x00ff00ff` (地址 `0x80002000`)
- `mem[2049]` = `0xff00ff00` (地址 `0x80002004`)
- `mem[2050]` = `0x0ff00ff0` (地址 `0x80002008`)
- `mem[2051]` = `0xf00ff00f` (地址 `0x8000200c`)

## 测试示例

### 有数据段的测试
```bash
# Load/Store 测试
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-lw
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-sw
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-lh
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-sh
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-lb
./rtl/prepare_test.sh verification/riscv-tests/isa/rv32ui-p-sb
```

### 无数据段的测试
对于没有 `.data` 段的测试（如 `rv32ui-p-add`），脚本会创建一个空的 `dataram.hex` 文件，不会影响仿真。

## 注意事项

1. **文件路径**: `dataram.v` 中的hex文件路径是绝对路径，如果移动项目需要更新
2. **内存大小**: 当前数据内存大小为 8192 words (32KB)，足够大多数测试使用
3. **$readmemh 行为**: 如果hex文件不存在或为空，`$readmemh` 会静默失败，内存保持全零初始化

## 故障排除

### 问题：仿真时数据读取错误
- 检查 `dataram.hex` 是否存在且内容正确
- 确认测试的 `.data` 段地址是否为 `0x80002000`
- 使用 `readelf -S <test_elf>` 查看段信息

### 问题：extract_data.sh 报错
- 确认已安装 `riscv32-unknown-elf-objcopy`
- 检查ELF文件路径是否正确
- 某些测试可能没有 `.data` 段，这是正常的

## 扩展

如果需要支持不同的数据段地址，可以修改 `dataram.v` 中的加载偏移量，或者让脚本自动计算偏移。
