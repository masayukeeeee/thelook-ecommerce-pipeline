with source as (
  select * from {{ source('thelook_raw', 'distribution_centers') }}
),

cleaned as (
  select
    cast(id as int) as product_distribution_center_id,
    cast(name as string) as product_distribution_center_name,
    cast(latitude as float) as latitude,
    cast(longitude as float) as longitude
  from source
)

select * from cleaned
