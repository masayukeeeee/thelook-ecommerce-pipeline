with orders as (
  select * from {{ ref('stg_orders') }}
),

order_items as (
  select * from {{ ref('stg_order_items') }}
),

inventory_items as (
  select * from {{ ref('stg_inventory_items') }}
),

output as (
  select
    order_items.order_item_id,
    orders.order_id,
    orders.user_id,
    order_items.product_id,
    inventory_items.inventory_item_id,
    inventory_items.product_distribution_center_id,

    cast(strftime(order_items.created_at, '%Y%m%d') as int) as created_date_key,
    order_items.sale_price,
    inventory_items.inventory_item_cost,

    case
      when order_items.shipped_at is not null
        then cast(strftime(order_items.shipped_at, '%Y%m%d') as int)
    end as shipped_date_key,
    case
      when order_items.delivered_at is not null
        then cast(strftime(order_items.delivered_at, '%Y%m%d') as int)
    end as delivered_date_key,
    order_items.sale_price - inventory_items.inventory_item_cost as gross_profit,

    date_diff('day', order_items.created_at, order_items.shipped_at) as ship_lead_days,
    date_diff('day', order_items.created_at, order_items.delivered_at) as deliver_lead_days
  from orders
  left join order_items
    on orders.order_id = order_items.order_id
  left join inventory_items
    on order_items.inventory_item_id = inventory_items.inventory_item_id
)

select * from output
