#!/usr/bin/env python3
"""
Generate Vivado .coe files for banked memory from instruction/data HEX images.

Memory model follows std_bram_tdp initialization in this project:
1) load inst_bank*.hex
2) overlay bank*.hex (data section with address directives)

Input HEX supports:
- plain 32-bit words (one word per line)
- optional @<hex_addr> address directives
- '#' line comments
"""

import argparse
import os
import re
import sys
from typing import List


HEX_ADDR_RE = re.compile(r"^[0-9a-fA-F]+$")
HEX_WORD_RE = re.compile(r"^[0-9a-fA-F]{1,8}$")


def apply_hex_to_mem(path: str, mem: List[int], depth: int, required: bool = True) -> int:
    """Apply one hex file into mem[] using @address directives."""
    if not os.path.isfile(path):
        if required:
            raise FileNotFoundError(f"hex file not found: {path}")
        return 0

    addr = 0
    loaded = 0

    with open(path, "r", encoding="utf-8") as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue

            if line.startswith("@"):
                addr_token = line[1:].strip()
                if not HEX_ADDR_RE.fullmatch(addr_token):
                    raise ValueError(f"{path}:{lineno}: invalid address directive '{line}'")
                addr = int(addr_token, 16)
                if addr < 0 or addr >= depth:
                    raise ValueError(
                        f"{path}:{lineno}: address 0x{addr:x} out of range (depth={depth})"
                    )
                continue

            token = line.split()[0]
            if not HEX_WORD_RE.fullmatch(token):
                raise ValueError(f"{path}:{lineno}: invalid 32-bit hex word '{line}'")
            if addr < 0 or addr >= depth:
                raise ValueError(
                    f"{path}:{lineno}: write address 0x{addr:x} out of range (depth={depth})"
                )

            mem[addr] = int(token, 16) & 0xFFFFFFFF
            addr += 1
            loaded += 1

    return loaded


def write_coe(path: str, mem: List[int]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        last = len(mem) - 1
        for i, word in enumerate(mem):
            tail = ";" if i == last else ","
            f.write(f"{word:08x}{tail}\n")


def merge_and_emit(inst_hex: str, data_hex: str, out_coe: str, depth: int) -> None:
    mem = [0] * depth
    inst_words = apply_hex_to_mem(inst_hex, mem, depth, required=True)
    data_words = apply_hex_to_mem(data_hex, mem, depth, required=False)
    write_coe(out_coe, mem)
    print(
        f"[COE] {out_coe} generated (depth={depth}, inst_words={inst_words}, overlay_words={data_words})"
    )


def main() -> int:
    script_dir = os.path.dirname(os.path.abspath(__file__))

    parser = argparse.ArgumentParser(
        description="Generate merged bank0.coe/bank1.coe from inst_bank*.hex + bank*.hex"
    )
    parser.add_argument("--inst0", default=os.path.join(script_dir, "inst_bank0.hex"))
    parser.add_argument("--inst1", default=os.path.join(script_dir, "inst_bank1.hex"))
    parser.add_argument("--data0", default=os.path.join(script_dir, "bank0.hex"))
    parser.add_argument("--data1", default=os.path.join(script_dir, "bank1.hex"))
    parser.add_argument("--out0", default=os.path.join(script_dir, "bank0.coe"))
    parser.add_argument("--out1", default=os.path.join(script_dir, "bank1.coe"))
    parser.add_argument("--depth", type=int, default=8192, help="words per bank")
    args = parser.parse_args()

    if args.depth <= 0:
        print("Error: --depth must be > 0", file=sys.stderr)
        return 1

    try:
        merge_and_emit(args.inst0, args.data0, args.out0, args.depth)
        merge_and_emit(args.inst1, args.data1, args.out1, args.depth)
    except Exception as e:  # noqa: BLE001
        print(f"Error: {e}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
