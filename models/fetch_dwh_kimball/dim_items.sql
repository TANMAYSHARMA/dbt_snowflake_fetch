{{
    config(
        materialized = 'table',
        tags = [
            'receipts_line_items_flattened_deduped'
        ],
        unique_key = 'item_id',
        dist = 'user_id'
    )
}}

{% set unique_key = [
    'receipt_id',
    'partner_item_id'
] %}

with dim_items as (

    select
		receipt_id,
		barcode,
		description,
		meta_brite_campaign_id as metabrite_campaign_id,
		original_receipt_item_text,
		needs_fetch_review,
		partner_item_id,
		points_payer_id,
		rewards_group,
		rewards_product_partner_id,
		competitive_product,
		discounted_item_price,
		competitor_rewards_group,
		item_number
    from
        {{ ref('receipt_line_items') }}
	{{ dbt_utils.group_by(14) }}

)

select
    {{ dbt_utils.generate_surrogate_key(
        unique_key
    ) }} as item_id,
    *
from
    dim_items
