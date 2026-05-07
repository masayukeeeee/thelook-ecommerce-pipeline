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
    count_if(event_type = 'page_view') > 0 as page_view_count,
    count_if(event_type = 'product') > 0 as has_product_view,
    count_if(event_type = 'cart') > 0 as has_cart_add,
    count_if(event_type = 'purchase') > 0 as has_purchase,
    count_if(event_type = 'cancel') > 0 as has_cancel,
    arg_min(uri, created_at) as landed_uri,
    arg_max(uri, created_at) as exited_uri,
    min(traffic_source) filter (where sequence_number = 1) as traffic_source,
    min(browser_name) filter (where sequence_number = 1) as browser_name
  from parsed_events
  group by session_id, user_id
),

output as (
  select
    session_id,
    user_id,
    date(started_at) as started_date_key,
    started_at,
    ended_at,
    datediff('second', started_at, ended_at) as session_duration_sec,
    event_count,
    page_view_count,
    has_product_view,
    has_cart_add,
    has_purchase,
    has_cancel,
    case
      when has_cancel then 'cancelled'
      when has_purchase then 'purchased'
      when has_cart_add then 'cart_abandoned'
      else 'browse_only'
    end as session_outcome,
    landed_uri,
    exited_uri,
    traffic_source,
    browser_name
  from session_summary
)

select * from output
