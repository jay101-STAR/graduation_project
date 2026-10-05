"""Exercise runner orchestration without requiring a simulator license."""

from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import time
import unittest


SOURCE = Path(__file__).resolve().parents[1]


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="runner-tests-")
        self.addCleanup(self.temp.cleanup)
        self.project = Path(self.temp.name)
        self.rtl = self.project / "rtl"
        self.inst = self.rtl / "vsrc/instrom"
        self.data = self.rtl / "vsrc/dataram"
        self.bin = self.project / "bin"
        for path in (self.inst / "bp_tests", self.inst / "minstret_tests", self.data,
                     self.rtl / "tools", self.bin):
            path.mkdir(parents=True, exist_ok=True)
        shutil.copy(SOURCE / "run.sh", self.rtl / "run.sh")
        shutil.copy(SOURCE / "tools/run.py", self.rtl / "tools/run.py")
        self.images = [self.inst / "instrom.hex"] + [self.data / f"bank{bank}.{suffix}"
                       for bank in (0, 1) for suffix in ("hex", "coe", "mem")]
        for path in self.images:
            path.write_text(f"original {path.name}\n")
        self.before = {p: p.read_bytes() for p in self.images}
        isa = self.project / "verification/riscv-tests/isa"
        isa.mkdir(parents=True)
        for name in ("rv32ui-p-add", "rv32ui-p-fence_i", "rv32ui-p-bad"):
            (isa / name).write_text("mock ELF")
        (isa / "rv32ui-p-add.dump").write_text("not an ELF")
        for name in ("uart_tx_smoke_test", "uart_tx_back_to_back_test", "uart_loopback_echo_test",
                     "uart_rx_smoke_test", "uart_rx_double_read_test", "uart_rx_overrun_test"):
            (self.inst / f"{name}.s").write_text("assembly")
        (self.inst / "bp_tests/bp_tntn.s").write_text("assembly")
        (self.inst / "minstret_tests/minstret_basic.s").write_text("assembly")
        bench = self.project / "verification/riscv-tests/benchmarks/rv32im_build/output"
        bench.mkdir(parents=True)
        (bench / "multiply.hex").write_text("00000013\n")
        core = self.project / "verification/coremark"
        core.mkdir(parents=True)
        (core / "core_main.c").write_text("list_known_crc[] = {0xd4b0};\n"
                                          "matrix_known_crc[] = {0xbe52};\n"
                                          "state_known_crc[] = {0x5e47};\n")
        self.write(self.bin / "riscv32-unknown-elf-objcopy", '''#!/usr/bin/env python3
import sys
from pathlib import Path
if "bad" in Path(sys.argv[-2]).name: sys.exit(1)
Path(sys.argv[-1]).write_bytes(bytes([0x13, 0, 0, 0, 0x41]))
''')
        self.write(self.bin / "riscv32-unknown-elf-gcc", '''#!/usr/bin/env python3
import sys
from pathlib import Path
Path(sys.argv[sys.argv.index("-o") + 1]).write_text("mock ELF")
''')
        self.write(self.bin / "riscv32-unknown-elf-nm", '''#!/usr/bin/env python3
print("80000010 T start_time\\n80000020 T stop_time")
''')
        self.write(self.data / "mem_image_tool.py", '''#!/usr/bin/env python3
from pathlib import Path
import os, sys
root = Path(__file__).parent
if os.environ.get("PREP_FAIL") and sys.argv[1] == "emit": sys.exit(1)
for bank in (0, 1):
    for suffix in ("hex", "coe", "mem"):
        (root / f"bank{bank}.{suffix}").write_text("prepared " + sys.argv[1])
''')
        for helper in ("llvm.sh", "asm2hex.sh"):
            self.write(self.inst / helper, '''#!/bin/bash
python3 - "$1" <<'PY'
from pathlib import Path
import sys
Path(sys.argv[1]).with_suffix('.hex').write_text('00000013\\n')
PY
''')
        self.simulator = '''#!/usr/bin/env python3
from pathlib import Path
import json, os, sys, time
with open("trace.jsonl", "a") as f:
    f.write(json.dumps({"args": sys.argv[1:], "image": Path("vsrc/instrom/instrom.hex").read_text()}) + "\\n")
if os.environ.get("SLOW"): time.sleep(30)
if os.environ.get("LICENSE_FAIL"):
    print("Cannot connect to the license server."); sys.exit(1)
text = "TEST PASSED\\n[PERF] mcycle=100 minstret=50 cpi=2.0000\\n"
if not os.environ.get("NO_BP"):
    text += "[BP] branches=10 mispredict=2 target_miss=1\\n"
if any(a.startswith("+perf_start_pc=") for a in sys.argv):
    text += "seedcrc : 0x8a02\\n[0]crclist : 0xd4b0\\n[0]crcmatrix : 0xbe52\\n[0]crcstate : 0x5e47\\n"
    text += "[PERF-REGION] mcycle=100 minstret=50\\n[STALL-REGION] mem=10 mul=10 div=10 load_use=10 unstalled=60 redirects=2\\n"
    if os.environ.get("BAD_CRC"): text = text.replace("0xd4b0", "0x0000")
if os.environ.get("TEST_FAIL"): text = text.replace("TEST PASSED", "TEST FAILED tohost = 2")
print(text)
Path("sim.log").write_text(text)
'''
        self.write(self.rtl / "simv", self.simulator)
        self.write(self.bin / "make", '''#!/usr/bin/env python3
from pathlib import Path
import os, sys
Path("build_called").write_text(" ".join(sys.argv[1:]))
sys.exit(int(os.environ.get("BUILD_FAIL", "0")))
''')
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}")
        for key in ("SKIP_TEST_REGEX", "SKIP_BUILD", "SIM_ARGS", "SIM_TIMEOUT", "ITERATIONS",
                    "BP_TIMEOUT_NS", "BP_WALL_TIMEOUT_S", "UART_PRINT", "CORE_FREQ_HZ", "TB_TIMEOUT_NS"):
            self.env.pop(key, None)

    def write(self, path, content):
        path.write_text(content)
        path.chmod(0o755)

    def run_cli(self, *args, **env):
        return subprocess.run([str(self.rtl / "run.sh"), *args], cwd=self.project,
                              env=dict(self.env, **env), capture_output=True, text=True, timeout=10)

    def assert_restored(self):
        self.assertEqual(self.before, {p: p.read_bytes() for p in self.images})

    def test_help_and_list_do_not_build_or_change_images(self):
        for args in (("--help",), ("uart", "--list"), ("coremark", "--help")):
            self.assertEqual(self.run_cli(*args).returncode, 0)
        self.assertFalse((self.rtl / "test_results").exists())
        self.assert_restored()

    def test_all_reuses_uart_cases_and_records_exclusions(self):
        result = self.run_cli("all", "rv32ui-p-*", "--skip-fencei", "--no-build")
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)  # bad conversion fails
        self.assertIn("Total: 9", result.stdout)
        self.assertIn("Pass: 7", result.stdout)
        self.assertIn("Skip: 1", result.stdout)
        self.assertIn("Fail: 1", result.stdout)
        self.assertIn("Weighted CPI: 2.0000", result.stdout)
        self.assert_restored()

    def test_filtered_uart_bp_perf_minstr_and_benchmark(self):
        for args in (("uart", "--test", "uart_rx_double"), ("bp",), ("minstret",),
                     ("perf", "--tests", "rv32ui-p-add"), ("benchmark", "multiply")):
            result = self.run_cli(*args, "--no-build")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assert_restored()
        self.assertIn("Weighted accuracy: 80.00%", result.stdout)

    def test_prepare_pads_final_word_and_keeps_images(self):
        path = self.project / "verification/riscv-tests/isa/rv32ui-p-add"
        result = self.run_cli("prepare", str(path))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.images[0].read_text(), "00000013\n00000041\n")
        self.assertNotEqual(self.before[self.images[1]], self.images[1].read_bytes())

    def test_failure_restores_generated_and_originally_absent_images(self):
        self.images[-1].unlink()
        result = self.run_cli("single", "rv32ui-p-add", "--no-build", PREP_FAIL="1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("PREPARE_FAIL", result.stdout)
        self.assertFalse(self.images[-1].exists())
        for p in self.images[:-1]: self.assertEqual(p.read_bytes(), self.before[p])

    def test_prepare_failure_is_transactional(self):
        source = self.inst / "uart_tx_smoke_test.s"
        result = self.run_cli("prepare", str(source), PREP_FAIL="1")
        self.assertEqual(result.returncode, 1)
        self.assert_restored()

    def test_rebuild_and_prepare_with_spaces_in_path(self):
        (self.rtl / "vsrc/new_source.v").write_text("module example; endmodule")
        result = self.run_cli("single", "rv32ui-p-add")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.rtl / "build_called").read_text(), "simv_build")
        self.assert_restored()
        source = self.project / "input with spaces.s"
        source.write_text("assembly")
        result = self.run_cli("prepare", str(source), "--toolchain", "gnu")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.images[0].read_text(), "00000013\n")

    def test_simulation_and_build_errors_propagate(self):
        for env, expected in (({"TEST_FAIL": "1"}, "FAIL"), ({"LICENSE_FAIL": "1"}, "LICENSE")):
            result = self.run_cli("single", "rv32ui-p-add", "--no-build", **env)
            self.assertEqual(result.returncode, 1)
            self.assertIn(expected, result.stdout)
            self.assert_restored()
        result = self.run_cli("single", "rv32ui-p-add", "--build", BUILD_FAIL="1")
        self.assertEqual(result.returncode, 1)
        self.assert_restored()

    def test_bp_missing_statistics_is_failure(self):
        result = self.run_cli("bp", "--no-build", NO_BP="1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("BP_PARSE_FAIL", result.stdout)
        self.assert_restored()

    def test_timeout_kills_simulator_and_restores_images(self):
        result = self.run_cli("bp", "--no-build", BP_WALL_TIMEOUT_S="1", SLOW="1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("TIMEOUT", result.stdout)
        self.assert_restored()

    def test_sigterm_restores_images(self):
        proc = subprocess.Popen([str(self.rtl / "run.sh"), "single", "rv32ui-p-add", "--no-build"],
                                cwd=self.project, env=dict(self.env, SLOW="1"),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            deadline = time.monotonic() + 5
            while not (self.rtl / "trace.jsonl").exists() and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertTrue((self.rtl / "trace.jsonl").exists())
            proc.terminate()
            proc.communicate(timeout=5)
            self.assertEqual(proc.returncode, 130)
            self.assert_restored()
        finally:
            if proc.poll() is None:
                proc.kill()
                proc.communicate()

    def test_coremark_measurement_and_crc_validation(self):
        result = self.run_cli("coremark", "3", "--no-build")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("iterations/MHz: 30000.000000", result.stdout)
        self.assertIn("CRCs verified", result.stdout)
        self.assert_restored()
        result = self.run_cli("coremark", "--no-build", BAD_CRC="1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("CRC_FAIL", result.stdout)
        self.assertIn("list CRC 0x0000, expected 0xd4b0", result.stdout)
        self.assert_restored()

    def coremark_log(self):
        return ("TEST PASSED\nseedcrc : 0x8a02\n[0]crclist : 0xd4b0\n"
                "[0]crcmatrix : 0xbe52\n[0]crcstate : 0x5e47\n"
                "[PERF-REGION] mcycle=100 minstret=50\n"
                "[STALL-REGION] mem=10 mul=10 div=10 load_use=10 unstalled=60 redirects=2\n")

    def test_offline_coremark_check_and_short_run(self):
        log = self.project / "existing coremark.log"
        log.write_text(self.coremark_log() +
                       "ERROR! Must execute for at least 10 secs for a valid result!\nErrors detected\n")
        result = self.run_cli("check-coremark", str(log))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Short-run comparison only", result.stdout)
        self.assertFalse((self.rtl / "test_results").exists())
        self.assert_restored()

    def test_offline_coremark_rejects_invalid_evidence(self):
        cases = [("unstalled=60", "unstalled=61", "stall cycle buckets"),
                 ("minstret=50", "minstret=0", "empty measurement window"),
                 ("seedcrc : 0x8a02", "seedcrc : 0xffff", "unknown seed CRC"),
                 ("[0]crcmatrix : 0xbe52", "", "missing matrix CRC"),
                 ("TEST PASSED", "TEST FAILED", "did not complete successfully")]
        log = self.project / "invalid.log"
        for old, new, reason in cases:
            with self.subTest(reason=reason):
                log.write_text(self.coremark_log().replace(old, new))
                result = self.run_cli("check-coremark", str(log))
                self.assertEqual(result.returncode, 1)
                self.assertIn(reason, result.stderr)
        log.write_text(self.coremark_log() + "ERROR! unexpected error\n")
        self.assertEqual(self.run_cli("check-coremark", str(log)).returncode, 1)
        self.assert_restored()

    def test_invalid_arguments_have_no_simulation_side_effects(self):
        for args in (("uart", "--test", "unknown"), ("coremark", "0"),
                     ("isa", "--build", "--no-build"), ("perf", "--tests", "missing"),
                     ("single", "rv32ui-p-*")):
            self.assertNotEqual(self.run_cli(*args).returncode, 0)
        self.assertFalse((self.rtl / "trace.jsonl").exists())
        self.assert_restored()


if __name__ == "__main__":
    unittest.main()
