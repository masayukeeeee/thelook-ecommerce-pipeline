with source as (
	select * from {{ source('thelook_raw', 'users') }}
),

drop_duplicated as (
	select
		cast(id as int) as user_id,
		cast(first_name as string) as first_name,
		cast(last_name as string) as last_name,
		cast(email as string) as email,
		-- emailのドメインとローカル部分を分離
		split(email, '@')[1] as email_domain,
		split(email, '@')[0] as email_local,
		cast(age as int) as age,
		cast(gender as string) as gender,
		cast(country as string) as country,
		cast(state as string) as state,
		cast(city as string) as city,
		cast(traffic_source as string) as traffic_source,
		cast(created_at as timestamp) as created_at
	from source
	-- 同一アドレスで複数アカウント登録している場合は最新のものを採用
	qualify row_number() over (partition by email order by created_at desc) = 1
)

select * from drop_duplicated
