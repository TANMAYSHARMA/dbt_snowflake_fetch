{{
    config(
        materialized = 'table',
        tags = [
            'raw_users_flattened'
        ]
    )
}}

with users_deduped as (

    select
        user_id,
        state,
	created_date as created_at,
	last_login_date as last_login_at,
	role,
        is_active,
        sign_up_source
    from
        {{ ref('users_flattened') }} as s
	{{ dbt_utils.group_by(7) }}

)

select *
from users_deduped
