with weekly as (
  select
    dim_date.year_month,
    dim_date.iso_year_week,
    count(distinct dim_users.user_id) as new_registered_users
  from {{ ref('dim_users') }} as dim_users
  inner join {{ ref('dim_date') }} as dim_date
    on date(dim_users.created_at) = dim_date.date
  where dim_users.user_type = 'registered'
  group by 1, 2
)

select
  year_month,
  iso_year_week,
  new_registered_users,
  sum(new_registered_users) over (
    order by year_month, iso_year_week
    rows between unbounded preceding and current row
  ) as cumulative_registered_users
from weekly
