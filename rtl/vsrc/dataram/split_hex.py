#!/usr/bin/env python3
"""
split_hex.py - 将 dataram.hex 分割为 Bank0 和 Bank1 的 hex 文件

用法:
    python3 split_hex.py dataram.hex

输出:
    bank0.hex - 偶数字 (Word 0, 2, 4, ...)
    bank1.hex - 奇数字 (Word 1, 3, 5, ...)

HEX 文件格式:
    每行一个 32 位十六进制数，无前缀
    例如: DEADBEEF
"""

import sys
import os

def split_hex(input_file, output_dir=None):
    """
    分割 hex 文件为奇偶两个 Bank

    Args:
        input_file: 输入的 hex 文件路径
        output_dir: 输出目录（默认为输入文件所在目录）
    """
    if output_dir is None:
        output_dir = os.path.dirname(input_file)
        if not output_dir:
            output_dir = '.'

    bank0_file = os.path.join(output_dir, 'bank0.hex')
    bank1_file = os.path.join(output_dir, 'bank1.hex')

    bank0_data = []
    bank1_data = []

    print(f"读取: {input_file}")

    with open(input_file, 'r') as f:
        lines = f.readlines()

    word_index = 0
    for line in lines:
        line = line.strip()

        # 跳过空行和注释
        if not line or line.startswith('//') or line.startswith('#'):
            continue

        # 处理 @address 格式（Verilog $readmemh 支持）
        if line.startswith('@'):
            # 解析地址，更新 word_index
            addr_str = line[1:].strip()
            word_index = int(addr_str, 16)

            # 填充 Bank 到指定地址
            bank0_target = word_index // 2
            bank1_target = word_index // 2

            while len(bank0_data) < bank0_target:
                bank0_data.append('00000000')
            while len(bank1_data) < bank1_target:
                bank1_data.append('00000000')

            continue

        # 提取十六进制数据
        # 可能的格式: "DEADBEEF" 或 "DEADBEEF // comment"
        hex_data = line.split()[0]

        # 验证是有效的十六进制
        try:
            int(hex_data, 16)
        except ValueError:
            print(f"警告: 跳过无效行: {line}")
            continue

        # 确保是 8 位十六进制（32位数据）
        hex_data = hex_data.zfill(8)[-8:]  # 取最后 8 位

        # 根据字地址分配到对应 Bank
        if word_index % 2 == 0:
            bank0_data.append(hex_data)
        else:
            bank1_data.append(hex_data)

        word_index += 1

    # 写入 Bank0
    with open(bank0_file, 'w') as f:
        for data in bank0_data:
            f.write(data + '\n')

    # 写入 Bank1
    with open(bank1_file, 'w') as f:
        for data in bank1_data:
            f.write(data + '\n')

    print(f"输出: {bank0_file} ({len(bank0_data)} 字)")
    print(f"输出: {bank1_file} ({len(bank1_data)} 字)")
    print(f"总计: {len(bank0_data) + len(bank1_data)} 字 = {(len(bank0_data) + len(bank1_data)) * 4} 字节")

def main():
    if len(sys.argv) < 2:
        print("用法: python3 split_hex.py <dataram.hex> [output_dir]")
        print("示例: python3 split_hex.py dataram.hex ./")
        sys.exit(1)

    input_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    if not os.path.exists(input_file):
        print(f"错误: 文件不存在: {input_file}")
        sys.exit(1)

    split_hex(input_file, output_dir)
    print("完成!")

if __name__ == '__main__':
    main()
