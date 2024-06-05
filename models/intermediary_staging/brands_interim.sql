{{
    config(
        materialized = 'table',
        tags = [
            'brand_interim'
        ]
    )
}}

with brands_deduped as (

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
        {{ ref('brands_flattened') }} as bs,
    {{ dbt_utils.group_by(9) }}

)

select *
from brands_deduped
