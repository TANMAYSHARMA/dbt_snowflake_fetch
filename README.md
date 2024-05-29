# Fetch Rewards Analytics Engineering Exercise

## Approach
- setup dbt-core, dbt-snowflake locally 
- create a trial snowflake account
- connect dbt & snowflake
- Saved data in s3 bucket, then
- Create or replace the S3 stage
- Create the staging table
- Copy data into the staging table
- Flatten the raw data in dbt in the source layer
- Deduplicate in the intermediary_staging layer, ready to be converted into a relational data model
- do modeling in fetch_dwh_kimball layer, contains the dimensions and facts
- solve the business problems in the aggregate layer
- finally, use dbt's test-driven design to find data quality issues while modelling

### Model Type
As we don't have conitinuous flowing data with new timestamps, all the model types are either view or table.
In a production setting all of the intermediate and onward models would be incremental 

for source model testing I would have added tests like the below

    schema: schema_name
    loaded_at_field: timestamp_field
    freshness:
      warn_after:
        count: 25
        period: minute
      error_after:
        count: 45
        period: minute
    tables:
      - name: table name
        config:
          tags: ['is_live']
      - name: table_name
        tests:
          - expect_row_values_to_have_data_for_every_n_datepart:
              date_col: timestamp
              date_part: hour
              interval: '{{ var("source_test_interval_size", 1) }}'
              test_start_date: "dateadd(hour, -24, getdate())"
              test_end_date: "date_trunc('hour', getdate())"
              exclusion_seed:
              config:
                severity: warn
                warn_if: ">=3" 
etc...
## Answers

### Q1: Structural Data Model

![fetch_structural_data_model](https://github.com/TANMAYSHARMA/dbt_snowflake_fetch/assets/10876447/ff1905f4-6a60-422a-899f-d692de7140f6)

Validation for data models with built in tests

Validation 

brands_interim
```
(dbt-venv) (base) Tanmays-MacBook-Pro:intermediary_staging tanmay$ dbt build -s brands_interim
14:22:11  Running with dbt=1.8.1
14:22:12  Registered adapter: snowflake=1.8.2
14:22:15  Concurrency: 8 threads (target='dev')
14:22:15  
14:22:15  1 of 19 START sql table model fetch_dbt.brands_interim ......................... [RUN]
14:22:17  1 of 19 OK created sql table model fetch_dbt.brands_interim .................... [SUCCESS 1 in 2.07s]
14:22:17  2 of 19 START test not_null_brands_interim_barcode ............................. [RUN]
14:22:17  3 of 19 START test not_null_brands_interim_brand_code .......................... [RUN]
14:22:17  4 of 19 START test not_null_brands_interim_brand_id ............................ [RUN]
14:22:17  5 of 19 START test not_null_brands_interim_brand_name .......................... [RUN]
14:22:17  6 of 19 START test not_null_brands_interim_category ............................ [RUN]
14:22:17  7 of 19 START test not_null_brands_interim_category_code ....................... [RUN]
14:22:17  8 of 19 START test not_null_brands_interim_cpg_id .............................. [RUN]
14:22:17  9 of 19 START test not_null_brands_interim_cpg_ref ............................. [RUN]
14:22:18  2 of 19 PASS not_null_brands_interim_barcode ................................... [PASS in 0.88s]
14:22:18  10 of 19 START test not_null_brands_interim_is_top_brand ....................... [RUN]
14:22:18  4 of 19 PASS not_null_brands_interim_brand_id .................................. [PASS in 0.96s]
14:22:18  11 of 19 START test unique_brands_interim_barcode .............................. [RUN]
14:22:18  5 of 19 PASS not_null_brands_interim_brand_name ................................ [PASS in 1.00s]
14:22:18  8 of 19 PASS not_null_brands_interim_cpg_id .................................... [PASS in 1.00s]
14:22:18  12 of 19 START test unique_brands_interim_brand_code ........................... [RUN]
14:22:18  13 of 19 START test unique_brands_interim_brand_id ............................. [RUN]
14:22:18  6 of 19 WARN 155 not_null_brands_interim_category .............................. [WARN 155 in 1.01s]
14:22:18  14 of 19 START test unique_brands_interim_brand_name ........................... [RUN]
14:22:18  7 of 19 WARN 650 not_null_brands_interim_category_code ......................... [WARN 650 in 1.08s]
14:22:18  15 of 19 START test unique_brands_interim_category ............................. [RUN]
14:22:18  3 of 19 WARN 234 not_null_brands_interim_brand_code ............................ [WARN 234 in 1.12s]
14:22:18  16 of 19 START test unique_brands_interim_category_code ........................ [RUN]
14:22:18  9 of 19 PASS not_null_brands_interim_cpg_ref ................................... [PASS in 1.52s]
14:22:18  17 of 19 START test unique_brands_interim_cpg_id ............................... [RUN]
14:22:18  10 of 19 WARN 612 not_null_brands_interim_is_top_brand ......................... [WARN 612 in 0.72s]
14:22:18  18 of 19 START test unique_brands_interim_cpg_ref .............................. [RUN]
14:22:18  11 of 19 WARN 7 unique_brands_interim_barcode .................................. [WARN 7 in 0.67s]
14:22:18  19 of 19 START test unique_brands_interim_is_top_brand ......................... [RUN]
14:22:18  15 of 19 WARN 22 unique_brands_interim_category ................................ [WARN 22 in 0.68s]
14:22:18  16 of 19 WARN 10 unique_brands_interim_category_code ........................... [WARN 10 in 0.71s]
14:22:19  13 of 19 PASS unique_brands_interim_brand_id ................................... [PASS in 0.83s]
14:22:19  12 of 19 WARN 3 unique_brands_interim_brand_code ............................... [WARN 3 in 1.05s]
14:22:19  14 of 19 WARN 11 unique_brands_interim_brand_name .............................. [WARN 11 in 1.02s]
14:22:19  18 of 19 WARN 2 unique_brands_interim_cpg_ref .................................. [WARN 2 in 0.51s]
14:22:19  19 of 19 WARN 2 unique_brands_interim_is_top_brand ............................. [WARN 2 in 0.59s]
14:22:19  17 of 19 WARN 100 unique_brands_interim_cpg_id ................................. [WARN 100 in 0.82s]
14:22:19  
14:22:19  Finished running 1 table model, 18 data tests in 0 hours 0 minutes, and 5.67 seconds (5.67s).
14:22:19  Done. PASS=7 WARN=12 ERROR=0 SKIP=0 TOTAL=19

```



Receipts_interim
```
(dbt-venv) (base) Tanmays-MacBook-Pro:intermediary_staging tanmay$ dbt build -s receipts_interim
15:40:29  Running with dbt=1.8.1
15:40:30  Registered adapter: snowflake=1.8.2
15:40:31  Found 7 models, 48 data tests, 6 sources, 834 macros
15:40:31  
15:40:33  Concurrency: 8 threads (target='dev')
15:40:33  
15:40:33  1 of 27 START sql view model fetch_dbt.receipts_interim ........................ [RUN]
15:40:34  1 of 27 OK created sql view model fetch_dbt.receipts_interim ................... [SUCCESS 1 in 1.35s]
15:40:34  2 of 27 START test not_null_receipts_interim_bonus_points_earned ............... [RUN]
15:40:34  3 of 27 START test not_null_receipts_interim_bonus_points_earned_reason ........ [RUN]
15:40:34  4 of 27 START test not_null_receipts_interim_created_at ........................ [RUN]
15:40:34  5 of 27 START test not_null_receipts_interim_finished_at ....................... [RUN]
15:40:34  6 of 27 START test not_null_receipts_interim_modified_at ....................... [RUN]
15:40:34  7 of 27 START test not_null_receipts_interim_points_awarded_at ................. [RUN]
15:40:34  8 of 27 START test not_null_receipts_interim_points_earned ..................... [RUN]
15:40:34  9 of 27 START test not_null_receipts_interim_purchased_date .................... [RUN]
15:40:35  9 of 27 ERROR not_null_receipts_interim_purchased_date ......................... [ERROR in 0.79s]
15:40:35  10 of 27 START test not_null_receipts_interim_purchased_item_count ............. [RUN]
15:40:35  4 of 27 PASS not_null_receipts_interim_created_at .............................. [PASS in 0.80s]
15:40:35  11 of 27 START test not_null_receipts_interim_receipt_id ....................... [RUN]
15:40:35  3 of 27 WARN 575 not_null_receipts_interim_bonus_points_earned_reason .......... [WARN 575 in 0.90s]
15:40:35  12 of 27 START test not_null_receipts_interim_rewards_receipt_status ........... [RUN]
15:40:35  6 of 27 PASS not_null_receipts_interim_modified_at ............................. [PASS in 0.92s]
15:40:35  13 of 27 START test not_null_receipts_interim_scanned_at ....................... [RUN]
15:40:35  5 of 27 FAIL 551 not_null_receipts_interim_finished_at ......................... [FAIL 551 in 1.14s]
15:40:35  14 of 27 START test not_null_receipts_interim_total_spent ...................... [RUN]
15:40:35  2 of 27 WARN 575 not_null_receipts_interim_bonus_points_earned ................. [WARN 575 in 1.27s]
15:40:35  15 of 27 START test not_null_receipts_interim_user_id .......................... [RUN]
15:40:36  10 of 27 WARN 484 not_null_receipts_interim_purchased_item_count ............... [WARN 484 in 0.70s]
15:40:36  16 of 27 START test unique_receipts_interim_bonus_points_earned ................ [RUN]
15:40:36  13 of 27 PASS not_null_receipts_interim_scanned_at ............................. [PASS in 0.79s]
15:40:36  17 of 27 START test unique_receipts_interim_bonus_points_earned_reason ......... [RUN]
15:40:36  12 of 27 PASS not_null_receipts_interim_rewards_receipt_status ................. [PASS in 0.86s]
15:40:36  18 of 27 START test unique_receipts_interim_created_at ......................... [RUN]
15:40:36  11 of 27 PASS not_null_receipts_interim_receipt_id ............................. [PASS in 0.97s]
15:40:36  19 of 27 START test unique_receipts_interim_finished_at ........................ [RUN]
15:40:36  15 of 27 PASS not_null_receipts_interim_user_id ................................ [PASS in 0.60s]
15:40:36  20 of 27 START test unique_receipts_interim_modified_at ........................ [RUN]
15:40:36  7 of 27 FAIL 582 not_null_receipts_interim_points_awarded_at ................... [FAIL 582 in 2.20s]
15:40:36  8 of 27 FAIL 510 not_null_receipts_interim_points_earned ....................... [FAIL 510 in 2.20s]
15:40:36  21 of 27 START test unique_receipts_interim_points_awarded_at .................. [RUN]
15:40:36  22 of 27 START test unique_receipts_interim_points_earned ...................... [RUN]
15:40:37  16 of 27 WARN 10 unique_receipts_interim_bonus_points_earned ................... [WARN 10 in 0.86s]
15:40:37  23 of 27 START test unique_receipts_interim_purchased_date ..................... [RUN]
15:40:37  14 of 27 FAIL 435 not_null_receipts_interim_total_spent ........................ [FAIL 435 in 1.47s]
15:40:37  24 of 27 START test unique_receipts_interim_receipt_id ......................... [RUN]
15:40:37  19 of 27 WARN 14 unique_receipts_interim_finished_at ........................... [WARN 14 in 0.90s]
15:40:37  25 of 27 START test unique_receipts_interim_rewards_receipt_status ............. [RUN]
15:40:37  20 of 27 WARN 14 unique_receipts_interim_modified_at ........................... [WARN 14 in 0.84s]
15:40:37  26 of 27 START test unique_receipts_interim_scanned_at ......................... [RUN]
15:40:37  18 of 27 WARN 9 unique_receipts_interim_created_at ............................. [WARN 9 in 1.04s]
15:40:37  27 of 27 START test unique_receipts_interim_user_id ............................ [RUN]
15:40:37  23 of 27 ERROR unique_receipts_interim_purchased_date .......................... [ERROR in 0.54s]
15:40:37  22 of 27 WARN 41 unique_receipts_interim_points_earned ......................... [WARN 41 in 0.81s]
15:40:37  21 of 27 WARN 13 unique_receipts_interim_points_awarded_at ..................... [WARN 13 in 0.86s]
15:40:37  17 of 27 WARN 9 unique_receipts_interim_bonus_points_earned_reason ............. [WARN 9 in 1.40s]
15:40:38  24 of 27 PASS unique_receipts_interim_receipt_id ............................... [PASS in 0.85s]
15:40:38  25 of 27 WARN 5 unique_receipts_interim_rewards_receipt_status ................. [WARN 5 in 0.81s]
15:40:38  26 of 27 WARN 9 unique_receipts_interim_scanned_at ............................. [WARN 9 in 0.86s]
15:40:38  27 of 27 FAIL 91 unique_receipts_interim_user_id ............................... [FAIL 91 in 0.83s]
15:40:38  
15:40:38  Finished running 1 view model, 26 data tests in 0 hours 0 minutes and 6.49 seconds (6.49s).
15:40:38    compiled code at target/compiled/dbt_snowflake_fetch_exercise/models/intermediary_staging/intermediary_staging.yml/unique_receipts_interim_scanned_at.sql
15:40:38  
15:40:38  Done. PASS=8 WARN=12 ERROR=7 SKIP=0 TOTAL=27

```

Receipt_line_items
```
(dbt-venv) (base) Tanmays-MacBook-Pro:intermediary_staging tanmay$ dbt build -s receipt_line_items
17:42:25  Running with dbt=1.8.1
17:42:25  Registered adapter: snowflake=1.8.2
17:42:27  Found 9 models, 58 data tests, 6 sources, 834 macros
17:42:27  
17:42:28  Concurrency: 8 threads (target='dev')
17:42:28  
17:42:28  1 of 2 START sql table model fetch_dbt.receipt_line_items ...................... [RUN]
17:42:30  1 of 2 OK created sql table model fetch_dbt.receipt_line_items ................. [SUCCESS 1 in 2.23s]
17:42:30  2 of 2 START test not_null_receipt_line_items_receipt_id ....................... [RUN]
17:42:31  2 of 2 PASS not_null_receipt_line_items_receipt_id ............................. [PASS in 0.86s]
17:42:31  
17:42:31  Finished running 1 table model, 1 test in 0 hours 0 minutes and 4.37 seconds (4.37s).
17:42:31  
17:42:31  Completed successfully
17:42:31  
17:42:31  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2

```

Users_interim

```

17:35:24  Running with dbt=1.8.1
17:35:25  Registered adapter: snowflake=1.8.2
17:35:27  Found 9 models, 60 data tests, 6 sources, 834 macros
17:35:27  
17:35:29  Concurrency: 8 threads (target='dev')
17:35:29  
17:35:29  1 of 11 START sql table model fetch_dbt.users_interim .......................... [RUN]
17:35:31  1 of 11 OK created sql table model fetch_dbt.users_interim ..................... [SUCCESS 1 in 1.97s]
17:35:31  2 of 11 START test not_null_users_interim_created_at ........................... [RUN]
17:35:31  3 of 11 START test not_null_users_interim_is_active ............................ [RUN]
17:35:31  4 of 11 START test not_null_users_interim_last_login_at ........................ [RUN]
17:35:31  5 of 11 START test not_null_users_interim_role ................................. [RUN]
17:35:31  6 of 11 START test not_null_users_interim_sign_up_source ....................... [RUN]
17:35:31  7 of 11 START test not_null_users_interim_state ................................ [RUN]
17:35:31  8 of 11 START test not_null_users_interim_user_id .............................. [RUN]
17:35:31  9 of 11 START test unique_users_interim_is_active .............................. [RUN]
17:35:32  3 of 11 PASS not_null_users_interim_is_active .................................. [PASS in 1.13s]
17:35:32  6 of 11 WARN 5 not_null_users_interim_sign_up_source ........................... [WARN 5 in 1.13s]
17:35:32  10 of 11 START test unique_users_interim_sign_up_source ........................ [RUN]
17:35:32  11 of 11 START test unique_users_interim_user_id ............................... [RUN]
17:35:32  2 of 11 PASS not_null_users_interim_created_at ................................. [PASS in 1.15s]
17:35:32  8 of 11 PASS not_null_users_interim_user_id .................................... [PASS in 1.14s]
17:35:32  5 of 11 PASS not_null_users_interim_role ....................................... [PASS in 1.15s]
17:35:32  4 of 11 WARN 40 not_null_users_interim_last_login_at ........................... [WARN 40 in 1.15s]
17:35:32  7 of 11 WARN 6 not_null_users_interim_state .................................... [WARN 6 in 1.50s]
17:35:32  9 of 11 WARN 1 unique_users_interim_is_active .................................. [WARN 1 in 1.49s]
17:35:32  10 of 11 WARN 2 unique_users_interim_sign_up_source ............................ [WARN 2 in 0.62s]
17:35:33  11 of 11 PASS unique_users_interim_user_id ..................................... [PASS in 0.91s]
17:35:33  
17:35:33  Finished running 1 table model, 10 data tests in 0 hours 0 minutes and 5.55 seconds (5.55s).
17:35:33    compiled code at target/compiled/dbt_snowflake_fetch_exercise/models/intermediary_staging/intermediary_staging.yml/unique_users_interim_sign_up_source.sql
17:35:33  
17:35:33  Done. PASS=6 WARN=5 ERROR=0 SKIP=0 TOTAL=11
```
dim_items
```
(dbt-venv) (base) Tanmays-MacBook-Pro:fetch_dwh_kimball tanmay$ dbt build -f -s dim_items
22:27:04  Running with dbt=1.8.1
22:27:05  Registered adapter: snowflake=1.8.2
22:27:06  Found 13 models, 65 data tests, 6 sources, 834 macros
22:27:06  
22:27:08  Concurrency: 8 threads (target='dev')
22:27:08  
22:27:08  1 of 2 START sql table model fetch_dbt.dim_items ............................... [RUN]
22:27:09  1 of 2 OK created sql table model fetch_dbt.dim_items .......................... [SUCCESS 1 in 1.60s]
22:27:09  2 of 2 START test not_null_dim_items_barcode ................................... [RUN]
22:27:10  2 of 2 PASS not_null_dim_items_barcode ......................................... [PASS in 0.89s]
22:27:10  
22:27:10  Finished running 1 table model, 1 test in 0 hours 0 minutes and 4.68 seconds (4.68s).
22:27:10  
22:27:10  Completed successfully
22:27:10  
22:27:10  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2

```


dim_brands
```
(dbt-venv) (base) Tanmays-MacBook-Pro:fetch_dwh_kimball tanmay$ dbt build -s dim_brands
21:45:10  Running with dbt=1.8.1
21:45:11  Registered adapter: snowflake=1.8.2
21:45:11  Found 11 models, 62 data tests, 6 sources, 834 macros
21:45:11  
21:45:13  Concurrency: 8 threads (target='dev')
21:45:13  
21:45:13  1 of 3 START sql table model fetch_dbt.dim_brands .............................. [RUN]
21:45:14  1 of 3 OK created sql table model fetch_dbt.dim_brands ......................... [SUCCESS 1 in 1.66s]
21:45:14  2 of 3 START test not_null_dim_brands_brand_id ................................. [RUN]
21:45:14  3 of 3 START test unique_dim_brands_brand_id ................................... [RUN]
21:45:15  2 of 3 PASS not_null_dim_brands_brand_id ....................................... [PASS in 0.84s]
21:45:15  3 of 3 PASS unique_dim_brands_brand_id ......................................... [PASS in 1.01s]
21:45:15  
21:45:15  Finished running 1 table model, 2 data tests in 0 hours 0 minutes and 4.10 seconds (4.10s).
21:45:15  
21:45:15  Completed successfully
21:45:15  
21:45:15  Done. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3
```

Dim_users
```
(dbt-venv) (base) Tanmays-MacBook-Pro:fetch_dwh_kimball tanmay$ dbt build -s dim_users
21:55:49  Running with dbt=1.8.1
21:55:49  Registered adapter: snowflake=1.8.2
21:55:50  Found 12 models, 64 data tests, 6 sources, 834 macros
21:55:50  
21:55:51  Concurrency: 8 threads (target='dev')
21:55:51  
21:55:51  1 of 3 START sql table model fetch_dbt.dim_users ............................... [RUN]
21:55:53  1 of 3 OK created sql table model fetch_dbt.dim_users .......................... [SUCCESS 1 in 1.55s]
21:55:53  2 of 3 START test not_null_dim_users_user_id ................................... [RUN]
21:55:53  3 of 3 START test unique_dim_users_user_id ..................................... [RUN]
21:55:54  2 of 3 PASS not_null_dim_users_user_id ......................................... [PASS in 0.90s]
21:55:54  3 of 3 PASS unique_dim_users_user_id ........................................... [PASS in 0.97s]
21:55:54  
21:55:54  Finished running 1 table model, 2 data tests in 0 hours 0 minutes and 3.92 seconds (3.92s).
21:55:54  
21:55:54  Completed successfully
21:55:54  
21:55:54  Done. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3

```

Fact_receipts

```
(dbt-venv) (base) Tanmays-MacBook-Pro:fetch_dwh_kimball tanmay$ dbt build -s fact_receipts
22:04:43  Running with dbt=1.8.1
22:04:44  Registered adapter: snowflake=1.8.2
22:04:45  Found 13 models, 66 data tests, 6 sources, 834 macros
22:04:45  
22:04:46  Concurrency: 8 threads (target='dev')
22:04:46  
22:04:46  1 of 3 START sql table model fetch_dbt.fact_receipts ........................... [RUN]
22:04:50  1 of 3 OK created sql table model fetch_dbt.fact_receipts ...................... [SUCCESS 1 in 3.49s]
22:04:50  2 of 3 START test not_null_fact_receipts_receipt_id ............................ [RUN]
22:04:50  3 of 3 START test unique_fact_receipts_receipt_id .............................. [RUN]
22:04:51  3 of 3 PASS unique_fact_receipts_receipt_id .................................... [PASS in 0.98s]
22:04:51  2 of 3 PASS not_null_fact_receipts_receipt_id .................................. [PASS in 1.01s]
22:04:51  
22:04:51  Finished running 1 table model, 2 data tests in 0 hours 0 minutes and 5.89 seconds (5.89s).
22:04:51  
22:04:51  Completed successfully
22:04:51  
22:04:51  Done. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3

```





### Q2: SQL Queries
See queries in the model/aggregate layer

### Q3: Evaluate Data Quality Issues in the Data Provided
Generic Data quality tests are set up in the respective yml files of the model. 

based on manually running queries in the snowflake database to look for data quality issues below are the points i found:
- duplicate user_ids, brand_ids, receipt_ids
- Missing Required Fields
  - missing state, created_at, last_login_at from users table
  - missing rand_name, category, category_code from brands table
  - missing user_id, creatd_at, total_spent from receipts table
- There are referential integrity/ foreign key issues issues between receipts and users, receipts and brands. 
- There are a lot of nulls in the most important attributes ex: brand_names.
- Inconsistencies
  - The is data is inconsistent ex: the same product has multiple brands
  - The sum of individual parts does not equal the totals ex: points earned in individual receipt items that is the array of arrays does not equal to the total points earned across the entire receipt
  - There are receipts with 0 points and 0 items; all receipts should have atleast least 1 item 
  - inactive users with recent login dates
  - abnormally high spend amounts
  - for some brands, BAKEN-ETS appear to be duplicated


### Q4: Communicate with Stakeholders


Data Issues and Questions

Hi Product Leader,

I hope this message finds you well! 

After thoroughly reviewing our datasets, I've identified several data quality issues that require clarification and your assistance. I’ve detailed the findings and questions below.

Data Quality Issues Identified:

Data Completeness

- Duplicate Entries: There are duplicates in user IDs, brand IDs, and receipt IDs.
- Missing Required Fields:
  - Users Table: Missing state, created_at, last_login_at.
  - Brands Table: Missing brand_name, category, category_code.
  - Receipts Table: Missing user_id, created_at, total_spent.
- Referential Integrity Issues: There are foreign key mismatches between receipts and users, and receipts and brands, indicating missing references.

Null Values

- Important Attributes: There are significant null values in critical fields like brand_name.

Inconsistencies

- Product Mapping: The same product is mapped to different brands across various receipts.
- Summation Errors: The sum of points earned in individual receipt items does not match the total points earned in some receipts.
- Empty Receipts: Some receipts show 0 points and 0 items; ideally, every receipt should have at least one item.
- Inactive Users: Some inactive users have recent login dates, which is inconsistent.
- Abnormal Transactions: There are transactions with abnormally high spend amounts.
- Duplicate Brands: Some brands, such as "BAKEN-ETS", appear to be duplicated.

Questions for Clarification

To resolve these issues and optimize our data assets, I have a few questions:

Data Completeness

Missing Data: Please direct me to the right poc to obtain the missing brands and users information in the receipts data?

Data Duplicates and Inconsistencies

Duplicate Entries: Can you please connect me with someone from the business team so that I can educate them to avoid duplicates & inconsistencies

Abnormal Data Points

Transaction Guidelines: Do we have any guidelines on average or maximum spend and points per transaction to identify and address anomalies or outliers?

Thank you for your attention to these matters. 
I look forward to your guidance and support in resolving these issues at the earliest.

Yours Sincerely,
Tanmay Sharma
