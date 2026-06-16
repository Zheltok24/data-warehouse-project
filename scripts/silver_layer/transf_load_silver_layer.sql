CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
BEGIN

    -- crm_cust_info
    RAISE NOTICE 'loading silver.crm_cust_info';

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(cst_material_status) = 'S' THEN 'Single'
            WHEN UPPER(cst_material_status) = 'M' THEN 'Married'
        END,
        CASE
            WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
            WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM bronze.crm_cust_info;

    RAISE NOTICE 'silver.crm_cust_info load completed';


    -- crm_prd_info
    RAISE NOTICE 'loading silver.crm_prd_info';

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
        SUBSTRING(prd_key,7,LENGTH(prd_key)),
        prd_nm,
        COALESCE(prd_cost,0),
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        CAST(prd_start_dt AS DATE),
        CAST(
            LEAD(prd_start_dt)
                OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
            AS DATE
        ) - 1
    FROM bronze.crm_prd_info;

    RAISE NOTICE 'silver.crm_prd_info load completed';


    -- crm_sales_details
    RAISE NOTICE 'loading silver.crm_sales_details';

    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) <> 8
            THEN NULL
            ELSE TO_DATE(CAST(sls_order_dt AS VARCHAR), 'YYYYMMDD')
        END,
        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) <> 8
            THEN NULL
            ELSE TO_DATE(CAST(sls_ship_dt AS VARCHAR), 'YYYYMMDD')
        END,
        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) <> 8
            THEN NULL
            ELSE TO_DATE(CAST(sls_due_dt AS VARCHAR), 'YYYYMMDD')
        END,
        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze.crm_sales_details;

    RAISE NOTICE 'silver.crm_sales_details load completed';


    -- erp_cust_az12
    RAISE NOTICE 'loading silver.erp_cust_az12';

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4)
            ELSE cid
        END,
        CASE
            WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
        END,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;

    RAISE NOTICE 'silver.erp_cust_az12 load completed';


    -- erp_loc_a101
    RAISE NOTICE 'loading silver.erp_loc_a101';

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid,'-',''),
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
            WHEN COALESCE(TRIM(cntry),'') = '' THEN 'n/a'
            ELSE cntry
        END
    FROM bronze.erp_loc_a101;

    RAISE NOTICE 'silver.erp_loc_a101 load completed';


    -- erp_px_cat_g1v2
    RAISE NOTICE 'loading silver.erp_px_cat_g1v2';

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    RAISE NOTICE 'silver.erp_px_cat_g1v2 load completed';

END;
$$;

