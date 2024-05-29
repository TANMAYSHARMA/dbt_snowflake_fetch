{{
    config(
        materialized = 'view',
        tags = [
            'raw_users_flattened'
        ]
    )
}}

with users_flattened as (

    select
        s.raw_users_json:_id:"$oid"::varchar as user_id,
        s.raw_users_json:state::varchar as state,
		s.raw_users_json:createdDate:"$date"::varchar::timestamp as created_date,
		s.raw_users_json:lastLogin:"$date"::varchar::timestamp as last_login_date,
		s.raw_users_json:role::varchar as role,
        s.raw_users_json:active::boolean as is_active,
        s.raw_users_json:signUpSource::varchar as sign_up_source
    from
        {{ source('fetch_dbt', 'users_raw_json_staging') }} as s

)

select *
from users_flattened
