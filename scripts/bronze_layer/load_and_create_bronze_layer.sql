CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE 'Loading crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    COPY bronze.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gndr,
        cst_create_date
    )
    FROM '/datasets/source_crm/cust_info.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'crm_cust_info loaded';


    RAISE NOTICE 'Loading crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    COPY bronze.crm_prd_info (
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    FROM '/datasets/source_crm/prd_info.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'crm_prd_info loaded';


    RAISE NOTICE 'Loading crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    COPY bronze.crm_sales_details (
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
    FROM '/datasets/source_crm/sales_details.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'crm_sales_details loaded';


    RAISE NOTICE 'Loading erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    COPY bronze.erp_loc_a101 (
        cid,
        cntry
    )
    FROM '/datasets/source_erp/loc_a101.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'erp_loc_a101 loaded';


    RAISE NOTICE 'Loading erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    COPY bronze.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    FROM '/datasets/source_erp/cust_az12.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'erp_cust_az12 loaded';


    RAISE NOTICE 'Loading erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    COPY bronze.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    FROM '/datasets/source_erp/px_cat_g1v2.csv'
    DELIMITER ','
    CSV HEADER;

    RAISE NOTICE 'erp_px_cat_g1v2 loaded';

END;
$$;


