import sys

def txt_to_coe(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            # 读取所有行，去掉空白字符
            lines = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: 找不到文件 {input_file}")
        return

    with open(output_file, 'w') as f:
        # 1. 写入 Vivado COE 标准头
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        
        # 2. 写入数据
        total_lines = len(lines)
        for i, line in enumerate(lines):
            # 确保每行都是 8 个字符 (32-bit)，如果不足补前导0
            formatted_line = line.zfill(8)
            
            # 最后一行用分号，其他用逗号
            if i == total_lines - 1:
                f.write(f"{formatted_line};\n")
            else:
                f.write(f"{formatted_line},\n")

    print(f"转换成功！")
    print(f"源文件: {input_file} ({total_lines} 行)")
    print(f"目标文件: {output_file}")
    # 打印前几行预览
    print(f"预览前3行:\n" + "\n".join(lines[:3]))

if __name__ == "__main__":
    # 如果没有命令行参数，默认读取 hex.txt 输出 init.coe
    input_f = sys.argv[1] if len(sys.argv) > 1 else "hex.txt"
    output_f = sys.argv[2] if len(sys.argv) > 2 else "init.coe"
    txt_to_coe(input_f, output_f)
