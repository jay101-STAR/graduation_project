#!/usr/bin/env python3
"""Check AXI read/write overlap and beat counts from CPU or cache-bus VCDs."""
import argparse
import json
from pathlib import Path


def inspect(path, scope="TOP.testbench.top"):
    cpu = scope == "TOP.testbench.top"
    signals = {"clk": "clk", "rst": "sync_rst" if cpu else "rst"}
    for channel, fields in {"ar": ("valid", "ready", "addr", "len"),
                            "r": ("valid", "ready", "last", "resp"),
                            "aw": ("valid", "ready", "addr", "len"),
                            "w": ("valid", "ready", "last"),
                            "b": ("valid", "ready", "resp")}.items():
        master_outputs = {"ar": {"valid", "addr", "len"}, "r": {"ready"},
                          "aw": {"valid", "addr", "len"}, "w": {"valid", "last"},
                          "b": {"ready"}}
        for field in fields:
            prefix = ("bridge_axi_" if field in master_outputs[channel] else "axi_bridge_") if cpu else "m_axi_"
            signals[channel + field] = prefix + channel + field
    for name in ("req_valid", "req_ready", "rsp_valid", "rsp_ready", "rsp_last"):
        signals[name] = ("word_s_" if cpu else "s_") + name
    names, nesting, values, changes = {}, [], {}, {}
    cycle, read, write, wbeats, wlast, i_pending = 0, None, None, 0, False, False
    overlap, i_overlap, rw_beats, rb_responses, reads, writes, bursts = 0, 0, 0, 0, 0, 0, 0
    first_overlap = None

    def sample():
        nonlocal cycle, read, write, wbeats, wlast, i_pending
        nonlocal overlap, i_overlap, rw_beats, rb_responses, reads, writes, bursts, first_overlap
        cycle += 1
        def v(key):
            return values.get(names[key], 0)
        def fire(channel):
            return v(channel + "valid") and v(channel + "ready")
        if v("rst"):
            read, write, wbeats, wlast, i_pending = None, None, 0, False, False
            return
        if read and (write or wbeats):
            overlap += 1
            if i_pending:
                i_overlap += 1
                if first_overlap is None:
                    first_overlap = {"cycle": cycle, "read_addr": hex(read["addr"]),
                                     "write_addr": hex(write["addr"]) if write else None}
        if fire("r") and fire("w"):
            rw_beats += 1
        if fire("r") and fire("b"):
            rb_responses += 1
        if fire("r"):
            assert read is not None, "R without AR"
            assert v("rresp") == 0, "AXI read error"
            assert bool(v("rlast")) == (read["beats"] == read["len"]), "RLAST/count"
            read["beats"] += 1
            if v("rlast"):
                read = None
                reads += 1
        if fire("b"):
            assert write is not None and wlast and wbeats == write["len"] + 1, "B/AW/W count"
            assert v("bresp") == 0, "AXI write error"
            writes += 1
            bursts += write["len"] == 15
            write, wbeats, wlast = None, 0, False
        if fire("ar"):
            assert read is None, "second outstanding read"
            read = {"addr": v("araddr"), "len": v("arlen"), "beats": 0}
        if fire("aw"):
            assert write is None, "second outstanding write"
            write = {"addr": v("awaddr"), "len": v("awlen")}
        if fire("w"):
            assert not wlast, "W after LAST"
            wbeats += 1
            wlast = bool(v("wlast"))
        if v("rsp_valid") & v("rsp_ready") & v("rsp_last") & 1:
            i_pending = False
        if v("req_valid") & v("req_ready") & 1:
            i_pending = True

    def flush():
        if changes.get(names["clk"]) == 1 and values.get(names["clk"], 0) == 0:
            sample()
        values.update(changes)
        changes.clear()

    with Path(path).open() as stream:
        for line in stream:
            t = line.split()
            if not t:
                continue
            if t[0] == "$scope":
                nesting.append(t[2])
            elif t[0] == "$upscope":
                nesting.pop()
            elif t[0] == "$var":
                where = ".".join(nesting)
                for key, name in signals.items():
                    target = scope
                    if cpu and key == "clk":
                        target = scope.rsplit(".", 1)[0]
                    elif cpu and name.startswith("word_s_"):
                        target = scope + ".u_core"
                    if where == target and t[4] == name:
                        names[key] = t[3]
            elif t[0] == "$enddefinitions":
                break
        assert names.keys() == signals.keys(), f"missing signals: {signals.keys() - names.keys()}"
        tracked = set(names.values())
        for line in stream:
            line = line.strip()
            if line.startswith("#"):
                flush()
            elif line and line[0] in "01" and line[1:] in tracked:
                changes[line[1:]] = int(line[0])
            elif line.startswith("b"):
                number, name = line[1:].split()
                if name in tracked and set(number) <= {"0", "1"}:
                    changes[name] = int(number, 2)
        flush()
    assert overlap > 0 and i_overlap > 0 and bursts > 0, "no ICache-read / DCache-write burst overlap"
    return {"wave": str(path), "completed_reads": reads, "completed_writes": writes,
            "completed_write_bursts": bursts, "axi_overlap_cycles": overlap,
            "icache_read_dcache_write_cycles": i_overlap, "simultaneous_RW_beats": rw_beats,
            "simultaneous_RB": rb_responses, "first_overlap": first_overlap,
            "read_pending_at_end": read is not None, "write_pending_at_end": write is not None or wbeats != 0}


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("wave", type=Path)
    cli.add_argument("--scope", default="TOP.testbench.top")
    args = cli.parse_args()
    result = inspect(args.wave, args.scope)
    args.wave.with_suffix(".parallel.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
