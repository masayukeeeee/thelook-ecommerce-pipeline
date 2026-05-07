with source as (
  select * from {{ ref('stg_inventory_items') }}
),

output as (
  select
    inventory_item_id,
    product_id,
    product_distribution_center_id,
    cast(strftime(created_at, '%Y%m%d') as int) as created_date_key,
    case when sold_at is not null then cast(strftime(sold_at, '%Y%m%d') as int) end as sold_date_key,
    inventory_item_cost,
    date_diff('day', created_at, coalesce(sold_at, current_timestamp)) as days_in_stock,
    sold_at is not null as is_sold
  from source
)

select * from output
