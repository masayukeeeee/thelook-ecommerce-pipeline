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
    orders.order_id,
    orders.user_id,
    order_items.order_item_id,
    order_items.product_id,
    order_items.sale_price,
    inventory_items.inventory_item_id,
    inventory_items.product_distribution_center_id,
    inventory_items.inventory_item_cost,
    order_items.sale_price - inventory_items.inventory_item_cost as gross_profit
  from orders
  left join order_items
    on orders.order_id = order_items.order_id
  left join inventory_items
    on order_items.inventory_item_id = inventory_items.inventory_item_id
)

select * from output
