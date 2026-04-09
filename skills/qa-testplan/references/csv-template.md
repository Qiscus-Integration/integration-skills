---
name: csv-template
description: CSV template and generation rules for QA test case export, matching the standard Qiscus QA spreadsheet format.
type: reference
---

# QA Test Case CSV Template

## Column Structure (exact order)

| # | Column Header | Description |
| --- | --------------- | ------------- |
| 1 | No | Sequential test case number (1, 2, 3, ...) |
| 2 | Key Feature in TRA/ SRS | Feature name / module name from the PRD |
| 3 | Scenario | Short scenario label (e.g., "Select Send Helpdesk Notification action") |
| 4 | Description Scenario | Full description of what the scenario covers |
| 5 | PREREQUISITE | Pre-conditions required before executing the test |
| 6 | CASE TYPE | `Positive` or `Negative` |
| 7 | Test Case | Specific test case action (e.g., "Verify action availability") |
| 8 | Test Data | Input values or role used (e.g., "Role: Admin") |
| 9 | Step | Numbered steps, each on a new line within the cell |
| 10 | EXPECTED RESULT | What should happen after the steps are completed |
| 11 | ENV | Environment: `Staging`, `Production`, or `Dev` |
| 12 | (blank) | Leave blank — reserved for execution pass/fail marking |
| 13 | Actual Result | Leave blank — filled by tester during execution |
| 14 | Severity | Leave blank — filled if test fails: `Critical`, `High`, `Medium`, `Low` |
| 15 | Notes | Leave blank — filled by tester |
| 16 | TEST DATE | Leave blank — filled during execution |
| 17 | TESTER | Leave blank — filled during execution |
| 18 | SCREEN CAPTURE | Leave blank — filled during execution |
| 19 | NOTE | Leave blank — additional notes column |
| 20 | (blank) | Leave blank |
| 21 | TOTAL TEST CASE | First row only: label "TOTAL TEST CASE" in col 21, count in col 22 |
| 22 | (count) | Total count of test cases |
| 23 | (blank) | Leave blank |
| 24 | TOTAL TEST CASE | Repeat label in col 24 for formula reference |

## CSV Header Row (exact)

```bash
No,Key Feature in TRA/ SRS,Scenario,Description Scenario,PREREQUISITE,CASE TYPE,Test Case,Test Data,Step,EXPECTED RESULT,ENV,,Actual Result,Severity,Notes,TEST DATE,TESTER,SCREEN CAPTURE,NOTE,,TOTAL TEST CASE,{COUNT},,TOTAL TEST CASE
```

## Step Format Rules

- Each step must be numbered: `1. action`
- Multiple steps are separated by newline within the same cell
- Steps must be self-contained — no assumed domain knowledge
- **Opening a new feature always requires these standard opening steps:**

  ```bash
  1. Login sebagai {Role}
  2. Buka {URL / Menu path}
  3. Verifikasi halaman {feature name} berhasil terbuka
  ```

- After the opening steps, add the specific feature interaction steps

## PREREQUISITE Format Rules

- Written in Indonesian (Bahasa Indonesia)
- Comma-separated conditions in a single string
- Always include login role and the page/editor that must be open
- Example: `Login sebagai Admin/Owner, Automation editor terbuka`

## CASE TYPE Values

- `Positive` — happy path, valid inputs, expected success
- `Negative` — invalid inputs, unauthorized roles, missing permissions, error states

## ENV Values

- `Staging` — default for new feature testing
- `Production` — for regression on live environment
- `Dev` — for development environment testing

## Sample Row (Positive case)

```csv
1,Automation – Helpdesk Notification,Select Send Helpdesk Notification action,"Admin/Owner dapat memilih action Send Notifications → Send Helpdesk Notification","Login sebagai Admin/Owner, Automation editor terbuka",Positive,Verify action availability,Role: Admin,"1. Login sebagai Admin
2. Buka menu Automation
3. Verifikasi halaman Automation Editor berhasil terbuka
4. Klik tombol Add Action
5. Pilih Send Notifications
6. Verifikasi opsi Send Helpdesk Notification tersedia",Action Send Helpdesk Notification tersedia di dropdown,Staging,,,,,,,,,,,,
```

## Sample Row (Negative case)

```csv
2,Automation – Helpdesk Notification,Select Send Helpdesk Notification action – unauthorized role,"Agent tidak dapat mengakses Send Helpdesk Notification action","Login sebagai Agent, Automation editor terbuka",Negative,Verify action not available for Agent role,Role: Agent,"1. Login sebagai Agent
2. Buka menu Automation
3. Verifikasi halaman Automation Editor berhasil terbuka
4. Klik tombol Add Action
5. Pilih Send Notifications",Opsi Send Helpdesk Notification tidak tersedia atau tombol Add Action tidak ada,Staging,,,,,,,,,,,,
```

## Generation Instructions

When `output_format = csv`:

1. Generate **all manual test cases** from Phase 3 into this CSV format.
2. Number rows sequentially starting from 1 (No column).
3. Group rows by feature — same `Key Feature in TRA/ SRS` value for related test cases.
4. Every feature's first test case must include the **standard opening steps** above.
5. For subsequent test cases in the same feature, opening steps can be condensed to:

   ```bash
   1. Login sebagai {Role} (sudah login — skip ke langkah berikutnya)
   ```

   unless the PREREQUISITE state differs.
6. Steps cell: use actual newline (`\n`) within a quoted CSV cell so it renders correctly in Google Sheets / Excel.
7. Columns 12 (blank), 13–19 (execution fields): leave empty for all rows.
8. Final tally: in the header row only, put `TOTAL TEST CASE` in column 21 and the total count in column 22.
9. Save the CSV file to: `docs/features/[feature-slug]/qa-testplan.csv`

## Output File Naming

- Markdown: `docs/features/[feature-slug]/qa-testplan.md`
- CSV: `docs/features/[feature-slug]/qa-testplan.csv`
- Both files should be produced when `output_format = csv` or `output_format = both`
