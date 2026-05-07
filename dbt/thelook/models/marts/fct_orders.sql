with orders as (
  select * from {{ ref('stg_orders') }}
),

order_items as (
  select * from {{ ref('stg_order_items') }}
),

inventory_items as (
  select * from {{ ref('stg_inventory_items') }}
),

order_summary as (
  select
    oi.order_id,
    sum(oi.sale_price) as order_total_sale,
    sum(ii.inventory_item_cost) as order_total_cost -- ※stg_inventory_itemsの原価カラム名に合わせて調整してください
  from order_items oi
  left join inventory_items ii
    on oi.inventory_item_id = ii.inventory_item_id
  group by 1
),

output as (
  select
    o.order_id,
    o.user_id,
    cast(strftime(o.created_at, '%Y%m%d') as int) as created_date_key,
    o.status,
    o.num_of_item,
    
    coalesce(s.order_total_sale, 0.0) as order_total_sale,
    coalesce(s.order_total_cost, 0.0) as order_total_cost,
    coalesce(s.order_total_sale, 0.0) - coalesce(s.order_total_cost, 0.0) as order_gross_profit,
    
    date_diff('day', o.created_at, o.shipped_at) as ship_lead_days,
    date_diff('day', o.created_at, o.delivered_at) as deliver_lead_days,
    
    o.status = 'cancelled' as is_cancelled,
    o.status = 'returned' as is_returned

  from orders o
  left join order_summary s
    on o.order_id = s.order_id
)

select * from output
