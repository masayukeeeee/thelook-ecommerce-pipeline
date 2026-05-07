-- dim_distribution_centers {
--   int distribution_center_id PK "センターID"
--   string distribution_center_name "センター名"
-- }

with source as (
  select * from {{ ref('stg_distribution_centers') }}
),

output as (
  select
    distribution_center_id,
    distribution_center_name
  from source
)

select * from output
