with source as (
	select * from {{ source('thelook_raw', 'users') }}
),

renamed as (
	select
		id as user_id,
		first_name,
		last_name,
		email,
		age,
		gender,
		country,
		state,
		city,
		traffic_source,

		cast(created_at as timestamp) as created_at

	from source
)

select * from renameds
