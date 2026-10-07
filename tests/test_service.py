"""Offline lifecycle tests: no framework, daemon, or device access."""
import pathlib
import re
import subprocess
import tempfile
import unittest


class StopTests(unittest.TestCase):
    def check_stop(self, daemon_status):
        source = (pathlib.Path(__file__).resolve().parents[1] / "src/service.sh").read_text()
        stop = re.search(r"^stop\(\) \{.*?^\}", source, re.M | re.S).group()
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            for name in ("pid.txt", "tailscaled.sock", "tailscaled.state"):
                (root / name).write_text("sentinel")
            mock = root / "start-stop-daemon"
            mock.write_text('#!/bin/sh\nexit "$MOCK_STATUS"\n')
            mock.chmod(0o755)
            script = '''
PATH="$1:$PATH"
export MOCK_STATUS="$2"
pidfile="$1/pid.txt"
socket="$1/tailscaled.sock"
daemon="$1/mock-daemon"
''' + stop + '\nstop\n'
            result = subprocess.run(["sh", "-c", script, "test", directory, str(daemon_status)])
            self.assertEqual(result.returncode, daemon_status)
            self.assertEqual((root / "pid.txt").exists(), daemon_status != 0)
            self.assertEqual((root / "tailscaled.sock").exists(), daemon_status != 0)
            self.assertEqual((root / "tailscaled.state").read_text(), "sentinel")

    def test_failed_stop_preserves_control_files_and_failure(self):
        self.check_stop(7)

    def test_successful_stop_removes_control_files_and_preserves_state(self):
        self.check_stop(0)


if __name__ == "__main__":
    unittest.main()
