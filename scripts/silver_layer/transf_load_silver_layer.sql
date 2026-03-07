-- Transform and load data to silver layer --
INSERT INTO silver.crm_cust_info(
	cst_id ,
	cst_key ,
	cst_firstname ,
	cst_lastname ,
	cst_material_status ,
	cst_gndr ,
	cst_create_date 
)
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(cst_material_status) = 'S' THEN 'Single'
	WHEN UPPER(cst_material_status) = 'M' THEN 'Married'
END AS cst_material_status,
CASE WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
	WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
END AS cst_gndr,
cst_create_date
FROM bronze.crm_cust_info;


INSERT INTO silver.crm_prd_info(
	prd_id ,
	cat_id ,
	prd_key ,
	prd_nm ,
	prd_cost ,
	prd_line ,
	prd_start_dt ,
	prd_end_dt
)
SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
prd_nm,
COALESCE(prd_cost,0) AS prd_cost,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt,
CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) -1 AS prd_end_dt 
FROM bronze.crm_prd_info;


INSERT INTO silver.crm_prd_info(
    sls_ord_num     ,
    sls_prd_key     ,
    sls_cust_id     ,
    sls_order_dt    ,
    sls_ship_dt     ,
    sls_due_dt      ,
    sls_sales       ,
    sls_quantity    ,
    sls_price       
)
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE 
	WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE 
	WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE 
	WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales, 
sls_quantity,
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price  
END AS sls_price
FROM bronze.crm_sales_details;
