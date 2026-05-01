with source as (
    select * from {{ source('thelook_raw', 'products') }}
),

cleaned as (
    select
        cast(id as int) as product_id,
        cast(cost as float) as cost,
        cast(category as string) as category,
        cast(brand as string) as brand,
        cast(retail_price as float) as retail_price,
        cast(department as string) as department,
        cast(sku as string) as sku,
        cast(distribution_center_id as int) as distribution_center_id,
    from source
)

select * from cleaned
