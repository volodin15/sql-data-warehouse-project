CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
BEGIN   
	/*
	temp link for file in local MinIO
	need to update pg container and install curl to make it work
	*/
	RAISE NOTICE '=====================================';
	RAISE NOTICE 'Loading Silver Layer';
	RAISE NOTICE '=====================================';

	RAISE NOTICE '-------------------------------------';
	RAISE NOTICE 'Loading CRM';
	RAISE NOTICE '-------------------------------------';
	
	RAISE NOTICE 'Truncating Table >> silver.crm_cust_info';
	truncate table silver.crm_cust_info;
	RAISE NOTICE 'Tranforming Data into >> silver.crm_cust_info';
	insert into silver.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
	select
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case
			when upper(trim(cst_marital_status)) = 'S' then 'Single'
			when upper(trim(cst_marital_status)) = 'M' then 'Married'
			else 'n/a'
		end as cst_marital_status,
		case
			when upper(trim(cst_gndr)) = 'F' then 'Female'
			when upper(trim(cst_gndr)) = 'M' then 'Male'
			else 'n/a'
		end as cst_gndr,
		cst_create_date
	from (
		select *,
		row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
	)t where flag_last = 1 ;

	RAISE NOTICE 'Truncating Table >> silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	RAISE NOTICE 'Tranforming Data into >> silver.crm_prd_info';
	insert into silver.crm_prd_info(prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
	select 
		prd_id,
		replace(substring(prd_key,1,5), '-','_') as cat_id,
		substring(prd_key, 7,length(prd_key)) as prd_key,
		prd_nm,
		COALESCE(prd_cost,0) as prd_cost,
		case upper(trim(prd_line))
		  when 'R' then 'Road'
		  when 'M' then 'Mountain'
		  when 'S' then 'other Sales'
		  when 'T' then 'Touring'
		  else 'n/a'
		end as prd_line,
		cast(prd_start_dt as date) as prd_start_dt,
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	from bronze.crm_prd_info;

	RAISE NOTICE 'Truncating Table >> silver.crm_sales_details';	
	truncate table silver.crm_sales_details;
	RAISE NOTICE 'Tranforming Data into >> silver.crm_sales_details';
	insert into silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
	SELECT sls_ord_num, 
		   sls_prd_key, 
		   sls_cust_id, 
		   case when length(sls_order_dt)!=8  then null
		   	else cast(sls_order_dt as date)
			end as sls_order_dt, 
		   	case when length(sls_ship_dt)!=8  then null
		   	else cast(sls_ship_dt as date)
			end as sls_ship_dt,
		   case when length(sls_due_dt)!=8  then null
		   	else cast(sls_due_dt as date)
			end as sls_due_dt,
		   case when sls_sales is null or sls_sales<=0 or sls_sales != sls_quantity*abs(sls_price)
		   		then sls_quantity*abs(sls_price)
				else 	sls_sales
			end as sls_sales,
		   sls_quantity,
		   case when sls_price is null or sls_price<=0 
		   		then sls_sales/nullif(sls_quantity,0)
				else sls_price
			end as sls_price
		FROM bronze.crm_sales_details;

	RAISE NOTICE '-------------------------------------';
	RAISE NOTICE 'Loading ERP';
	RAISE NOTICE '-------------------------------------';
	
	RAISE NOTICE 'Truncating Table >> silver.erp_cust_az12';	
	truncate table silver.erp_cust_az12;
	RAISE NOTICE 'Tranforming Data into >> silver.erp_cust_az12';
	INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
	select case when cid like 'NAS%' then substring(cid, 4, length(cid))
			else cid
			end as cid, 
		   case when bdate > CURRENT_DATE then null
				else bdate
			end as bdate, 
			case 
				when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
				when upper(trim(gen)) in ('M', 'MALE') then 'Male'
				else 'n/a'
			end as gen		
	from bronze.erp_cust_az12;
	
	RAISE NOTICE 'Truncating Table >> silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	RAISE NOTICE 'Tranforming Data into >> silver.erp_loc_a101';	
	INSERT INTO silver.erp_loc_a101(cid, cntry)
	SELECT replace(cid,'-','') as cid, 
		   case when trim(cntry) = 'DE' then 'Germany'
		   		when trim(cntry) in ('USA', 'US') then 'United States'
				when trim(cntry)='' or cntry is null then 'n/a'
				else trim(cntry)
			end as cntry
		FROM bronze.erp_loc_a101;
		
	RAISE NOTICE 'Truncating Table >> silver.erp_px_cat_g1v2';
	truncate table silver.erp_px_cat_g1v2;
	RAISE NOTICE 'Tranforming Data into >> silver.erp_px_cat_g1v2';	
	INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
	SELECT id, 
		   cat, 
		   subcat, 
		   maintenance
		FROM bronze.erp_px_cat_g1v2;
	

END;
$$;

--call silver.load_silver();
