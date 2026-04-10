#!/usr/bin/env python3
"""Print a compact backend checklist for the Rails skill."""

from __future__ import annotations

CHECKLIST = [
    "Check Gemfile.lock and .ruby-version to detect Ruby/Rails versions before version-specific advice.",
    "Inspect the nearest existing Rails implementation before adding a new abstraction.",
    "Keep controller actions thin; move coordination into forms, services, or queries.",
    "Use the project's authorization library for access control and background jobs for non-request-critical work.",
    "Write tests for every new feature, behavior change, or bug fix — no code without spec coverage.",
    "Match existing RSpec structure and add coverage near the changed runtime code.",
    "Treat migrations as production-safe, reversible, and compatible with migration safety tools when present.",
    "Load the focused reference file when the task is mainly queries, jobs, APIs, or testing.",
    "If an API contract changes, update API documentation before considering the task complete.",
    "Run the relevant specs to verify they pass before finishing.",
]


def main() -> None:
    print("Ruby/Rails checklist")
    for index, item in enumerate(CHECKLIST, start=1):
      print(f"{index}. {item}")


if __name__ == "__main__":
    main()
