with source as (
    select * from {{ source('thelook_raw', 'orders') }}
),

cleaned as (
    select
        cast(order_id as int) as order_id,
        cast(user_id as int) as user_id,
        cast(status as string) as status,
        cast(gender as string) as gender,
        cast(created_at as timestamp) as created_at,
        
        cast(shipped_at as timestamp) as shipped_at,
        cast(delivered_at as timestamp) as delivered_at,
        cast(returned_at as timestamp) as returned_at,
        cast(num_of_item as int) as num_of_item,
    from source
    where order_id is not null
)

select * from cleaned