/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Check for nulls or duplicate in primary key
-- Expectations: No result

select
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null



-- Check unwanted spaces
-- Expectation : No results

select prd_nm
from silver.crm_prd_info
where prd_nm <> trim(prd_nm)


-- Data Standardization & Consistency
select distinct prd_line
from silver.crm_prd_info

select *
from bronze.crm_prd_info

-- check null or negative numbers
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- Check for valid dates
select
nullif(sls_due_dt,0) sls_due_dt
from bronze.crm_sales_details
where  sls_due_dt <= 0 or len(sls_due_dt) <> 8 

select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,

case 
	when sls_sales is null or sls_sales <= 0 or sls_sales <> sls_quantity * abs(sls_price)
	then sls_quantity * abs(sls_price)
else sls_sales
end sls_sales,
case 
	when sls_price is null or sls_price <= 0
	then sls_sales / nullif(sls_quantity, 0)
else sls_price
end sls_price
from bronze.crm_sales_details


--check for invalid dates
select *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


