# thelook-ecommerce-pipeline

## 1. Download the original dataset

Download csv files from kaggle datasets.
All files will be put in `data-source/data/raw` directory.


```sh
cd data-source/setup
uv sync --frozen
source .venv/bin/activate
python main.py
```

## 2. dbt initialization

```sh
cd dbt
uv sync --frozen
source .venv/bin/activate
dbt run --profiles-dir .
dbt test --profiles-dir .
```
