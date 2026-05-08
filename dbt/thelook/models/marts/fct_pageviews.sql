with source as (
  select * from {{ ref('int_events_uri_parsed') }}
),

output as (
  select
    event_id,
    session_id,
    user_id,
    cast(strftime(created_at, '%Y%m%d') as int) as created_date_key,
    created_at,
    sequence_number,
    event_type,
    uri,
    viewed_product_id,
    viewed_department_gender,
    viewed_category,
    viewed_brand,
    sequence_number = 1 as is_landing,
    sequence_number = max(sequence_number) over (partition by session_id) as is_exit
  from source
  where event_type in ('home', 'department', 'product')
)

select * from output
