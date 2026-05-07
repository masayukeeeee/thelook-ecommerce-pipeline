-- dim_date {
--     int date_key PK "YYYYMMDD"
--     date date "日付"
--     int year "年"
--     int month "月"
--     int day "日"
--     int week_of_year "週番号"
--     string day_of_week_en "曜日"
--     string day_of_week_ja "曜日（日本語）"
--     boolean is_weekend "週末フラグ"
-- }
with date_spine as (
  select
    unnest(generate_series(
      date '2016-01-01',
      date '2050-12-31',
      interval 1 day
    )) as date_day
),

output as (
  select
    cast(strftime(date_day, '%Y%m%d') as int) as date_key,

    date_day as date,  
    cast(strftime(date_day, '%Y') as int) as year,
    cast(strftime(date_day, '%m') as int) as month,
    cast(strftime(date_day, '%d') as int) as day,
    cast(strftime(date_day, '%W') as int) + 1 as week_of_year,
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
