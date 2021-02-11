CREATE OR REPLACE VIEW monthly_bill_by_account_apptag AS 
SELECT
  "bill_billing_period_start_date"
, "bill_payer_account_id"
, "payer_account_name"
, "line_item_usage_account_id"
, "account_name"
, "resource_tags_user_application"
, (CASE WHEN ("product_product_name" LIKE '') THEN "customer_all"."line_item_product_code" ELSE "product_product_name" END) "product_product_name"
, (CASE WHEN (("aws_service_category" IS NULL) AND ("product_product_name" IS NOT NULL)) THEN "product_product_name" WHEN (("aws_service_category" IS NULL) AND ("customer_all"."product_product_name" IS NULL)) THEN 'Other' ELSE "aws_service_category" END) "aws_service_category"
, "product_region"
, TRY_CAST("region_latitude" AS decimal) "region_latitude"
, TRY_CAST("region_longitude" AS decimal) "region_longitude"
, "round"("sum"("line_item_unblended_cost"), 2) "unblended_cost"
, "round"("sum"((CASE WHEN ("line_item_line_item_type" = 'SavingsPlanCoveredUsage') THEN "savings_plan_savings_plan_effective_cost" WHEN ("line_item_line_item_type" = 'SavingsPlanRecurringFee') THEN ("savings_plan_total_commitment_to_date" - "savings_plan_used_commitment") WHEN ("line_item_line_item_type" = 'SavingsPlanNegation') THEN 0 WHEN ("line_item_line_item_type" = 'SavingsPlanUpfrontFee') THEN 0 WHEN ("line_item_line_item_type" = 'DiscountedUsage') THEN "reservation_effective_cost" WHEN ("line_item_line_item_type" = 'RIFee') THEN ("reservation_unused_amortized_upfront_fee_for_billing_period" + "reservation_unused_recurring_fee") WHEN (("line_item_line_item_type" = 'Fee') AND ("reservation_reservation_a_r_n" <> '')) THEN 0 ELSE "line_item_unblended_cost" END)), 2) "amortized_cost"
FROM
  ((((cur_file
LEFT JOIN customer_cur_data.payer_account_name_map ON ("customer_all"."bill_payer_account_id" = "payer_account_name_map"."account_id"))
LEFT JOIN customer_cur_data.aws_accounts ON ("customer_all"."line_item_usage_account_id" = "aws_accounts"."account_id"))
LEFT JOIN customer_cur_data.aws_regions ON ("customer_all"."product_region" = "aws_regions"."region_name"))
LEFT JOIN customer_cur_data.aws_service_category_map ON ("customer_all"."line_item_product_code" = "aws_service_category_map"."line_item_product_code"))
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11