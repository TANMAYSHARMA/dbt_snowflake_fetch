{{
    config(
        materialized = 'view'
    )
}}

-- Questions:
-- What are the top 5 brands by receipts scanned for most recent month?

with brand_receipts as (

    select
        coalesce(db.brand_name, 'N/A') as brand_name,
        date_trunc('month', fs.created_at::date) as receipt_month,
        count(distinct fs.receipt_id) as count_of_receipts
    from fact_receipts as fs
    inner join fact_receipt_line_items as fcli
        using(receipt_id)
    left join dim_brands as db
        on fcli.barcode = db.barcode -- this is resulting in a lot of null brand_names ideal join would have been on brand_id
    where fs.created_at >= date_trunc('month', add_months(current_date, -48)) -- most recent months were ot generating any results. Please feel free to tweak 
    {{ dbt_utils.group_by(2) }}

),

total_receipts as (

    select
        brand_name,
        sum(count_of_receipts) as total_count_of_receipts
    from brand_receipts
    {{ dbt_utils.group_by(1) }}

),

ranked_brands as (

    select
        brand_name,
        total_count_of_receipts,
        row_number() over (order by total_count_of_receipts desc) as rank
    from total_receipts

)

select
    brand_name,
    total_count_of_receipts,
    rank
from ranked_brands
where rank <= 5
order by rank
