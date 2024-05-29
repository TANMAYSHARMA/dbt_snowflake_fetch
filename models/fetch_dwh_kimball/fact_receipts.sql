{{
    config(
        materialized = 'table',
        tags = [
            'fact_receipts'
        ],
        unique_key = 'receipt_id',
        dist = 'receipt_id',
        sort = 'created_at'
    )
}}

with fact_receipts as (

    select
        receipt_id,
		user_id,
		created_at,
		scanned_at,
        finished_at,
        modified_at,	
        points_awarded_at,
		purchased_at,
        bonus_points_earned,
		bonus_points_earned_reason,		
        points_earned,
        purchased_item_count,
        rewards_receipt_status,
        total_spent
    from
        {{ ref('receipts_interim') }} as rf
	{{ dbt_utils.group_by(14) }}

)

select *
from fact_receipts
