truncate table silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(cid, cntry)
SELECT replace(cid,'-','') as cid, 
	   case when trim(cntry) = 'DE' then 'Germany'
	   		when trim(cntry) in ('USA', 'US') then 'United States'
			when trim(cntry)='' or cntry is null then 'n/a'
			else trim(cntry)
		end as cntry
	FROM bronze.erp_loc_a101;
