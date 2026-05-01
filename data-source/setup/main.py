import os
import kagglehub

from pathlib import Path


def main():
    ROOT = Path(__file__).resolve().parents[1]
    # Check or create output_dir
    OUTPUT_DIR = ROOT / "data/raw"
    os.makedirs(OUTPUT_DIR, exist_ok = True) 

    # Download latest version
    path = kagglehub.dataset_download(
        "mustafakeser4/looker-ecommerce-bigquery-dataset",
        output_dir = OUTPUT_DIR,
        force_download = True
    )

    # Show csv files
    for i in OUTPUT_DIR.glob("*.csv"):
        print(i.name)


if __name__ == "__main__":
    main()
