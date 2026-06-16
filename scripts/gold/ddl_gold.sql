CREATE OR REPLACE PROCEDURE gold.load_gold()
LANGUAGE plpgsql
AS $$
BEGIN

    --------------------------------------------------------------------
    -- Create Customer Dimension
    -- Объединяет данные клиентов из CRM и ERP систем.
    -- Формирует единое измерение клиентов для аналитики.
    --------------------------------------------------------------------

    RAISE NOTICE 'Creating gold.dim_customers';

    DROP VIEW IF EXISTS gold.dim_customers;

    CREATE VIEW gold.dim_customers AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_number,
        ci.cst_firstname AS firstname,
        ci.cst_lastname AS lastname,
        ci.cst_material_status AS marital_status,
        CASE
            WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
            ELSE COALESCE(ca.gen,'n/a')
        END AS gender,
        ci.cst_create_date AS create_date,
        ca.bdate AS birthdate,
        la.cntry AS country
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
        ON ci.cst_key = la.cid;

    RAISE NOTICE 'gold.dim_customers created';


    --------------------------------------------------------------------
    -- Create Product Dimension
    -- Формирует измерение продуктов с категориями,
    -- подкатегориями и информацией об обслуживании.
    --------------------------------------------------------------------

    RAISE NOTICE 'Creating gold.dim_products';

    DROP VIEW IF EXISTS gold.dim_products;

    CREATE VIEW gold.dim_products AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt) AS product_key,
        pr.prd_id AS product_id,
        pr.prd_key AS product_number,
        pr.prd_nm AS product_name,
        pr.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pr.prd_cost AS product_cost,
        pr.prd_line AS product_line,
        pr.prd_start_dt AS start_date,
        pc.maintenance
    FROM silver.crm_prd_info AS pr
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
        ON pr.cat_id = pc.id
    WHERE pr.prd_end_dt IS NULL;

    RAISE NOTICE 'gold.dim_products created';


    --------------------------------------------------------------------
    -- Create Sales Fact Table
    -- Формирует таблицу фактов продаж.
    -- Связывает продажи с измерениями клиентов и продуктов.
    --------------------------------------------------------------------

    RAISE NOTICE 'Creating gold.fact_sales';

    DROP VIEW IF EXISTS gold.fact_sales;

    CREATE VIEW gold.fact_sales AS
    SELECT
        sl.sls_ord_num AS order_number,
        pr.product_key,
        cs.customer_key,
        sl.sls_order_dt AS order_date,
        sl.sls_ship_dt AS ship_date,
        sl.sls_due_dt AS due_date,
        sl.sls_sales AS sales,
        sl.sls_quantity AS quantity,
        sl.sls_price AS price
    FROM silver.crm_sales_details AS sl
    LEFT JOIN gold.dim_products AS pr
        ON sl.sls_prd_key = pr.product_number
    LEFT JOIN gold.dim_customers AS cs
        ON sl.sls_cust_id = cs.customer_id;

    RAISE NOTICE 'gold.fact_sales created';

    RAISE NOTICE 'Gold Layer loaded successfully';

END;
$$;
