with weekly as (
  select
    dd.iso_year_week as time_axis,
    count(distinct user_id) as uu
  from "thelook"."main"."dim_users" as du
  inner join "thelook"."main"."dim_date" as dd
    on date(du.created_at) = dd.date
  where du.user_type = 'registered'
  group by 1
)
select
  time_axis,
  uu
from weekly
order by time_axis
;
