{{
    config(
        materialized = 'view',
        tags = [
            'raw_brand_flattened'
        ]
    )
}}

with brands_flattened as (

    select
        s.raw_brand_json:_id:"$oid"::varchar as brand_id,
        s.raw_brand_json:barcode::varchar as barcode,
	s.raw_brand_json:brandCode::varchar as brand_code,
	s.raw_brand_json:name::varchar as brand_name,
	s.raw_brand_json:topBrand::boolean as is_top_brand,
        s.raw_brand_json:category::varchar as category,
        s.raw_brand_json:categoryCode::varchar as category_code,
        s.raw_brand_json:cpg:"$id":"$oid"::varchar as cpg_id,
        s.raw_brand_json:cpg:"$ref"::varchar as cpg_ref
    from
        {{ source('fetch_dbt', 'brands_raw_json_staging') }} as s

)

select *
from brands_flattened
