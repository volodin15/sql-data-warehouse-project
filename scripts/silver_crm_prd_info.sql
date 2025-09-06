truncate table silver.crm_prd_info;
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
from bronze.crm_prd_info



