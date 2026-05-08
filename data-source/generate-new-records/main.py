"""
Generate new records and insert them into the source csv.
1. events.csv
"""
import argparse
import csv
import random
import json
import uuid
from datetime import datetime, timezone, timedelta
from pathlib import Path

source_dir = Path(__file__).resolve().parents[1] / "data" / "raw"
csv_file_path = source_dir / "events.csv"

def choose_one() -> dict | None:
    """
    Choose one record from the source csv where sequence_number == 1 and user_id is not null.
    """
    match_count = 0
    selected_row = None

    with open(csv_file_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)    

        for r in reader:
            if r.get("user_id") and r.get("sequence_number") == "1":
                match_count += 1
                if random.randint(1, match_count) == 1:
                    selected_row = r

    return selected_row


def generate_new_record(r: dict) -> dict:
    """
    Generate a new record based on the given record.
    """
    if r is None:
        raise ValueError("No record found with sequence_number == 1 and user_id is not null.")

    # adhoc event_id at random and over 2500000 
    new_event_id = random.randint(2500001, 5000000)

    new_session_id = str(uuid.uuid4())

    jst = timezone(timedelta(hours=9))
    current_time_str = datetime.now(jst).strftime("%Y-%m-%d %H:%M:%S+09")
    
    new_r = r.copy()

    new_r["id"] = new_event_id
    new_r["session_id"] = new_session_id
    new_r["created_at"] = current_time_str

    return new_r


def insert_new_record(new_r: dict):
    """
    Insert the new record into the source csv.
    """
    with open(csv_file_path, "a", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=new_r.keys(), lineterminator="\n")
        writer.writerow(new_r)


def main():
    r = choose_one()
    new_r = generate_new_record(r)
    insert_new_record(new_r)

if __name__ == "__main__":
    main()    
    print("New record generated and inserted into the source csv.")
