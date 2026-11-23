#!/usr/bin/env python3
"""Check completed AXI writes in a CPU VCD, including W arriving before AW."""
import json
from pathlib import Path
import sys


def inspect(path):
    wanted = ["sync_rst", "bridge_axi_awvalid", "axi_bridge_awready", "bridge_axi_awaddr",
              "bridge_axi_awlen", "bridge_axi_wvalid", "axi_bridge_wready", "bridge_axi_wlast",
              "axi_bridge_bvalid", "bridge_axi_bready", "axi_bridge_bresp"]
    names, scope, values, changes = {}, [], {}, {}
    address, length, beats, last = None, None, 0, False
    completed, bursts, cycle = 0, [], 0
    first_w, aw_cycle = None, None

    def sample():
        nonlocal address, length, beats, last, completed, cycle, first_w, aw_cycle
        cycle += 1
        def v(name):
            return values.get(names[name], 0)
        if v("sync_rst"):
            address, length, beats, last, first_w, aw_cycle = None, None, 0, False, None, None
            return
        if v("axi_bridge_bvalid") and v("bridge_axi_bready"):
            assert address is not None, "B without AW"
            assert beats == length + 1 and last, f"write length/LAST: {beats}/{length}"
            assert v("axi_bridge_bresp") == 0, "write returned an error"
            completed += 1
            if length == 15:
                bursts.append({"address": hex(address), "AWLEN": length, "W_beats": beats,
                               "aw_cycle": aw_cycle, "first_w_cycle": first_w, "b_cycle": cycle})
            address, length, beats, last, first_w, aw_cycle = None, None, 0, False, None, None
        if v("bridge_axi_awvalid") and v("axi_bridge_awready"):
            assert address is None, "another AW before B"
            address, length, aw_cycle = v("bridge_axi_awaddr"), v("bridge_axi_awlen"), cycle
            assert length in (0, 15), "unsupported AWLEN"
        if v("bridge_axi_wvalid") and v("axi_bridge_wready"):
            assert not last, "W after LAST before B"
            if first_w is None:
                first_w = cycle
            beats += 1
            last = bool(v("bridge_axi_wlast"))

    def flush():
        if changes.get(names["clk"]) == 1 and values.get(names["clk"], 0) == 0:
            sample()
        values.update(changes)
        changes.clear()

    with Path(path).open() as stream:
        for line in stream:
            tokens = line.split()
            if not tokens:
                continue
            if tokens[0] == "$scope":
                scope.append(tokens[2])
            elif tokens[0] == "$upscope":
                scope.pop()
            elif tokens[0] == "$var":
                where = ".".join(scope)
                if where == "TOP.testbench.top" and tokens[4] in wanted:
                    names[tokens[4]] = tokens[3]
                elif where == "TOP.testbench" and tokens[4] == "clk":
                    names["clk"] = tokens[3]
            elif tokens[0] == "$enddefinitions":
                break
        assert len(names) == len(wanted) + 1, "missing CPU AXI signals"
        tracked = set(names.values())
        for line in stream:
            text = line.strip()
            if text.startswith("#"):
                flush()
            elif text and text[0] in "01" and text[1:] in tracked:
                changes[text[1:]] = int(text[0])
            elif text.startswith("b"):
                number, name = text[1:].split()
                if name in tracked and set(number) <= {"0", "1"}:
                    changes[name] = int(number, 2)
        flush()
    assert bursts, "no completed 16-beat write found"
    return {"wave": str(path), "completed_writes": completed,
            "completed_write_bursts": len(bursts), "bursts": bursts,
            "pending_at_end": address is not None or beats != 0}


if __name__ == "__main__":
    wave = Path(sys.argv[1])
    result = inspect(wave)
    wave.with_suffix(".writes.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
