from __future__ import annotations

import sys
from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = APP_ROOT.parents[1]
sys.path.insert(0, str(APP_ROOT))

from data_bridge import load_playground_dataset, write_local_snapshot  # noqa: E402


def main() -> None:
    bundle = load_playground_dataset(PROJECT_ROOT)
    csv_path, json_path = write_local_snapshot(bundle, APP_ROOT / "data")
    print(f"Wrote {csv_path}")
    print(f"Wrote {json_path}")
    print(f"Rows: {len(bundle.data)}")
    print(f"Participants: {bundle.data['participant_key'].nunique()}")
    for note in bundle.metadata.get("sources", []):
        print(f"- {note}")


if __name__ == "__main__":
    main()
