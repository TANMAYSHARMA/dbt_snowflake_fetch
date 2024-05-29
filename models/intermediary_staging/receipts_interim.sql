{{
    config(
        materialized = 'view',
        tags = [
            'receipts_interim'
        ]
    )
}}

with receipts_deduped as (

    select
        receipt_id,
        bonus_points_earned,
		bonus_points_earned_reason,
		created_date as created_at,
		scanned_date as scanned_at,
        finished_date as finished_at,
        modify_date as modified_at,	
        points_awarded_date as points_awarded_at,
        points_earned,
        purchased_date as purchased_at,
        purchased_item_count,
        rewards_receipt_item_list,
        rewards_receipt_status,
        total_spent,
        user_id
    from
        {{ ref('receipts_flattened') }} as rf
	{{ dbt_utils.group_by(15) }}

)

select *
from receipts_deduped
