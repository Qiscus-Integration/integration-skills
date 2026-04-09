#!/usr/bin/env python3
"""Print a compact checklist for the prd-plan skill."""

from __future__ import annotations

CHECKLIST = [
    "Clarify scope, users, goals, constraints, and assumptions before drafting the PRD.",
    "Build outputs sequentially: requirements, journey, flow, edge cases, data model, API, stories.",
    "Keep every phase consistent with the previous one instead of regenerating from scratch.",
    "Cover failure paths, authorization, retries, and concurrency where relevant.",
    "Keep user stories small, testable, and tied to the journey and edge cases.",
    "Use assets/templates/notion-templated.md.template when the user wants Notion-ready output.",
]


def main() -> None:
    print("PRD plan checklist")
    for index, item in enumerate(CHECKLIST, start=1):
        print(f"{index}. {item}")


if __name__ == "__main__":
    main()
