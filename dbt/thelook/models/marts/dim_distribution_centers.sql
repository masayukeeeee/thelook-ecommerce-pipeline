with source as (
  select * from {{ ref('stg_distribution_centers') }}
),

output as (
  select
    product_distribution_center_id,
    product_distribution_center_name
  from source
)

select * from output
