{{
    config(
        materialized = 'table',
        tags = [
            'dim_users'
        ],
        unique_key = 'user_id',
        dist = 'user_id',
        sort = 'last_login_at'
    )
}}

with dim_users as (

    select
        user_id,
        state,
		created_at,
		last_login_at,
		role,
        is_active,
        sign_up_source
    from
        {{ ref('users_interim') }} as s
	{{ dbt_utils.group_by(7) }}

)

select
    *
from
    dim_users
