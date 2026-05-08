{{ config(materialized='ephemeral') }}

with base as (
  select
    * exclude (user_id),
    coalesce(user_id, -1) as user_id
  from {{ ref('stg_events') }}
),

parsed as (
  select
    *,
    regexp_extract(uri, '^/product/([0-9]+)', 1) as viewed_product_id,
    regexp_extract(
      uri,
      '^/department/([^/]+)/category/([^/]+)/brand/([^/]+)',
      1
    ) as viewed_department_gender,
    regexp_extract(
      uri,
      '^/department/([^/]+)/category/([^/]+)/brand/([^/]+)',
      2
    ) as viewed_category,
    regexp_extract(
      uri,
      '^/department/([^/]+)/category/([^/]+)/brand/([^/]+)',
      3
    ) as viewed_brand
  from base
)

select * from parsed
