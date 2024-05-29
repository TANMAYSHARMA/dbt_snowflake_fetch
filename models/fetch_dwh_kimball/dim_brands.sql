{{
    config(
        materialized = 'table',
        tags = [
            'dim_brand'
        ]
    )
}}

with dim_brands as (

    select
        brand_id,
        barcode,
		brand_code,
		brand_name,
		is_top_brand,
        category,
        category_code,
        cpg_id,
        cpg_ref
    from
        {{ ref('brands_interim') }} as bi

)

select *
from dim_brands
