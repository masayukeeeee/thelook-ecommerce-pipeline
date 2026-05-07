with source as (
  select * from {{ ref('stg_products') }}
),

output as (
  select
    product_id,
    department,
    category,
    brand,
    sku,
    retail_price,
    product_cost,
    distribution_center_id
  from source
)

select * from output
