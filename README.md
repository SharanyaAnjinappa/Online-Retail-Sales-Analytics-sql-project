# Online-Retail-Sales-Analytics-Database-Management-System
📌 Project Overview
This project focuses on designing and implementing a normalized relational database for an online retail business using MySQL.
The project uses an online retail transaction dataset obtained from Kaggle. The raw data was cleaned and transformed into a structured relational database containing customers, products, categories, orders, order items, and payments.
SQL queries were then developed to analyze sales performance, customer spending, product performance, revenue trends, and other business metrics.
🎯 Objectives
- Design a normalized SQL database for an online retail business.
- Clean and transform raw transaction data.
- Reduce data redundancy using relational database design.
- Implement primary keys and foreign keys.
- Analyze sales using SQL queries.
- Use JOINs, GROUP BY, HAVING, subqueries, CTEs, and window functions.
- Create reusable SQL views for reporting.
- Generate meaningful business insights from retail transactions.
🛠️ Tools & Technologies
Tool	Purpose
MySQL 8.0	Database management
MySQL Workbench	SQL development and ER diagram
SQL	Data cleaning, transformation and analysis
Kaggle	Source dataset


📂 Dataset
The project uses an online retail transaction dataset containing fields such as:
- Invoice Number
- Stock Code
- Product Description
- Quantity
- Invoice Date
- Unit Price
- Customer ID
- Country
The imported data was stored initially in a staging table called retail_raw.
🔄 Project Workflow
Kaggle Dataset
       ↓
Raw Data Import
       ↓
Data Quality Checks
       ↓
Data Cleaning
       ↓
Database Normalization
       ↓
Customers
Categories
Products
Orders
Order_Items
Payments
       ↓
SQL Analysis
       ↓
Views & Reports

🧹 Data Cleaning
The raw dataset was checked for:
- Missing Customer IDs
- Invalid quantities
- Invalid prices
- Missing product descriptions
- Duplicate records
Records with invalid quantities or prices and missing required customer/product information were removed.
After cleaning, the project contained:
Metric	Count
Valid transaction rows	653
Customers	31
Products	416
Orders	44
Categories	10


🗄️ Database Design
The database contains six main tables:
1. Customers
Stores unique customer information.
customer_id
source_customer_id
country

2. Categories
Stores product categories.
category_id
category_name

3. Products
Stores product information.
product_id
stock_code
product_name
unit_price
category_id

4. Orders
Stores individual orders/invoices.
order_id
invoice_no
customer_id
order_date

5. Order_Items
Stores the products purchased in each order.
order_item_id
order_id
product_id
quantity
unit_price

6. Payments
Stores payment information associated with orders.
payment_id
order_id
payment_method
payment_status
payment_amount

Note: Payment information was not available in the original dataset. Payment attributes were generated as synthetic project data to complete the e-commerce database model.

🔗 ER Diagram
The database relationships are:
Customers
    │
    │ 1 : Many
    ▼
  Orders ───────── Payments
    │
    │ 1 : Many
    ▼
Order_Items
    │
    │ Many : 1
    ▼
 Products
    │
    │ Many : 1
    ▼
Categories

ER Diagram
<img width="891" height="469" alt="ER_diagram_for online_retail" src="https://github.com/user-attachments/assets/754652e5-e508-489f-ad74-28b13fa40402" />

📈 SQL Analysis
The project includes SQL queries for:
Sales Analysis
- Total revenue
- Revenue by country
- Monthly revenue
- Revenue by category
Product Analysis
- Top 10 products by revenue
- Top products by quantity sold
- Products above average price
- Product performance
Customer Analysis
- Top customers by spending
- Customers with multiple orders
- Customer spending rankings
- Average order value
Advanced SQL
The project demonstrates:
- INNER JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- Aggregate functions
- Subqueries
- CTEs
- Window functions
- RANK()
- Date functions
- SQL Views
🔍 Example SQL Query
Total Revenue
-- Calculate total revenue from all order items.
-- Revenue = Quantity × Unit Price

SELECT
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;

Top 10 Products by Revenue
-- Calculate revenue for every product
-- and display the top 10 products.

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

👁️ SQL Views
The project contains reusable views for reporting:
sales_summary
customer_sales_summary
monthly_sales
product_performance

These views make frequently required reports easier to query.
📊 Key Project Insights
The SQL analysis can be used to identify:
- Products generating the highest revenue.
- Products with the highest number of units sold.
- Customers contributing the most revenue.
- Countries with higher sales within the project sample.
- Monthly sales patterns.
- Category-level revenue performance.
- Repeat customers.
- Products priced above the overall average.
📁 Project Structure
I recommend arranging your GitHub repository like this:
online-retail-sales-sql-project/
│
├── README.md
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_table_creation.sql
│   ├── 04_data_transformation.sql
│   ├── 05_analysis_queries.sql
│   └── 06_views.sql
│
├── data/
│   └── README.md
│
├── diagrams/
│   └── ER_Diagram.png
│
├── reports/
│   └── Online_Retail_Sales_Analytics_Project_Report.pdf


⚠️ Don't upload the raw CSV if it contains unnecessary personal/customer information.
For this project, you can simply put a README.md inside data/ saying:
# Dataset

The project uses an online retail transaction dataset obtained from Kaggle.

The raw dataset is not included in this repository. The SQL scripts operate on the cleaned project data imported during development.

🎓 Conclusion
This project demonstrates the complete workflow of transforming raw retail transaction data into a normalized relational database and performing SQL-based business analysis.
The project provided practical experience in database design, data cleaning, normalization, relational modeling, SQL analytics, CTEs, window functions, and reporting views.


👩‍💻 Author
Sharanya A
B.Tech – Computer Science and Engineering
