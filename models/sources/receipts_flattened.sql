{{
    config(
        materialized = 'view',
        tags = [
            'raw_receipt_flattened'
        ]
    )
}}

with receipts_flattened as (

    select
        s.raw_receipts_json:_id:"$oid"::varchar as receipt_id,
        s.raw_receipts_json:bonusPointsEarned::int as bonus_points_earned,
		s.raw_receipts_json:bonusPointsEarnedReason::varchar as bonus_points_earned_reason,
		s.raw_receipts_json:createDate:"$date"::varchar::timestamp as created_date,
		s.raw_receipts_json:dateScanned:"$date"::varchar::timestamp as scanned_date,
        s.raw_receipts_json:finishedDate:"$date"::varchar::timestamp as finished_date,
        s.raw_receipts_json:modifyDate:"$date"::varchar::timestamp as modify_date,	
        s.raw_receipts_json:pointsAwardedDate:"$date"::varchar::timestamp as points_awarded_date,
        s.raw_receipts_json:pointsEarned::int as points_earned,
        s.raw_receipts_json:purchaseDate:"$date"::varchar::timestamp as purchased_date,
        s.raw_receipts_json:purchasedItemCount::int as purchased_item_count,
        s.raw_receipts_json:rewardsReceiptItemList as rewards_receipt_item_list,
        s.raw_receipts_json:rewardsReceiptStatus::varchar as rewards_receipt_status,
        s.raw_receipts_json:totalSpent::varchar as total_spent,
        s.raw_receipts_json:userId::varchar as user_id
    from
        {{ source('fetch_dbt', 'receipts_raw_json_staging') }} as s

)

select *
from receipts_flattened
