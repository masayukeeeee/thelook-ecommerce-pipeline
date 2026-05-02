with stg_users as (
  select * from {{ ref('stg_users') }}
),

select
  user_id,
  first_name,
  last_name,
  email,
  age,
  gender,
  country,
  state,
  city,
  traffic_source,
  created_at,
  email_domain,
  email_local
from stg_users
