{{
    config(
        materialized = 'view'
    )
}}

-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
-- Answer: Since the data was not generating any results I wrote a query to instead generate count_of_receipts for the last 6 months by brand_name
with monthly_receipts as (

    select
        coalesce(db.brand_name, 'N/A') as brand_name,
        date_trunc('month', fs.created_at::date) as receipt_month,
        count(distinct fs.receipt_id) as count_of_receipts
    from fact_receipts as fs
    inner join fact_receipt_line_items as fcli
        using(receipt_id)
    left join dim_brands as db
        on fcli.barcode = db.barcode
    {{ dbt_utils.group_by(2) }}

),

pivoted_receipts as (

    select
        brand_name,
        sum(case when receipt_month = date_trunc('month', current_date) then count_of_receipts else 0 end) as current_month,
        sum(case when receipt_month = date_trunc('month', add_months(current_date, -1)) then count_of_receipts else 0 end) as previous_month_1,
        sum(case when receipt_month = date_trunc('month', add_months(current_date, -2)) then count_of_receipts else 0 end) as previous_month_2,
        sum(case when receipt_month = date_trunc('month', add_months(current_date, -3)) then count_of_receipts else 0 end) as previous_month_3,
        sum(case when receipt_month = date_trunc('month', add_months(current_date, -4)) then count_of_receipts else 0 end) as previous_month_4,
        sum(case when receipt_month = date_trunc('month', add_months(current_date, -5)) then count_of_receipts else 0 end) as previous_month_5
    from monthly_receipts
    group by brand_name

)

select *
from pivoted_receipts
order by current_month
