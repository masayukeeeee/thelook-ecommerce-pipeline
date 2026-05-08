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
    ord_it.order_id,
    sum(ord_it.sale_price) as order_total_sale,
    sum(inv_itm.inventory_item_cost) as order_total_cost
  from order_items as ord_it
  left join inventory_items as inv_itm
    on ord_it.inventory_item_id = inv_itm.inventory_item_id
  group by 1
),

output as (
  select
    ord.order_id,
    ord.user_id,
    cast(strftime(ord.created_at, '%Y%m%d') as int) as created_date_key,
    ord.status,
    ord.num_of_item,
    coalesce(ord_sum.order_total_sale, 0.0) as order_total_sale,
    coalesce(ord_sum.order_total_cost, 0.0) as order_total_cost,
    coalesce(ord_sum.order_total_sale, 0.0)
    - coalesce(ord_sum.order_total_cost, 0.0) as order_gross_profit,

    date_diff('day', ord.created_at, ord.shipped_at) as ship_lead_days,
    date_diff('day', ord.created_at, ord.delivered_at) as deliver_lead_days,

    ord.status = 'Cancelled' as is_cancelled,
    ord.status = 'Returned' as is_returned

  from orders as ord
  left join order_summary as ord_sum
    on ord.order_id = ord_sum.order_id
)

select * from output
