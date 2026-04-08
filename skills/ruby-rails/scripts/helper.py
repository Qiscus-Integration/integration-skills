#!/usr/bin/env python3
"""Print a compact backend checklist for the Rails skill."""

from __future__ import annotations

CHECKLIST = [
    "Inspect the nearest existing Rails implementation before adding a new abstraction.",
    "Keep controller actions thin; move coordination into forms, services, or queries.",
    "Use Pundit for authorization and Sidekiq for non-request-critical work.",
    "Match existing RSpec structure and add coverage near the changed runtime code.",
    "Treat migrations as strong_migrations-compatible and verify tenant-aware behavior.",
    "Load the focused reference file when the task is mainly queries, jobs, APIs, or testing.",
    "If an API contract changes, update docs/openapi.yml before considering the task complete.",
]


def main() -> None:
    print("Ruby/Rails checklist")
    for index, item in enumerate(CHECKLIST, start=1):
      print(f"{index}. {item}")


if __name__ == "__main__":
    main()
