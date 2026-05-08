with parsed_events as (
  select * from {{ ref('int_events_uri_parsed') }}
),

session_summary as (
  select
    session_id,
    user_id,
    min(created_at) as started_at,
    max(created_at) as ended_at,
    count(event_id) as event_count,
    count_if(event_type in ('home', 'department', 'product')) as page_view_count,
    count_if(event_type = 'product') > 0 as has_product,
    count_if(event_type = 'cart') > 0 as has_cart,
    count_if(event_type = 'purchase') > 0 as has_purchase,
    count_if(event_type = 'cancel') > 0 as has_cancel,
    arg_min(uri, created_at) as landed_uri,
    arg_max(uri, created_at) as exited_uri,
    arg_min(traffic_source, created_at) as traffic_source,
    arg_min(browser_name, created_at) as browser_name
  from parsed_events
  group by session_id, user_id
),

output as (
  select
    session_id,
    user_id,
    started_at,
    ended_at,
    event_count,
    page_view_count,
    has_product,
    has_cart,
    has_purchase,
    has_cancel,
    landed_uri,
    exited_uri,
    traffic_source,
    browser_name,
    cast(strftime(started_at, '%Y%m%d') as int) as started_date_key,
    datediff('second', started_at, ended_at) as session_duration_sec,
    case
      when has_cancel then 'cancelled'
      when has_purchase then 'purchased'
      when has_cart then 'cart_abandoned'
      else 'browse_only'
    end as session_outcome
  from session_summary
)

select * from output
