{{
    config(
        materialized = 'table',
        tags = [
            'fact_receipt_line_items'
        ],
        unique_key = 'item_id',
        dist = 'receipt_id',
        sort = 'receipt_id'
    )
}}

{% set unique_key = [
    'receipt_id',
    'partner_item_id'
] %}

with dim_items as (

    select
		receipt_id,
		partner_item_id,
		barcode,
		discounted_item_price,
		final_price,
		item_price,
		points_earned,
		price_after_coupon,
		quantity_purchased,
		user_flagged_price,
		user_flagged_quantity,
		target_price
    from
        {{ ref('receipt_line_items') }}
	{{ dbt_utils.group_by(12) }}

)

select
    {{ dbt_utils.generate_surrogate_key(
        unique_key
    ) }} as receipt_item_id,
    *
from
    dim_items