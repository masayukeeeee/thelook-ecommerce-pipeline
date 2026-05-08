with date_spine as (
  select
    unnest(generate_series(
      date '2016-01-01',
      date_trunc('year', current_date()) + interval 3 year - interval 1 day,
      interval 1 day
    )) as date_day
),

output as (
  select
    cast(strftime(date_day, '%Y%m%d') as int) as date_key,

    cast(date_day as date) as date,
    cast(strftime(date_day, '%Y') as int) as year,
    cast(strftime(date_day, '%m') as int) as month,
    cast(strftime(date_day, '%d') as int) as day,

    cast(strftime(date_day, '%G-W%V') as varchar) as iso_year_week,
    cast(strftime(date_day, '%Y-%m') as varchar) as year_month,

    dayname(date_day) as day_of_week_en,
    case
      when dayname(date_day) = 'Monday' then '月'
      when dayname(date_day) = 'Tuesday' then '火'
      when dayname(date_day) = 'Wednesday' then '水'
      when dayname(date_day) = 'Thursday' then '木'
      when dayname(date_day) = 'Friday' then '金'
      when dayname(date_day) = 'Saturday' then '土'
      when dayname(date_day) = 'Sunday' then '日'
    end as day_of_week_ja,
    case when dayname(date_day) in ('Saturday', 'Sunday') then true else false end as is_weekend
  from date_spine
)

select * from output
