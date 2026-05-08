with registered as (
  select
    user_id,
    email_domain,
    country,
    traffic_source,
    created_at,
    'registered' as user_type
  from {{ ref('stg_users') }}
),

_referenced as (
  select * from {{ ref('int_users_inferred_in_events') }}
  union all
  select * from {{ ref('int_users_inferred_in_orders') }}
),

referenced as (
  select distinct user_id from _referenced
),

inferred as (
  select
    user_id,
    cast(null as varchar) as email_domain,
    cast(null as varchar) as country,
    cast(null as varchar) as traffic_source,
    cast(null as timestamp) as created_at,
    'inferred' as user_type
  from referenced
  where not exists (
    select 1 from registered
    where registered.user_id = referenced.user_id
  )
),

unknown as (
  select
    -1 as user_id,
    cast(null as varchar) as email_domain,
    cast(null as varchar) as country,
    cast(null as varchar) as traffic_source,
    cast(null as timestamp) as created_at,
    'unknown' as user_type
),

output as (
  select * from registered
  union all
  select * from inferred
  union all
  select * from unknown
)

select * from output
