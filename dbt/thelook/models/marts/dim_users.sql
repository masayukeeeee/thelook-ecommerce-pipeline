with source as (
  select * from {{ ref('stg_users') }}
),

output as (
  select
    user_id,
    email_domain,
    country,
    traffic_source,
    created_at
  from source
)

select * from output
