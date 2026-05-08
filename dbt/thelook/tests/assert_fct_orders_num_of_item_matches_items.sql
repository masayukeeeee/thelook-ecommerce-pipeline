with derived as (
  select
    fct_orders.order_id,
    fct_orders.num_of_item as num_of_item_in_orders,
    count(fct_order_items.order_item_id) as actual_items
  from {{ ref('fct_orders') }} as fct_orders
  left join {{ ref('fct_order_items') }} as fct_order_items using (order_id)
  group by 1, 2
)

select * from derived
where not (num_of_item_in_orders = actual_items)
