/*
=================================================
Create bronze table for all data sources
=================================================
*/

DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id integer,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date
);

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id integer,
	prd_key varchar(50),
	prd_nm integer,
	prd_cost integer,
	prd_line integer,
	prd_start_dt date,
	prd_end_dt date
);


DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num integer,
	sls_prd_key varchar(50),
	sls_cust_id integer,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales integer,
	sls_quantity integer,
	sls_price integer
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid varchar(50),
	bdate date,
	gen varchar(50)
);

DROP TABLE IF EXISTS bronze.erp_lock_a101;
CREATE TABLE bronze.erp_lock_a101(
	cid varchar(50),
	cntry varchar(50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id varchar(50),
	cat varchar(50),
	subcat varchar(50),
	maintenance varchar(50)
);



