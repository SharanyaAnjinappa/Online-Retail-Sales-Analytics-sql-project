# Online-Retail-Sales-Analytics-Database-Management-System

## 📌 Project Overview

This project focuses on designing and implementing a normalized relational database for an online retail business using **MySQL**.

The project uses an online retail transaction dataset obtained from Kaggle. The raw data was cleaned and transformed into a structured relational database containing **customers, products, categories, orders, order items, and payments**.

SQL queries were then developed to analyze sales performance, customer spending, product performance, revenue trends, and other business metrics.

---

## 🎯 Objectives

- Design a normalized SQL database for an online retail business.
- Clean and transform raw transaction data.
- Reduce data redundancy using relational database design.
- Implement primary keys and foreign keys.
- Analyze sales using SQL queries.
- Use `JOIN`, `GROUP BY`, `HAVING`, subqueries, CTEs, and window functions.
- Create reusable SQL views for reporting.
- Generate meaningful business insights from retail transactions.

---

## 🛠️ Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| MySQL 8.0 | Database management |
| MySQL Workbench | SQL development and ER diagram |
| SQL | Data cleaning, transformation, and analysis |
| Kaggle | Source dataset |

---

## 📂 Dataset

The project uses an online retail transaction dataset containing fields such as:

- Invoice Number
- Stock Code
- Product Description
- Quantity
- Invoice Date
- Unit Price
- Customer ID
- Country

The imported data was initially stored in a staging table called `retail_raw`.

---

## 🔄 Project Workflow

```text
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
┌─────────────┐
│  Customers  │
│ Categories  │
│  Products   │
│   Orders    │
│ Order_Items │
│  Payments   │
└─────────────┘
      ↓
SQL Analysis
      ↓
Views & Reports
```

---

## 🧹 Data Cleaning

The raw dataset was checked for:

- Missing Customer IDs
- Invalid quantities
- Invalid prices
- Missing product descriptions
- Duplicate records

Records with invalid quantities or prices and missing required customer/product information were removed.

### Dataset Statistics

| Metric | Count |
|---|---:|
| Valid transaction rows | 653 |
| Customers | 31 |
| Products | 416 |
| Orders | 44 |
| Categories | 10 |

---

## 🗄️ Database Design

The database contains six main tables.

### 1. Customers

Stores unique customer information.

| Column | Description |
|---|---|
| `customer_id` | Internal customer ID |
| `source_customer_id` | Customer ID from source dataset |
| `country` | Customer country |

### 2. Categories

Stores product categories.

| Column | Description |
|---|---|
| `category_id` | Category ID |
| `category_name` | Category name |

### 3. Products

Stores product information.

| Column | Description |
|---|---|
| `product_id` | Product ID |
| `stock_code` | Product/stock code |
| `product_name` | Product description |
| `unit_price` | Product price |
| `category_id` | Related category |

### 4. Orders

Stores individual orders/invoices.

| Column | Description |
|---|---|
| `order_id` | Order ID |
| `invoice_no` | Invoice number |
| `customer_id` | Related customer |
| `order_date` | Order date and time |

### 5. Order_Items

Stores the products purchased in each order.

| Column | Description |
|---|---|
| `order_item_id` | Order item ID |
| `order_id` | Related order |
| `product_id` | Related product |
| `quantity` | Quantity purchased |
| `unit_price` | Transaction price |

### 6. Payments

Stores payment information associated with orders.

| Column | Description |
|---|---|
| `payment_id` | Payment ID |
| `order_id` | Related order |
| `payment_method` | Payment method |
| `payment_status` | Payment status |
| `payment_amount` | Payment amount |

> **Note:** Payment information was not available in the original dataset. Payment attributes were generated as synthetic project data to complete the e-commerce database model.

---

## 🔗 ER Diagram

The database relationships are:

```text
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
```

### ER Diagram

<img width="891" height="469" alt="ER_diagram_for online_retail" src="https://github.com/user-attachments/assets/0e222c52-ab6c-4df1-80c9-a29f91bbe764" />


---

## 📈 SQL Analysis

The project includes SQL queries for different business analysis tasks.

### 💰 Sales Analysis

- Total revenue
- Revenue by country
- Monthly revenue
- Revenue by category
- Average order value

### 📦 Product Analysis

- Top 10 products by revenue
- Top products by quantity sold
- Products above average price
- Product performance

### 👥 Customer Analysis

- Top customers by spending
- Customers with multiple orders
- Customer spending rankings
- Repeat customers

### 🧠 Advanced SQL

The project demonstrates:

- `INNER JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- Aggregate functions
- Subqueries
- CTEs
- Window functions
- `RANK()`
- Date functions
- SQL Views

---

## 🔍 Example SQL Queries

### Total Revenue

Calculates the total revenue generated from all order items.

```sql
-- Calculate total revenue.
-- Revenue = Quantity × Unit Price

SELECT
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;
```

### Top 10 Products by Revenue

Calculates the revenue generated by each product and displays the top 10 products.

```sql
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
```

### Top Customers by Spending

```sql
-- Calculate the total amount spent by each customer.

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
```

---

## 👁️ SQL Views

The project contains reusable views for reporting:

- `sales_summary`
- `customer_sales_summary`
- `monthly_sales`
- `product_performance`

These views make frequently required reports easier to query and reuse.

---

## 📊 Key Project Insights

The SQL analysis can be used to identify:

- Products generating the highest revenue.
- Products with the highest number of units sold.
- Customers contributing the most revenue.
- Countries with higher sales within the project sample.
- Monthly sales patterns.
- Category-level revenue performance.
- Repeat customers.
- Products priced above the overall average.

---

## 📁 Project Structure

```text
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
│
└── screenshots/
    ├── database_tables.png
    ├── sales_analysis.png
    └── er_diagram.png
```

---

## 📂 Dataset Files

The raw CSV dataset is not included in this repository.

The project uses an online retail transaction dataset obtained from Kaggle.

The SQL scripts operate on the cleaned project data imported during development.

---

## 🎓 Conclusion

This project demonstrates the complete workflow of transforming raw retail transaction data into a normalized relational database and performing SQL-based business analysis.

The project provided practical experience in:

- Database design
- Data cleaning
- Normalization
- Relational modeling
- SQL analytics
- JOIN operations
- CTEs
- Window functions
- SQL Views
- Business reporting

The database can be extended in the future with additional customer attributes, inventory management, real payment information, and larger transaction volumes.

---

## 👩‍💻 Author

**Sharanya A**

B.Tech – Computer Science and Engineering
