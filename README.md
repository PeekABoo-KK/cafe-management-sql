# cafe-management-sql
SQL-based backend system for managing a coffee shop.

# Coffee Shop Database Management System

This project is a comprehensive **SQL-based database system** for managing the operations of a small coffee shop. It covers schema design, sample data generation, business logic via triggers, and reporting/analytics with stored procedures. The system is built to support operations such as order tracking, employee shifts, promotions, and revenue analysis.

---

# Project Structure

| File | Description |
|------|-------------|
| `ERD.drawio` | Entity Relationship Diagram (ERD) for database design. |
| `schema.sql` | SQL script to create all tables and define schema constraints. |
| `insert_sample_data.sql` | Inserts realistic sample data for testing (drinks, customers, orders, etc.). |
| `trigger.sql` | Implements business logic using T-SQL triggers (auto-calculation, validations, etc.). |
| `sales_revenue_promotions.sql` | Stored procedures for sales reporting and promotion tracking. |
| `employee_and_shift.sql` | Stored procedures for staff performance and shift analytics. |
| `customer_analytics.sql` | Stored procedures for customer behavior and segmentation analysis. |

---

# Features

- **Normalized relational schema** with constraints and relationships.
- **Data integrity** ensured via CHECKs, triggers, and default values.
- **Business rules** implemented directly in the database (e.g. loyalty tiers, payment validation).
- **Automatic calculations** such as total order value, discounts, and change.
- **Analytical queries** for:
  - Sales trends
  - Customer segmentation
  - Promotion effectiveness
  - Peak operation hours
  - Employee productivity

---

# How to Use

1. **Clone or download** this repository.
2. Open SQL Server Management Studio (SSMS) or your preferred SQL environment.
3. Run the scripts in the following order:
   ```bash
   1. schema.sql
   2. insert_sample_data.sql
   3. trigger.sql
   4. sales_revenue_promotions.sql
   5. employee_and_shift.sql
   6. customer_analytics.sql
   ```
4. Optionally open `ERD.drawio` in [draw.io](https://draw.io) to view the database structure.

---

#  Analytics Output

Each stored procedure can be executed manually or integrated with tools like **Power BI**, **Excel**, or **Tableau** to build dashboards.

Example:
```sql
EXEC SP_TotalSalesByDay;
EXEC SP_Top10LoyalCustomers;
```

---

#  Sample Business Insights

- Which drinks are the best-sellers?
- Which employees generate the most revenue?
- Are promotions improving sales?
- When are peak business hours?
- Which customers are most loyal or inactive?

---

# Author

**Nguyen Le Hoai An**  
First-year IT Student | Passionate about SQL & Data Systems  
Contact: [hoaiannguyenle19@gmail.com]

---

# License

This project is for academic and portfolio purposes. Feel free to fork or reuse with attribution.
