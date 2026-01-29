#!/usr/bin/env python3
"""Parse and pretty-print a Mastra workflow run result from stdin."""
import sys
import json

data = json.load(sys.stdin)
status = data.get("status", "unknown")
r = data.get("result", {})

if status == "success":
    print("Ingestion Summary:")
    fields = [
        ("Total docs", "totalDocs"),
        ("New docs", "newDocs"),
        ("Changed docs", "changedDocs"),
        ("Unchanged docs", "unchangedDocs"),
        ("Deleted docs", "deletedDocs"),
        ("Total chunks", "totalChunks"),
    ]
    for label, key in fields:
        print(f"  {label}: {r.get(key, '?')}")
    print(f"  Duration: {r.get('duration', '?')}ms")
    errors = r.get("errors", [])
    if errors:
        print(f"  Errors: {len(errors)}")
        for e in errors[:5]:
            print(f"    - {e}")
elif status == "failed":
    print("Result:", json.dumps(r, indent=2))
    errors = r.get("errors", [])
    for e in errors:
        print(f"  - {e}")
else:
    print(f"Status: {status}")
    print(json.dumps(data, indent=2))
