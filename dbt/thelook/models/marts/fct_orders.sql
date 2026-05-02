with stg_orders as (
  select * from {{ ref('stg_orders') }}
),

stg_order_items as (
  select * from {{ ref('stg_order_items') }}
),
