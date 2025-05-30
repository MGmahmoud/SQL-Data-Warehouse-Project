


---------------- Load & Transform crm_cust_info ----------------

Insert into silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
select 
cst_id,
cst_key,
Trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case	when upper(trim(cst_marital_status)) = 'M' then 'Married'
		when upper(trim(cst_marital_status)) = 'S' then 'Single'
		Else 'n/a'
end as cst_marital_status,
case	when upper(trim(cst_gndr)) = 'M' then 'Male'
		when upper(trim(cst_gndr)) = 'F' then 'Female'
		Else 'n/a'
end as cst_gndr,
cst_create_date
from
(select
*,
ROW_NUMBER() over (partition by cst_id order by cst_create_date) as flag_last
from bronze.crm_cust_info
where cst_id is not NULL
) t
where flag_last = 1

---------------- Load & Transform crm_prd_info ----------------
Insert into silver.crm_prd_info
(
    prd_id              ,
    prd_key             ,
	prd_cat_id			,
    prd_nm              ,
    prd_cost            ,
    prd_line            ,
    prd_start_dt        ,
    prd_end_dt          
)
Select
prd_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') as prd_cat_id,
prd_nm,
isnull(prd_cost,0) as prd_cost,
case upper(trim(prd_line))
when 'M' then 'Mountain'
when 'R' then 'Road'
when 'S' then 'Other Sales'
when 'T' then 'Touring'
else 'n/a'
end as prd_line,
prd_start_dt,
Dateadd(day, -1,lead(prd_start_dt) over (partition by prd_key order by prd_start_dt Asc) ) as prd_end_dt
from bronze.crm_prd_info

