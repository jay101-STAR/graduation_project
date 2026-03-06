#!/usr/bin/env python3
"""
Unified banked memory image tool.

Subcommands:
  - split: split one word hex image into bank0/bank1.
  - merge: merge base/overlay hex into one sparse hex image.
  - init-instrom: build final bank0.hex/bank1.hex from instrom hex.
  - overlay-data: extract ELF .data and overlay into final bank hex files.
  - emit: generate bank*.coe/bank*.mem from final bank*.hex.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile
from typing import Dict, List, Tuple


HEX_ADDR_RE = re.compile(r"^[0-9a-fA-F]+$")
HEX_WORD_RE = re.compile(r"^[0-9a-fA-F]{1,8}$")


def _strip_comment(line: str) -> str:
    hash_idx = line.find("#")
    slash_idx = line.find("//")
    cut = len(line)
    if hash_idx != -1:
        cut = min(cut, hash_idx)
    if slash_idx != -1:
        cut = min(cut, slash_idx)
    return line[:cut].strip()


def _parse_hex_entries(path: str) -> List[Tuple[str, int, int]]:
    """
    Parse input hex file into entries:
      ("addr", lineno, addr_int)
      ("word", lineno, word_int)
    """
    entries: List[Tuple[str, int, int]] = []
    with open(path, "r", encoding="utf-8") as f:
        for lineno, raw in enumerate(f, 1):
            line = _strip_comment(raw)
            if not line:
                continue

            if line.startswith("@"):
                token = line[1:].strip()
                if not HEX_ADDR_RE.fullmatch(token):
                    raise ValueError(f"{path}:{lineno}: invalid address directive '{line}'")
                entries.append(("addr", lineno, int(token, 16)))
                continue

            token = line.split()[0]
            if not HEX_WORD_RE.fullmatch(token):
                raise ValueError(f"{path}:{lineno}: invalid 32-bit hex word '{line}'")
            entries.append(("word", lineno, int(token, 16) & 0xFFFFFFFF))
    return entries


def _parse_int_auto_base(raw: str) -> int:
    try:
        return int(raw, 0)
    except ValueError as e:
        raise argparse.ArgumentTypeError(str(e)) from e


def split_hex_to_banks(
    input_path: str,
    bank0_path: str,
    bank1_path: str,
    start_addr: int = 0,
    sparse: bool = True,
) -> Tuple[int, int]:
    """
    Split word image into bank files.

    sparse=True:
      - output with @bank_addr directives
    sparse=False:
      - output dense plain words
    """
    entries = _parse_hex_entries(input_path)
    os.makedirs(os.path.dirname(bank0_path) or ".", exist_ok=True)
    os.makedirs(os.path.dirname(bank1_path) or ".", exist_ok=True)

    if sparse:
        with open(bank0_path, "w", encoding="utf-8") as b0, open(
            bank1_path, "w", encoding="utf-8"
        ) as b1:
            word_addr = start_addr
            bank0_next = -1
            bank1_next = -1
            bank0_words = 0
            bank1_words = 0

            for kind, _lineno, value in entries:
                if kind == "addr":
                    word_addr = value
                    continue

                bank_addr = word_addr >> 1
                word_hex = f"{value:08x}"

                if (word_addr & 1) == 0:
                    if bank0_next != bank_addr:
                        b0.write(f"@{bank_addr:x}\n")
                        bank0_next = bank_addr
                    b0.write(f"{word_hex}\n")
                    bank0_next += 1
                    bank0_words += 1
                else:
                    if bank1_next != bank_addr:
                        b1.write(f"@{bank_addr:x}\n")
                        bank1_next = bank_addr
                    b1.write(f"{word_hex}\n")
                    bank1_next += 1
                    bank1_words += 1
                word_addr += 1

        return bank0_words, bank1_words

    bank0_data: List[int] = []
    bank1_data: List[int] = []
    word_addr = start_addr

    for kind, _lineno, value in entries:
        if kind == "addr":
            word_addr = value
            continue

        bank_addr = word_addr >> 1
        if (word_addr & 1) == 0:
            while len(bank0_data) < bank_addr:
                bank0_data.append(0)
            if len(bank0_data) == bank_addr:
                bank0_data.append(value)
            else:
                bank0_data[bank_addr] = value
        else:
            while len(bank1_data) < bank_addr:
                bank1_data.append(0)
            if len(bank1_data) == bank_addr:
                bank1_data.append(value)
            else:
                bank1_data[bank_addr] = value
        word_addr += 1

    with open(bank0_path, "w", encoding="utf-8") as b0:
        for word in bank0_data:
            b0.write(f"{word:08x}\n")
    with open(bank1_path, "w", encoding="utf-8") as b1:
        for word in bank1_data:
            b1.write(f"{word:08x}\n")
    return len(bank0_data), len(bank1_data)


def apply_hex_to_dict(path: str, mem: Dict[int, int], required: bool = True) -> int:
    if not path:
        return 0
    if not os.path.isfile(path):
        if required:
            raise FileNotFoundError(f"hex file not found: {path}")
        return 0

    addr = 0
    loaded = 0
    for kind, _lineno, value in _parse_hex_entries(path):
        if kind == "addr":
            addr = value
            continue
        mem[addr] = value & 0xFFFFFFFF
        addr += 1
        loaded += 1
    return loaded


def write_sparse_hex(path: str, mem: Dict[int, int]) -> int:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    if not mem:
        with open(path, "w", encoding="utf-8"):
            pass
        return 0

    addrs = sorted(mem.keys())
    written = 0
    prev = None
    with open(path, "w", encoding="utf-8") as f:
        for addr in addrs:
            if prev is None or addr != (prev + 1):
                f.write(f"@{addr:x}\n")
            f.write(f"{mem[addr] & 0xFFFFFFFF:08x}\n")
            prev = addr
            written += 1
    return written


def merge_hex_images(
    base_path: str,
    overlay_path: str,
    out_path: str,
    base_required: bool = False,
) -> Tuple[int, int, int]:
    mem: Dict[int, int] = {}
    base_words = apply_hex_to_dict(base_path, mem, required=base_required)
    overlay_words = apply_hex_to_dict(overlay_path, mem, required=False)
    written_words = write_sparse_hex(out_path, mem)
    return base_words, overlay_words, written_words


def _ensure_file(path: str) -> None:
    if not os.path.isfile(path):
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        with open(path, "w", encoding="utf-8"):
            pass


def _find_data_addr(elf_file: str) -> int | None:
    proc = subprocess.run(
        ["riscv32-unknown-elf-readelf", "-S", elf_file],
        check=True,
        capture_output=True,
        text=True,
    )
    for line in proc.stdout.splitlines():
        if ".data" in line and "PROGBITS" in line:
            m = re.search(r"\.data\s+PROGBITS\s+([0-9a-fA-F]+)", line)
            if m:
                return int(m.group(1), 16)
    return None


def _extract_data_words(elf_file: str) -> List[int]:
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        tmp_bin = tmp.name
    try:
        subprocess.run(
            ["riscv32-unknown-elf-objcopy", "-O", "binary", "-j", ".data", elf_file, tmp_bin],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if not os.path.isfile(tmp_bin):
            return []
        with open(tmp_bin, "rb") as f:
            data = f.read()
        if not data:
            return []

        words: List[int] = []
        for i in range(0, len(data), 4):
            chunk = data[i : i + 4]
            if len(chunk) < 4:
                chunk = chunk + b"\x00" * (4 - len(chunk))
            words.append(int.from_bytes(chunk, byteorder="little", signed=False))
        return words
    finally:
        try:
            os.remove(tmp_bin)
        except OSError:
            pass


def init_from_instrom(instrom_hex: str, out_dir: str) -> Tuple[int, int]:
    os.makedirs(out_dir, exist_ok=True)
    bank0_path = os.path.join(out_dir, "bank0.hex")
    bank1_path = os.path.join(out_dir, "bank1.hex")
    return split_hex_to_banks(instrom_hex, bank0_path, bank1_path, start_addr=0, sparse=True)


def overlay_data_from_elf(elf_file: str, out_dir: str, base_addr: int) -> Tuple[int, int]:
    os.makedirs(out_dir, exist_ok=True)
    bank0_path = os.path.join(out_dir, "bank0.hex")
    bank1_path = os.path.join(out_dir, "bank1.hex")
    _ensure_file(bank0_path)
    _ensure_file(bank1_path)

    data_addr = _find_data_addr(elf_file)
    if data_addr is None:
        print(f"Warning: No .data section found in {elf_file}, keep existing bank hex files")
        return 0, 0

    word_offset = (data_addr - base_addr) // 4
    print(f"Data section address: 0x{data_addr:08x} (word offset: {word_offset})")

    words = _extract_data_words(elf_file)
    if not words:
        print(f"Warning: .data section is empty in {elf_file}, keep existing bank hex files")
        return 0, 0

    with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as tmp_hex:
        tmp_hex_path = tmp_hex.name
        for w in words:
            tmp_hex.write(f"{w:08x}\n")
    with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as tmp_b0:
        tmp_b0_path = tmp_b0.name
    with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as tmp_b1:
        tmp_b1_path = tmp_b1.name

    try:
        b0_words, b1_words = split_hex_to_banks(
            input_path=tmp_hex_path,
            bank0_path=tmp_b0_path,
            bank1_path=tmp_b1_path,
            start_addr=word_offset,
            sparse=True,
        )
        merge_hex_images(base_path=bank0_path, overlay_path=tmp_b0_path, out_path=bank0_path)
        merge_hex_images(base_path=bank1_path, overlay_path=tmp_b1_path, out_path=bank1_path)
    finally:
        for p in (tmp_hex_path, tmp_b0_path, tmp_b1_path):
            try:
                os.remove(p)
            except OSError:
                pass

    print("Data section extracted to:")
    print(f"  Overlay Bank0 words: {b0_words}")
    print(f"  Overlay Bank1 words: {b1_words}")
    print(f"  Final Bank0: {bank0_path}")
    print(f"  Final Bank1: {bank1_path}")
    print(f"Total size: {len(words)} words ({len(words) * 4} bytes)")
    print(f"Loaded at word address: {word_offset} (physical: 0x{data_addr:08x})")
    return b0_words, b1_words


def apply_hex_to_mem(path: str, mem: List[int], depth: int, required: bool = True) -> int:
    if not os.path.isfile(path):
        if required:
            raise FileNotFoundError(f"hex file not found: {path}")
        return 0

    addr = 0
    loaded = 0
    for kind, lineno, value in _parse_hex_entries(path):
        if kind == "addr":
            addr = value
            if addr < 0 or addr >= depth:
                raise ValueError(f"{path}:{lineno}: address 0x{addr:x} out of range (depth={depth})")
            continue
        if addr < 0 or addr >= depth:
            raise ValueError(
                f"{path}:{lineno}: write address 0x{addr:x} out of range (depth={depth})"
            )
        mem[addr] = value & 0xFFFFFFFF
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


def write_mem(path: str, mem: List[int]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        for word in mem:
            f.write(f"{word:08x}\n")


def emit_artifacts_from_final_hex(
    hex0: str,
    hex1: str,
    out0: str,
    out1: str,
    outmem0: str,
    outmem1: str,
    depth: int,
) -> Tuple[int, int]:
    mem0 = [0] * depth
    mem1 = [0] * depth
    words0 = apply_hex_to_mem(hex0, mem0, depth, required=True)
    words1 = apply_hex_to_mem(hex1, mem1, depth, required=True)
    write_coe(out0, mem0)
    write_coe(out1, mem1)
    write_mem(outmem0, mem0)
    write_mem(outmem1, mem1)
    return words0, words1


def _build_parser(script_dir: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Unified banked memory image helper")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_split = sub.add_parser("split", help="split one word hex image into bank0/bank1")
    p_split.add_argument("--input", required=True, help="input word hex")
    p_split.add_argument("--bank0", required=True, help="bank0 output path")
    p_split.add_argument("--bank1", required=True, help="bank1 output path")
    p_split.add_argument(
        "--start-addr",
        type=_parse_int_auto_base,
        default=0,
        help="word start address offset (default: 0)",
    )
    p_split.add_argument("--dense", action="store_true", help="dense output without @address")

    p_merge = sub.add_parser("merge", help="merge base/overlay hex into one image")
    p_merge.add_argument("--base", default="", help="base image path (optional)")
    p_merge.add_argument("--overlay", default="", help="overlay image path (optional)")
    p_merge.add_argument("--output", required=True, help="merged output hex path")
    p_merge.add_argument(
        "--base-required",
        action="store_true",
        help="treat missing --base file as error",
    )

    p_init = sub.add_parser("init-instrom", help="build final bank*.hex from instrom hex")
    p_init.add_argument(
        "--instrom",
        default=os.path.join(script_dir, "../instrom/instrom.hex"),
        help="instrom hex path",
    )
    p_init.add_argument("--out-dir", default=script_dir, help="output dataram directory")

    p_overlay = sub.add_parser("overlay-data", help="overlay ELF .data into final bank*.hex")
    p_overlay.add_argument("--elf", required=True, help="ELF path")
    p_overlay.add_argument("--out-dir", default=script_dir, help="output dataram directory")
    p_overlay.add_argument(
        "--base-addr",
        type=_parse_int_auto_base,
        default=0x80000000,
        help="base address for word offset (default: 0x80000000)",
    )

    p_emit = sub.add_parser("emit", help="generate bank*.coe/bank*.mem from final bank*.hex")
    p_emit.add_argument("--dir", default=script_dir, help="dataram directory")
    p_emit.add_argument("--depth", type=int, default=8192, help="words per bank")

    return parser


def main() -> int:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parser = _build_parser(script_dir)
    args = parser.parse_args()

    try:
        if args.cmd == "split":
            bank0_words, bank1_words = split_hex_to_banks(
                input_path=args.input,
                bank0_path=args.bank0,
                bank1_path=args.bank1,
                start_addr=args.start_addr,
                sparse=not args.dense,
            )
            mode = "dense" if args.dense else "sparse"
            print(
                f"[split:{mode}] bank0={args.bank0} ({bank0_words} words), "
                f"bank1={args.bank1} ({bank1_words} words)"
            )
            return 0

        if args.cmd == "merge":
            if not args.base and not args.overlay:
                print("Error: merge needs at least one of --base or --overlay", file=sys.stderr)
                return 1
            base_words, overlay_words, written_words = merge_hex_images(
                base_path=args.base,
                overlay_path=args.overlay,
                out_path=args.output,
                base_required=args.base_required,
            )
            print(
                f"[merge] output={args.output} "
                f"(base_words={base_words}, overlay_words={overlay_words}, written_words={written_words})"
            )
            return 0

        if args.cmd == "init-instrom":
            b0, b1 = init_from_instrom(args.instrom, args.out_dir)
            print(
                f"[init-instrom] out_dir={args.out_dir} "
                f"(bank0_words={b0}, bank1_words={b1})"
            )
            return 0

        if args.cmd == "overlay-data":
            b0, b1 = overlay_data_from_elf(args.elf, args.out_dir, args.base_addr)
            print(
                f"[overlay-data] out_dir={args.out_dir} "
                f"(bank0_overlay_words={b0}, bank1_overlay_words={b1})"
            )
            return 0

        if args.cmd == "emit":
            if args.depth <= 0:
                print("Error: --depth must be > 0", file=sys.stderr)
                return 1
            bank0_hex = os.path.join(args.dir, "bank0.hex")
            bank1_hex = os.path.join(args.dir, "bank1.hex")
            bank0_coe = os.path.join(args.dir, "bank0.coe")
            bank1_coe = os.path.join(args.dir, "bank1.coe")
            bank0_mem = os.path.join(args.dir, "bank0.mem")
            bank1_mem = os.path.join(args.dir, "bank1.mem")
            w0, w1 = emit_artifacts_from_final_hex(
                bank0_hex, bank1_hex, bank0_coe, bank1_coe, bank0_mem, bank1_mem, args.depth
            )
            print(
                f"[emit] dir={args.dir} depth={args.depth} "
                f"(bank0_loaded_words={w0}, bank1_loaded_words={w1})"
            )
            return 0

        parser.print_help()
        return 1
    except Exception as e:  # noqa: BLE001
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
