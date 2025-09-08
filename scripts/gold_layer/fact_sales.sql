create view gold.fact_sales as
SELECT 
	sd.sls_ord_num as order_number, 
	pr.product_key as product_key,
	cs.customer_key as customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr on (sd.sls_prd_key = pr.product_number)
left join gold.dim_customers cs on (sd.sls_cust_id = cs.customer_id)
