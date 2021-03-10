CREATE OR REPLACE VIEW monthly_bill_by_account_apptag AS 
SELECT
  "bill_billing_period_start_date"
, "bill_payer_account_id"
, "line_item_usage_account_id"
, "resource_tags_user_application"
, (CASE WHEN ("product_product_name" LIKE '') THEN "customer_all"."line_item_product_code" ELSE "product_product_name" END) "product_product_name"
, "round"("sum"("line_item_unblended_cost"), 2) "unblended_cost"
, "round"("sum"((CASE WHEN ("line_item_line_item_type" = 'SavingsPlanCoveredUsage') THEN "savings_plan_savings_plan_effective_cost" WHEN ("line_item_line_item_type" = 'SavingsPlanRecurringFee') THEN ("savings_plan_total_commitment_to_date" - "savings_plan_used_commitment") WHEN ("line_item_line_item_type" = 'SavingsPlanNegation') THEN 0 WHEN ("line_item_line_item_type" = 'SavingsPlanUpfrontFee') THEN 0 WHEN ("line_item_line_item_type" = 'DiscountedUsage') THEN "reservation_effective_cost" WHEN ("line_item_line_item_type" = 'RIFee') THEN ("reservation_unused_amortized_upfront_fee_for_billing_period" + "reservation_unused_recurring_fee") WHEN (("line_item_line_item_type" = 'Fee') AND ("reservation_reservation_a_r_n" <> '')) THEN 0 ELSE "line_item_unblended_cost" END)), 2) "amortized_cost"
FROM
  customer_cur_data.customer_all
GROUP BY 1, 2, 3, 4, 5
LIMIT 10