from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import venv


APP_ROOT = Path(__file__).resolve().parent
APP_FILE = APP_ROOT / "app.py"
REQUIREMENTS_FILE = APP_ROOT / "requirements.txt"
VENV_DIR = APP_ROOT / ".venv"
STAMP_FILE = VENV_DIR / ".requirements.sha256"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bootstrap the TOBIT local Streamlit playground and launch it.",
    )
    parser.add_argument(
        "--reinstall",
        action="store_true",
        help="Force a fresh dependency install even if the requirements stamp matches.",
    )
    parser.add_argument(
        "--skip-install",
        action="store_true",
        help="Skip dependency installation and just launch with the existing virtual environment.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the steps without creating the virtual environment or launching Streamlit.",
    )
    parser.add_argument(
        "streamlit_args",
        nargs=argparse.REMAINDER,
        help="Optional args forwarded to Streamlit. Example: -- --server.port 8502",
    )
    return parser.parse_args()


def requirements_hash() -> str:
    payload = REQUIREMENTS_FILE.read_bytes()
    return hashlib.sha256(payload).hexdigest()


def venv_python_path() -> Path:
    if os.name == "nt":
        return VENV_DIR / "Scripts" / "python.exe"
    return VENV_DIR / "bin" / "python"


def run_command(command: list[str], dry_run: bool = False) -> None:
    pretty = " ".join(f'"{part}"' if " " in part else part for part in command)
    print(pretty)
    if dry_run:
        return
    subprocess.check_call(command, cwd=str(APP_ROOT))


def ensure_virtualenv(dry_run: bool = False) -> Path:
    python_path = venv_python_path()
    if python_path.exists():
        return python_path

    print(f"Creating virtual environment in {VENV_DIR}")
    if dry_run:
        return python_path

    builder = venv.EnvBuilder(with_pip=True, clear=False, symlinks=False, upgrade=False)
    builder.create(str(VENV_DIR))
    return python_path


def install_dependencies(python_path: Path, force: bool = False, dry_run: bool = False) -> None:
    expected_hash = requirements_hash()
    current_hash = STAMP_FILE.read_text(encoding="utf-8").strip() if STAMP_FILE.exists() else None

    if current_hash == expected_hash and not force:
        print("Dependency stamp matches requirements.txt; skipping pip install.")
        return

    print("Installing playground dependencies")
    run_command([str(python_path), "-m", "pip", "install", "--upgrade", "pip"], dry_run=dry_run)
    run_command([str(python_path), "-m", "pip", "install", "-r", str(REQUIREMENTS_FILE)], dry_run=dry_run)

    if dry_run:
        return

    STAMP_FILE.parent.mkdir(parents=True, exist_ok=True)
    STAMP_FILE.write_text(expected_hash, encoding="utf-8")


def launch_streamlit(python_path: Path, streamlit_args: list[str], dry_run: bool = False) -> int:
    forwarded = list(streamlit_args)
    if forwarded and forwarded[0] == "--":
        forwarded = forwarded[1:]

    command = [str(python_path), "-m", "streamlit", "run", str(APP_FILE), *forwarded]
    if dry_run:
        run_command(command, dry_run=True)
        return 0

    completed = subprocess.run(command, cwd=str(APP_ROOT))
    return int(completed.returncode)


def main() -> int:
    args = parse_args()

    if not APP_FILE.exists():
        print(f"Missing app file: {APP_FILE}", file=sys.stderr)
        return 1
    if not REQUIREMENTS_FILE.exists():
        print(f"Missing requirements file: {REQUIREMENTS_FILE}", file=sys.stderr)
        return 1

    print("TOBIT local playground launcher")
    print(f"Folder: {APP_ROOT}")
    print(f"Python: {sys.executable}")

    python_path = ensure_virtualenv(dry_run=args.dry_run)
    if not args.skip_install:
        install_dependencies(
            python_path,
            force=args.reinstall,
            dry_run=args.dry_run,
        )
    elif not python_path.exists() and not args.dry_run:
        print("The virtual environment does not exist yet, so --skip-install cannot be used.", file=sys.stderr)
        return 1

    return launch_streamlit(python_path, args.streamlit_args, dry_run=args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
