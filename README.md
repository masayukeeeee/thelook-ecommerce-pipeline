# thelook-ecommerce-pipeline

## Download the original dataset

```python
import os
import kagglehub

from pathlib import Path

# Check or create output_dir
OUTPUT_DIR_STR = "data/raw"
os.makedirs(OUTPUT_DIR_STR)
OUTPUT_DIR = Path(OUTPUT_DIR_STR)

# Download latest version
path = kagglehub.dataset_download(
    "mustafakeser4/looker-ecommerce-bigquery-dataset",
    output_dir = OUTPUT_DIR_STR
)

# Show csv files
for i in f.glob("*.csv"):
    print(i.name)

# > products.csv
# > orders.csv
# > inventory_items.csv
# > users.csv
# > distribution_centers.csv
# > events.csv
# > order_items.csv

```
