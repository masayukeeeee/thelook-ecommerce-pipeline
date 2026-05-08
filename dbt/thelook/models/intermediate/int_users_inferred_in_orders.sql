{{ config(
  materialized = 'incremental',
  unique_key = ['user_id'],
  incremental_strategy = 'merge',
  merge_update_columns = ['last_seen_at'],
  on_schema_change = 'fail'
) }}

with source as (
  select
    user_id,
    created_at
  from {{ ref('stg_orders') }}
  where
    user_id is not null

    {% if is_incremental() %}
      and created_at > (select coalesce(max(last_seen_at), '1900-01-01') from {{ this }})
    {% endif %}
),

output as (
  select
    user_id,
    min(created_at) as first_seen_at,
    max(created_at) as last_seen_at
  from source
  group by user_id
)

select * from output
