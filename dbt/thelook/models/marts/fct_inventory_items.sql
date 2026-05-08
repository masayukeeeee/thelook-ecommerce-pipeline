with source as (
  select * from {{ ref('stg_inventory_items') }}
),

as_of as (
  select
    greatest(
      max(created_at),
      coalesce(max(sold_at), max(created_at))
    ) as as_of_ts
  from source
),

output as (
  select
    inventory_item_id,
    product_id,
    product_distribution_center_id,
    cast(strftime(created_at, '%Y%m%d') as int) as created_date_key,
    inventory_item_cost,
    case when sold_at is not null then cast(strftime(sold_at, '%Y%m%d') as int) end
      as sold_date_key,
    date_diff(
      'day',
      created_at,
      coalesce(sold_at, (select as_of_ts from as_of))
    ) as days_in_stock,
    sold_at is not null as is_sold
  from source
)

select * from output
