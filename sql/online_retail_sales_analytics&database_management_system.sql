-- =========================================================
-- PROJECT: ONLINE RETAIL SALES ANALYTICS
-- DATABASE SETUP
-- =========================================================

-- Create the database for our project
CREATE DATABASE online_retail_db;
USE online_retail_db;
SELECT DATABASE();
-- =========================================================
-- STEP 1: CREATE RAW / STAGING TABLE
-- =========================================================

-- This table stores the original CSV data.
-- We keep the raw data unchanged before cleaning it.
CREATE TABLE retail_raw (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(30),
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
);
SELECT COUNT(*) AS total_rows FROM retail_raw;-- Check how many records were imported
-- Display the first 10 records
-- This helps us verify that the import worked correctly
SELECT * FROM retail_raw LIMIT 10;
-- =========================================================
-- STEP 2: DATA QUALITY CHECK
-- =========================================================

-- Count records that have valid quantity,
-- valid price and a customer ID
SELECT COUNT(*) AS valid_rows
FROM retail_raw
WHERE Quantity > 0
  AND UnitPrice > 0
  AND CustomerID IS NOT NULL
  AND CustomerID <> '';
  -- =========================================================
-- STEP 3: CREATE CLEAN DATASET
-- =========================================================

-- Create a cleaned version of the raw dataset.
-- DISTINCT removes completely duplicate records.
-- Invalid quantities/prices are removed.
-- Records without customer IDs or descriptions are removed.

CREATE TABLE retail_clean AS
SELECT DISTINCT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM retail_raw
WHERE Quantity > 0
  AND UnitPrice > 0
  AND CustomerID IS NOT NULL
  AND CustomerID <> ''
  AND Description IS NOT NULL
  AND Description <> '';
SELECT *FROM retail_clean LIMIT 10;
-- =========================================================
-- STEP 4: CHECK UNIQUE BUSINESS ENTITIES
-- =========================================================

-- Find the number of unique customers, products and orders
-- present in our cleaned dataset.
SELECT
    COUNT(DISTINCT CustomerID) AS customers,
    COUNT(DISTINCT StockCode) AS products,
    COUNT(DISTINCT InvoiceNo) AS orders
FROM retail_clean;
-- =========================================================
-- STEP 5: CREATE CUSTOMERS TABLE
-- =========================================================

-- Stores each customer only once.
-- This reduces repeated customer information.
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    source_customer_id VARCHAR(20) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL
);
SELECT COUNT(*) AS customers FROM customers;

SELECT COUNT(*) AS clean_rows FROM retail_clean;

SELECT CustomerID, Country FROM retail_clean LIMIT 10;

INSERT INTO customers (source_customer_id, country)
SELECT DISTINCT
    TRIM(CustomerID),
    Country
FROM retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> '';
SELECT COUNT(*) AS total_customers FROM customers;
-- =========================================================
-- STEP 6: CREATE CATEGORIES TABLE
-- =========================================================

-- Stores product categories.
-- Categories are derived from product descriptions because
-- the original dataset does not contain a category column.
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);
-- =========================================================
-- STEP 7: CREATE PRODUCTS TABLE
-- =========================================================
-- Stores each product only once.
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_code VARCHAR(20) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);
-- =========================================================
-- INSERT PRODUCTS
-- =========================================================
-- GROUP BY StockCode creates one product record
-- for each unique stock code.
-- MAX() is used to select one description and one price
-- when the same product appears in multiple transactions.
INSERT INTO products (
    stock_code,
    product_name,
    unit_price
)
SELECT
    StockCode,
    MAX(Description),
    MAX(UnitPrice)
FROM retail_clean
GROUP BY StockCode;

SELECT COUNT(*) AS total_products FROM products;
-- =========================================================
-- STEP 8: CREATE ORDERS TABLE
-- =========================================================
-- Stores one record for each unique invoice/order.
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_no VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
-- =========================================================
-- INSERT ORDERS
-- =========================================================
-- Convert the original text date
-- DD-MM-YYYY HH:MM
-- into MySQL DATETIME format.

INSERT INTO orders (
    invoice_no,
    customer_id,
    order_date
)
SELECT
    r.InvoiceNo,
    c.customer_id,
    STR_TO_DATE(r.InvoiceDate, '%d-%m-%Y %H:%i')
FROM retail_clean r
JOIN customers c
    ON TRIM(r.CustomerID) = c.source_customer_id
GROUP BY
    r.InvoiceNo,
    c.customer_id,
    r.InvoiceDate;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT * FROM orders LIMIT 10;
-- =========================================================
-- STEP 9: CREATE ORDER_ITEMS TABLE
-- =========================================================
-- This table connects Orders and Products.
-- One order can contain many products.
-- One product can appear in many orders.
-- Therefore, order_items acts as the bridge between them
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
-- =========================================================
-- INSERT ORDER ITEMS
-- =========================================================
-- Connect each raw transaction to the correct
-- order and product using their IDs.
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    o.order_id,
    p.product_id,
    r.Quantity,
    r.UnitPrice
FROM retail_clean r
JOIN orders o
    ON r.InvoiceNo = o.invoice_no
JOIN products p
    ON r.StockCode = p.stock_code;

SELECT COUNT(*) AS total_order_items FROM order_items;
SELECT
    oi.order_item_id,
    o.invoice_no,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
LIMIT 10;
-- =========================================================
-- STEP 10: CREATE PAYMENTS TABLE
-- =========================================================
-- Stores payment information for each order.
-- IMPORTANT:
-- Payment details were NOT present in the original dataset.
-- These payment fields are synthetic project data.
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);
-- =========================================================
-- GENERATE SYNTHETIC PAYMENT DATA
-- =========================================================
INSERT INTO payments (
    order_id,
    payment_method,
    payment_status,
    payment_amount
)
SELECT
    o.order_id,

    CASE MOD(o.order_id, 4)
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Debit Card'
        WHEN 2 THEN 'UPI'
        ELSE 'Net Banking'
    END AS payment_method,

    CASE
        WHEN MOD(o.order_id, 10) = 0 THEN 'Pending'
        ELSE 'Completed'
    END AS payment_status,

    SUM(oi.quantity * oi.unit_price) AS payment_amount

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY o.order_id;
SELECT COUNT(*) AS total_payments FROM payments;
SELECT * FROM payments LIMIT 10;

UPDATE products
SET category_id =
    CASE
        WHEN UPPER(product_name) REGEXP 'MUG|PLATE|BOWL|CUP|KITCHEN|SPOON|FORK|GLASS'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Kitchen')

        WHEN UPPER(product_name) REGEXP 'NECKLACE|BRACELET|RING|EARRING|JEWEL'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Jewelry')

        WHEN UPPER(product_name) REGEXP 'DRESS|SHIRT|T-SHIRT|JACKET|COAT|SKIRT'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Clothing')

        WHEN UPPER(product_name) REGEXP 'PEN|PENCIL|NOTEBOOK|PAPER|CARD|STATIONERY'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Stationery')

        WHEN UPPER(product_name) REGEXP 'TOY|GAME|DOLL|CHILDREN'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Toys')

        WHEN UPPER(product_name) REGEXP 'BAG|PURSE|WALLET|UMBRELLA'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Accessories')

        WHEN UPPER(product_name) REGEXP 'CHRISTMAS|EASTER|HALLOWEEN|VALENTINE'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Seasonal')

        WHEN UPPER(product_name) REGEXP 'GIFT|PRESENT'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Gifts')

        WHEN UPPER(product_name) REGEXP 'CANDLE|FRAME|CLOCK|DECOR|ORNAMENT'
            THEN (SELECT category_id FROM categories WHERE category_name = 'Home Decor')

        ELSE
            (SELECT category_id FROM categories WHERE category_name = 'Other')
    END
WHERE product_id > 0;

SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p
    ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC;

SELECT
    'Customers' AS table_name,
    COUNT(*) AS record_count
FROM customers

UNION ALL

SELECT
    'Categories',
    COUNT(*)
FROM categories

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'Order Items',
    COUNT(*)
FROM order_items

UNION ALL

SELECT
    'Payments',
    COUNT(*)
FROM payments;

SELECT
    o.invoice_no,
    c.source_customer_id,
    c.country,
    o.order_date
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LIMIT 10;

SELECT
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;

SELECT
    c.country,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

SELECT
    c.source_customer_id,
    c.country,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.source_customer_id,
    c.country
ORDER BY total_spent DESC
LIMIT 10;

SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id
) AS order_totals;

SELECT
    c.category_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

SELECT
    c.source_customer_id,
    c.country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.source_customer_id,
    c.country
HAVING SUM(oi.quantity * oi.unit_price) > 100
ORDER BY total_spent DESC;

SELECT
    c.source_customer_id,
    COUNT(o.order_id) AS number_of_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.source_customer_id
HAVING COUNT(o.order_id) > 1
ORDER BY number_of_orders DESC;

SELECT
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING SUM(oi.quantity * oi.unit_price) > 100
ORDER BY revenue DESC;

SELECT
    product_name,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products
)
ORDER BY unit_price DESC;

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.source_customer_id,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.source_customer_id
)
SELECT
    source_customer_id,
    ROUND(total_spent, 2) AS total_spent
FROM customer_spending
ORDER BY total_spent DESC;

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.source_customer_id,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.source_customer_id
)
SELECT
    source_customer_id,
    ROUND(total_spent, 2) AS total_spent,
    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS customer_rank
FROM customer_spending
ORDER BY customer_rank;

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN categories c
        ON p.category_id = c.category_id
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
)
SELECT
    product_name,
    category_name,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        PARTITION BY category_name
        ORDER BY revenue DESC
    ) AS category_rank
FROM product_sales
ORDER BY category_name, category_rank;

CREATE VIEW sales_summary AS
SELECT
    o.invoice_no,
    o.order_date,
    c.source_customer_id,
    c.country,
    p.stock_code,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories cat
    ON p.category_id = cat.category_id;
    
CREATE VIEW customer_sales_summary AS
SELECT
    c.customer_id,
    c.source_customer_id,
    c.country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.source_customer_id,
    c.country;

CREATE VIEW monthly_sales AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS items_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

CREATE VIEW product_performance AS
SELECT
    p.product_id,
    p.stock_code,
    p.product_name,
    cat.category_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products p
JOIN categories cat
    ON p.category_id = cat.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.stock_code,
    p.product_name,
    cat.category_name;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';