{{
    config(
        materialized = 'table',
        tags = [
            'receipts_line_items_flattened_deduped'
        ]
    )
}}

with receipts_line_items_flattened as (

    select
        ri.receipt_id,
        flattened_item.value::variant as item
    from
        {{ ref('receipts_interim') }} as ri,
        lateral flatten(input => ri.rewards_receipt_item_list) as flattened_item

),

receipts_line_items_flattened_deduped as (

    select
        receipt_id,
        item:barcode::varchar as barcode,
        item:brandCode::varchar as brand_code,
        item:description::varchar as description,
        item:discountedItemPrice::float as discounted_item_price,
        item:finalPrice::float as final_price,
        item:itemPrice::float as item_price,
        item:metabriteCampaignId::varchar as meta_brite_campaign_id,
        item:originalReceiptItemText::varchar as original_receipt_item_text,
        item:needsFetchReview::boolean as needs_fetch_review,
        item:partnerItemId::varchar as partner_item_id,
        item:pointsEarned::int as points_earned,
        item:pointsPayerId::varchar as points_payer_id,
        item:priceAfterCoupon::float as price_after_coupon,
        item:preventTargetGapPoints::boolean as is_prevent_target_gap_points,
        item:quantityPurchased::int as quantity_purchased,
        item:userFlaggedBarcode::varchar as user_flagged_barcode,
        item:userFlaggedDescription::varchar as user_flagged_description,
        item:userFlaggedNewItem::boolean as is_user_flagged_new_item,
        item:userFlaggedPrice::float as user_flagged_price,
        item:userFlaggedQuantity::int as user_flagged_quantity,
        item:rewardsGroup::varchar as rewards_group,
        item:rewardsProductPartnerId::varchar as rewards_product_partner_id,
        item:targetPrice::float as target_price,
        item:competitiveProduct::varchar as competitive_product,
        item:competitorRewardsGroup::varchar as competitor_rewards_group,
        item:itemNumber::varchar as item_number
-- There were more columns that could have been extracted, I only extracted columns which i thought were important		
    from
        receipts_line_items_flattened
	{{ dbt_utils.group_by(27) }}
     
)

select *
from receipts_line_items_flattened_deduped
