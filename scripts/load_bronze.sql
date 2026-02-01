--- Create table from csv bronze_level ---

DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_material_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt   TIMESTAMP
);



DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);



DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);



DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);

--- Copy from csv to tables bronze_level ---

copy bronze.crm_cust_info (cst_id,
	cst_key,
	cst_firstname ,
	cst_lastname ,
	cst_material_status,
	cst_gndr ,
	cst_create_date)
FROM 'D:\Lessons_py\source_crm\cust_info.csv'
DELIMITER ','
CSV HEADER;

copy bronze.crm_prd_info (prd_id,
    prd_key      ,
    prd_nm       ,
    prd_cost     ,
    prd_line     ,
    prd_start_dt ,
    prd_end_dt   )
FROM 'D:\Lessons_py\source_crm\prd_info.csv'
DELIMITER ','
CSV HEADER;

copy bronze.crm_sales_details (sls_ord_num,
    sls_prd_key  ,
    sls_cust_id  ,
    sls_order_dt ,
    sls_ship_dt  ,
    sls_due_dt   ,
    sls_sales    ,
    sls_quantity ,
    sls_price    )
FROM 'D:\Lessons_py\source_crm\sales_details.csv'
DELIMITER ','
CSV HEADER;


copy bronze.erp_loc_a101 (
    cid    ,
    cntry 
)
FROM 'D:\Lessons_py\source_erp\loc_a101.csv'
DELIMITER ','
CSV HEADER;

copy bronze.erp_cust_az12 (
    cid    ,
    bdate  ,
    gen    
)
FROM 'D:\Lessons_py\source_erp\cust_az12.csv'
DELIMITER ','
CSV HEADER;

copy  bronze.erp_px_cat_g1v2 (
    id          ,
    cat          ,
    subcat       ,
    maintenance  
)
FROM 'D:\Lessons_py\source_erp\px_cat_g1v2.csv'
DELIMITER ','
CSV HEADER;
