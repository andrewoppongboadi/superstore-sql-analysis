-- ============================================================
-- SUPERSTORE SALES ANALYSIS PROJECT
-- Data Cleaning, Validation, and Business Insights
-- Andrew Boadi
-- ============================================================

USE superstore;

-- ============================================================
-- 1. DATA VALIDATION
-- Purpose: Check data quality before analysis.
-- This includes row counts, duplicates, missing values, date validity,
-- and referential checks across the normalized tables.
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM superstore_table;


SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS total_products FROM products;

SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_sales_rows FROM fact_sales;

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    row_id,
    COUNT(*) AS duplicate_count
FROM fact_sales
GROUP BY row_id
HAVING COUNT(*) > 1;

SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS missing_row_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS missing_sales
FROM fact_sales;

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS missing_segment
FROM customers;

SELECT
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region
FROM orders;



-- ============================================
-- EXECUTIVE OVERVIEW
-- ============================================
SELECT 
count(DISTINCT order_id) AS total_orders
FROM orders;

SELECT 
sum(sales) AS total_revenue
FROM fact_sales;

SELECT 
count(Distinct customer_id) AS total_customer
FROM customers;

WITH B_I AS 
(
SELECT
sum(sales) AS total_revenue,
count(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN fact_sales fs
ON fs.order_id = o.order_id
)
SELECT
total_revenue,
total_orders,
ROUND(total_revenue/total_orders,2) as avg_order_value
FROM B_I;

WITH B_I AS 
(
SELECT
sum(sales) AS total_revenue,
count(DISTINCT c.customer_id) AS unique_customers
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN fact_sales fs
ON fs.order_id = o.order_id
)
SELECT
total_revenue,
unique_customers,
ROUND(total_revenue/unique_customers,2) as revenue_per_customer
FROM B_I;
-- ======================================
-- Section 1: TIME ANALYSIS
-- ======================================
-- Q1
-- REVENUE BY YEAR
-- PURPOSE
-- Identifies whether the business is growing or declining
SELECT
    YEAR(o.order_date) AS YEAR,
    ROUND(SUM(fs.sales), 2) AS total_revenue
FROM fact_sales fs
JOIN orders o
    ON fs.order_id = o.order_id
GROUP BY
    YEAR(o.order_date)
ORDER BY
    total_revenue DESC;

-- Q2:
-- YEAR ON YEAR GROWTH
-- PURPOSE:
-- Shows how much revenue increased or decreased compared to the previous year.
-- Method: Uses LAG() to compare each year with the previous year.
    WITH annual_sales AS (
    SELECT
        YEAR(o.order_date) AS order_year,
        SUM(fs.sales) AS sales
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    GROUP BY YEAR(o.order_date)
),

with_previous_year AS (
    SELECT
        order_year,
        sales,
        LAG(sales) OVER (ORDER BY order_year) AS previous_year_sales
    FROM annual_sales
)

SELECT
    order_year,
    ROUND(sales,2) AS sales,
    ROUND(
        100 * (sales - previous_year_sales)
        / previous_year_sales,
        2
    ) AS yoy_growth_pct
FROM with_previous_year
ORDER BY order_year;

-- REVENUE BY MONTH (YEAR - MONTH)
-- How does revenne change month by month within each year?
-- PURPOSE
-- Helps identify seasonal patterns.
SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(fs.sales) AS total_revenue
FROM fact_sales fs
JOIN orders o
    ON fs.order_id = o.order_id
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    order_year,
    order_month;

-- Question:
-- Which year-month combinations generated the higest revenue?
-- Purpose:
-- Identifies the strongest individual sales
-- TOP 5 MONTHLY REVENUE
With monthly_revenue as (
SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(fs.sales) AS total_revenue
FROM fact_sales fs
JOIN orders o
    ON fs.order_id = o.order_id
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    order_year,
    order_month
)
SELECT *
FROM monthly_revenue
ORDER BY total_revenue DESC
LIMIT 5;
-- Question:
-- Which calendar months generate the most revenue across all years?
-- Purpose:
-- Highlights seasonal demand patterns by comparing month-level revenue aggregated across the full dataset.
-- REVENUE BY CALENDER MONTH (ALL YEARS)
SELECT
    MONTH(o.order_date) AS month_num,
    MONTHNAME(o.order_date) AS month_name,
    ROUND(SUM(fs.sales), 2) AS total_revenue
FROM fact_sales fs
JOIN orders o
    ON fs.order_id = o.order_id
GROUP BY
    MONTH(o.order_date),
    MONTHNAME(o.order_date)
ORDER BY
    total_revenue DESC;
    
-- ============================
-- Section 2: CATEGORY/PRODUCT ANALYSIS
-- ============================
-- Question:
-- Which product category generates the most revenue?
-- Purpose:
-- Identifies the highest-performing product category and sets the baseline
-- for deeper sub-category and product-level analysis.
WITH cr as(
SELECT
    p.category,
    ROUND(SUM(fs.sales), 2) AS category_revenue
FROM fact_sales fs
JOIN products p
    ON fs.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC
),
tr as (
SELECT 
sum(category_revenue) as total_revenue
FROM cr
)
SELECT
category,
category_revenue,
total_revenue,
ROUND(category_revenue/total_revenue * 100, 2) as share_of_total_revenue
FROM cr
CROSS JOIN tr
ORDER BY share_of_total_revenue;

-- YEAR BASIS
-- Question:
-- What share of each year's revenue came from each product category?
-- Purpose:
-- Tracks whether the revenue mix across Technology, Furniture, and Office Supplies changed over time.
WITH cyr as(
SELECT
    p.category,
    YEAR(o.order_date) as year_ordered,
    ROUND(SUM(fs.sales), 2) AS category_year_revenue
FROM fact_sales fs
JOIN products p
    ON fs.product_id = p.product_id
JOIN orders o
	ON fs.order_id = o.order_id
GROUP BY p.category, YEAR(o.order_date)
ORDER BY category_year_revenue DESC
),

tr as (
SELECT 
year_ordered,
sum(category_year_revenue) as total_revenue
FROM cyr
GROUP BY year_ordered
)
SELECT
category,
cyr.year_ordered,
category_year_revenue,
total_revenue,
ROUND(category_year_revenue/total_revenue * 100, 2) as share_of_total_revenue
FROM cyr
JOIN tr
on cyr.year_ordered = tr.year_ordered
ORDER BY year_ordered asc, share_of_total_revenue desc;


-- sub-category analysis
-- Question:
-- What share of each year's revenue came from each product category?
-- Purpose:
-- Tracks whether the revenue mix across Technology, Furniture, and Office Supplies changed over time.
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(fs.sales), 2) AS total_revenue
FROM fact_sales fs
JOIN products p
    ON fs.product_id = p.product_id
GROUP BY p.category,p.sub_category
ORDER BY total_revenue DESC;

-- Question:
-- What share of Technology revenue comes from each Technology sub-category?
-- Purpose:
-- Identifies whether Technology revenue is concentrated in one sub-category
-- or spread across Phones, Machines, Accessories, and Copiers.
WITH tech_subcategory_revenue AS (
    SELECT
        p.category,
        p.sub_category,
        SUM(fs.sales) AS subcategory_revenue
    FROM fact_sales fs
    JOIN products p
        ON fs.product_id = p.product_id
    WHERE p.category = 'Technology'
    GROUP BY
        p.category,
        p.sub_category
),

tech_total AS (
    SELECT
        SUM(subcategory_revenue) AS technology_revenue
    FROM tech_subcategory_revenue
)

SELECT
    tsr.category,
    tsr.sub_category,
    ROUND(tsr.subcategory_revenue, 2) AS subcategory_revenue,
    ROUND(tt.technology_revenue, 2) AS technology_revenue,
    ROUND(100 * tsr.subcategory_revenue / tt.technology_revenue, 2) AS share_of_technology_revenue
FROM tech_subcategory_revenue tsr
CROSS JOIN tech_total tt
ORDER BY share_of_technology_revenue DESC;

-- Question:
-- Which individual Technology products generated the most revenue?
-- Purpose:
-- Identifies the top products behind Technology revenue after Phones were found
-- to be the strongest Technology sub-category.
SELECT
    p.category,
    p.product_name,
    ROUND(SUM(fs.sales), 2) AS total_revenue
FROM fact_sales fs
JOIN products p
    ON fs.product_id = p.product_id
    WHERE category = 'technology'
GROUP BY p.category,p.product_name
ORDER BY total_revenue DESC
limit 5;

-- Question:
-- Which individual Technology products generated the most revenue?
-- Purpose:
-- Identifies the top products behind Technology revenue after Phones were found
-- to be the strongest Technology sub-category.
WITH tech_products AS (
SELECT
        p.product_name,
        SUM(fs.sales) AS product_revenue
    FROM fact_sales fs
    JOIN products p
        ON fs.product_id = p.product_id
    WHERE p.category = 'Technology'
    GROUP BY p.product_name
),

tech_total AS (
    SELECT
        SUM(product_revenue) AS technology_revenue
    FROM tech_products
)

SELECT
    tp.product_name,
    ROUND(tp.product_revenue, 2) AS product_revenue,
    technology_revenue,
    ROUND(
	    100 * tp.product_revenue / tt.technology_revenue,
        2
    ) AS share_of_technology_revenue
FROM tech_products tp
CROSS JOIN tech_total tt
ORDER BY product_revenue DESC
LIMIT 5;

-- Question:
-- Which individual Technology products contribute the most to Technology revenue?
-- Purpose:
-- Measures whether Technology revenue is driven by a few high-performing products
-- or spread across multiple products.
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(fs.sales), 2) AS total_revenue
FROM fact_sales fs
JOIN products p
    ON fs.product_id = p.product_id
GROUP BY
    p.category,
    p.sub_category
ORDER BY
    total_revenue DESC;

-- ==============================
-- Section 3: REGION ANALYSIS
-- ==============================
-- Question:
-- Which regions generate the most revenue, and what share of total revenue does each region represent?
-- Purpose:
-- Establishes the geographic revenue distribution and identifies the strongest regional markets.
WITH region_revenue as
(
SELECT
	region,
    sum(sales) as region_revenue
FROM orders o
JOIN fact_sales fs
	ON o.order_id = fs.order_id
GROUP BY region
ORDER BY sum(sales) DESC 
),
total_revenue as (
 SELECT
sum(region_revenue) as total_revenue
FROM region_revenue
)
SELECT
region,
region_revenue,
total_revenue,
ROUND(region_revenue/total_revenue * 100, 2) AS region_percentage_share
FROM region_revenue
CROSS JOIN total_revenue
ORDER BY total_revenue,
ROUND(region_revenue/total_revenue * 100, 2) DESC;

-- Question:
-- Which regions generated the most revenue in each year?
-- Purpose:
-- Compares annual regional performance and checks whether the West's overall lead
-- was consistent across years.
SELECT
    YEAR(o.order_date) AS order_year,
    o.region,
    ROUND(SUM(fs.sales), 2) AS annual_region_revenue
FROM fact_sales AS fs
JOIN orders AS o
    ON fs.order_id = o.order_id
GROUP BY
    YEAR(o.order_date),
    o.region
ORDER BY
    order_year,
    annual_region_revenue DESC;
    
-- Question:
-- Which states generate the most revenue within each region?
-- Purpose:
-- Identifies the leading states inside each region and shows whether regional
-- performance is concentrated in a few major states.
-- Method:
-- Uses RANK() partitioned by region to rank states separately within each region.
WITH state_revenue AS (
    SELECT
        o.region,
        o.state,
        SUM(fs.sales) AS state_revenue
    FROM fact_sales AS fs
    JOIN orders AS o
        ON fs.order_id = o.order_id
    GROUP BY
        o.region,
        o.state
)
SELECT
    region,
    state,
    ROUND(state_revenue, 2) AS state_revenue,
    RANK() OVER (
        PARTITION BY region
        ORDER BY state_revenue DESC
    ) AS state_rank
FROM state_revenue
ORDER BY
    region,
    state_rank;
    
-- Question:
-- How concentrated is West region revenue across its states?
-- Purpose:
-- Investigates whether the West's strong overall performance is broadly distributed
-- or mainly driven by one state.
WITH western_state_revenue AS (
    SELECT
        o.region,
        o.state,
        SUM(fs.sales) AS state_revenue
    FROM fact_sales AS fs
    JOIN orders AS o
        ON fs.order_id = o.order_id
    WHERE o.region = 'West'
    GROUP BY
        o.region,
        o.state
),
western_total_revenue AS (
    SELECT
        SUM(state_revenue) AS region_revenue
    FROM western_state_revenue
)
SELECT
    wsr.region,
    wsr.state,
    ROUND(wsr.state_revenue, 2) AS state_revenue,
    ROUND(wtr.region_revenue, 2) AS region_revenue,
    ROUND(
        wsr.state_revenue / wtr.region_revenue * 100,
        2
    ) AS share_of_region_revenue
FROM western_state_revenue AS wsr
CROSS JOIN western_total_revenue AS wtr
ORDER BY share_of_region_revenue DESC;

-- Question:
-- Which product categories drive California's revenue?
-- Purpose:
-- Since California accounts for most West region revenue, this query checks
-- whether California's strength is driven by one category or spread across categories.
WITH california_category_revenue AS (
    SELECT
        o.state,
        p.category,
        ROUND(SUM(fs.sales), 2) AS category_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN products p
        ON fs.product_id = p.product_id
    WHERE o.state = 'California'
    GROUP BY o.state, p.category
),

california_total_revenue AS (
    SELECT
        ROUND(SUM(category_revenue), 2) AS california_total_revenue
    FROM california_category_revenue
)

SELECT
    ccr.state,
    ccr.category,
    ccr.category_revenue,
    ctr.california_total_revenue,
    ROUND(ccr.category_revenue / ctr.california_total_revenue * 100, 2) AS share_of_california_revenue
FROM california_category_revenue ccr
CROSS JOIN california_total_revenue ctr
ORDER BY share_of_california_revenue DESC;

-- Question:
-- Which sub-categories drive revenue within each California category?
-- Purpose:
-- Since California revenue is balanced across categories, this query drills deeper
-- to identify the specific sub-categories driving each category's performance.
-- Method:
-- Uses RANK() partitioned by category to show the top sub-categories within each category.        
WITH california_subcategory_revenue AS (
    SELECT
        o.state,
        p.category,
        p.sub_category,
        ROUND(SUM(fs.sales), 2) AS subcategory_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN products p
        ON fs.product_id = p.product_id
    WHERE o.state = 'California'
    GROUP BY
        o.state,
        p.category,
        p.sub_category
),

california_category_revenue AS (
    SELECT
        category,
        ROUND(SUM(subcategory_revenue), 2) AS category_revenue
    FROM california_subcategory_revenue
    GROUP BY category
),

ranked_subcategories AS (
    SELECT
        csr.state,
        csr.category,
        csr.sub_category,
        csr.subcategory_revenue,
        ccr.category_revenue,
        ROUND(csr.subcategory_revenue / ccr.category_revenue * 100, 2) AS share_of_category_revenue,
        RANK() OVER (
            PARTITION BY csr.category
            ORDER BY csr.subcategory_revenue DESC
        ) AS subcategory_rank
    FROM california_subcategory_revenue csr
    JOIN california_category_revenue ccr
        ON csr.category = ccr.category
)

SELECT
    state,
    category,
    sub_category,
    subcategory_revenue,
    category_revenue,
    share_of_category_revenue,
    subcategory_rank
FROM ranked_subcategories
WHERE subcategory_rank <= 3
ORDER BY
    category,
    subcategory_rank;

-- ====================================
-- Section 4: Customer Segment Analysis
-- ====================================
-- Revenue
-- Question:
-- Which customer segments generate the most revenue, and what share of total revenue does each represent?
-- Purpose:
-- Identifies the main customer groups driving revenue and shows how dependent
-- the business is on each segment.
WITH segment_revenue AS (
    SELECT
        c.segment,
        ROUND(SUM(fs.sales), 2) AS segment_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.segment
),

total_revenue AS (
    SELECT
        ROUND(SUM(segment_revenue), 2) AS total_revenue
    FROM segment_revenue
)

SELECT
    sr.segment,
    sr.segment_revenue,
    tr.total_revenue,
    ROUND(sr.segment_revenue / tr.total_revenue * 100, 2) AS share_of_total_revenue
FROM segment_revenue sr
CROSS JOIN total_revenue tr
ORDER BY sr.segment_revenue DESC;

-- Overall Growth
-- Question:
-- Which customer segments grew the most from 2015 to 2018?
-- Purpose:
-- Compares each segment's starting-year revenue to ending-year revenue to identify
-- long-term growth across the dataset.
WITH segment_year_revenue AS (
    SELECT
        YEAR(o.order_date) AS order_year,
        c.segment,
        ROUND(SUM(fs.sales), 2) AS segment_year_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY
        YEAR(o.order_date),
        c.segment
)

SELECT
    segment,
    ROUND(SUM(CASE WHEN order_year = 2015 THEN segment_year_revenue ELSE 0 END), 2) AS revenue_2015,
    ROUND(SUM(CASE WHEN order_year = 2018 THEN segment_year_revenue ELSE 0 END), 2) AS revenue_2018,
    ROUND(
        (
            SUM(CASE WHEN order_year = 2018 THEN segment_year_revenue ELSE 0 END)
            -
            SUM(CASE WHEN order_year = 2015 THEN segment_year_revenue ELSE 0 END)
        )
        / SUM(CASE WHEN order_year = 2015 THEN segment_year_revenue ELSE 0 END) * 100,
        2
    ) AS total_growth_pct
FROM segment_year_revenue
GROUP BY segment
ORDER BY total_growth_pct DESC;
    
-- Year On Year Growth
-- Question:
-- How has revenue changed year over year for each customer segment?
-- Purpose:
-- Shows whether each segment is growing consistently or experiencing volatility over time.
-- Method:
-- Uses LAG() partitioned by segment to compare each year's revenue with the previous year.
WITH segment_year_revenue AS (
    SELECT
        YEAR(o.order_date) AS order_year,
        c.segment,
        ROUND(SUM(fs.sales), 2) AS segment_year_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY
        YEAR(o.order_date),
        c.segment
),

segment_growth AS (
    SELECT
        order_year,
        segment,
        segment_year_revenue,
        LAG(segment_year_revenue) OVER (
            PARTITION BY segment
            ORDER BY order_year
        ) AS previous_year_revenue
    FROM segment_year_revenue
)

SELECT
    order_year,
    segment,
    segment_year_revenue,
    previous_year_revenue,
    ROUND(
        (segment_year_revenue - previous_year_revenue)
        / previous_year_revenue * 100,
        2
    ) AS yoy_growth_pct
FROM segment_growth
ORDER BY
    segment,
    order_year;
    
-- Category Analysis on Segment Level
-- Question:
-- Which product categories does each customer segment spend the most on?
-- Purpose:
-- Compares category preferences across segments to understand whether Consumer,
-- Corporate, and Home Office customers buy different types of products.
WITH segment_category_revenue AS (
    SELECT
        c.segment,
        p.category,
        ROUND(SUM(fs.sales), 2) AS segment_category_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN products p
        ON fs.product_id = p.product_id
    GROUP BY
        c.segment,
        p.category
),

segment_total_revenue AS (
    SELECT
        segment,
        ROUND(SUM(segment_category_revenue), 2) AS segment_total_revenue
    FROM segment_category_revenue
    GROUP BY segment
)

SELECT
    scr.segment,
    scr.category,
    scr.segment_category_revenue,
    str.segment_total_revenue,
    ROUND(scr.segment_category_revenue / str.segment_total_revenue * 100, 2) AS share_of_segment_revenue
FROM segment_category_revenue scr
JOIN segment_total_revenue str
    ON scr.segment = str.segment
ORDER BY
    scr.segment,
    share_of_segment_revenue DESC;
    
-- Question:
-- Which individual customers generate the most revenue?
-- Purpose:
-- Identifies the top revenue-generating customers and checks whether revenue
-- is heavily dependent on any single customer.
-- Method:
-- Uses RANK() to rank customers by total revenue.
WITH customer_revenue AS (
    SELECT
        c.customer_name,
        ROUND(SUM(fs.sales), 2) AS customer_revenue
    FROM fact_sales fs
    JOIN orders o
        ON fs.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_name
),

total_revenue AS (
    SELECT
        ROUND(SUM(customer_revenue), 2) AS total_revenue
    FROM customer_revenue
),

ranked_customers AS (
    SELECT
        cr.customer_name,
        cr.customer_revenue,
        tr.total_revenue,
        ROUND(cr.customer_revenue / tr.total_revenue * 100, 2) AS share_of_total_revenue,
        RANK() OVER (
            ORDER BY cr.customer_revenue DESC
        ) AS customer_rank
    FROM customer_revenue cr
    CROSS JOIN total_revenue tr
)

SELECT
    customer_name,
    customer_revenue,
    total_revenue,
    share_of_total_revenue,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY customer_rank;



