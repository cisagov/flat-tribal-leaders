#!/usr/bin/env python3
"""Clean the tribal-leaders CSV: drop ID columns, strip newlines, sort by tribe.

Reads the CSV path given as the first argument and writes the cleaned result to
./tribal-leaders.csv. Uses only the Python standard library.
"""
import csv
import sys

DROP_COLUMNS = ("OBJECTID", "GlobalID")
SORT_COLUMN = "Tribe Full Name"
OUTPUT = "tribal-leaders.csv"


def main() -> None:
    source = sys.argv[1]

    # utf-8-sig drops a leading BOM if the source has one, newline="" lets the
    # csv module handle quoted fields that contain embedded newlines.
    with open(source, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))

    for row in rows:
        for column in DROP_COLUMNS:
            row.pop(column, None)
        # Strip carriage returns / newlines from every column except
        # the last one ("y", a coordinate) to match the original
        for column in list(row):
            if column == "y":
                break
            row[column] = row[column].replace("\r", "").replace("\n", "")

    rows.sort(key=lambda row: row[SORT_COLUMN])

    with open(OUTPUT, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main()
