with source as (
  select * from {{ ref('int_events_uri_parsed') }}
),

-- 1. 各セッションにおいて、各ステップに「最初に」到達した時刻だけを抽出（重複排除）
first_hits as (
  select
    session_id,
    user_id,
    event_type as step_name,
    min(created_at) as reached_at
  from source
  where event_type in ('home', 'department', 'product', 'cart', 'purchase')
  group by 1, 2, 3
),

-- 2. BIツールが喜ぶ「固定のステップ番号(1~5)」を付与する
funnel_steps as (
  select
    session_id,
    user_id,
    step_name,
    reached_at,
    case step_name
      when 'home'       then 1
      when 'department' then 2
      when 'product'    then 3
      when 'cart'       then 4
      when 'purchase'   then 5
    end as step_no
  from first_hits
),

-- 3. Window関数を使って経過時間と離脱フラグを計算する
output as (
  select
    session_id,
    step_no,
    user_id,
    cast(strftime(reached_at, '%Y%m%d') as int) as reached_date_key,
    step_name,
    reached_at,
    
    -- セッション内の「一番最初のイベント時刻」からの経過秒数
    date_diff('second', min(reached_at) over (partition by session_id), reached_at) as time_from_session_start_sec,
    
    -- 時間順で並べた時に、次のステップが存在しなければ「ここで離脱（true）」
    lead(step_no) over (partition by session_id order by reached_at) is null as dropped_here
    
  from funnel_steps
)

select * from output
