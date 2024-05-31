### README


This repository contains SQL code to create a view named `marketing_dataset` in the `rekrutacja` schema. The view consolidates various project properties and filters the data based on specific business criteria for Tidio's marketing activities.

## Table of Contents

- [Description](#description)
- [Schema and Tables](#schema-and-tables)
- [SQL Code](#sql-code)
- [Explanation](#explanation)
- [Usage](#usage)

## Description

The `marketing_dataset` view is designed to provide a consolidated dataset for Tidio's marketing activities. The view extracts and unifies various project properties and customer data, ensuring that only the latest values are considered. It then filters the data to include only those customers who meet specific criteria related to message volume, client volume, and product interest.

## Schema and Tables

The view relies on the following schema and tables within the `rekrutacja` schema:

### Schema

```sql
CREATE DATABASE rekrutacja;
USE rekrutacja;
```

### Tables

- **`project_properties`**
  - `id` (INT): Project property ID
  - `project_id` (INT): Project ID
  - `label` (VARCHAR): Project property label

- **`project_properties_values`**
  - `id` (INT): Project property value ID
  - `customer_id` (INT): Customer ID
  - `property_id` (INT): Project property ID
  - `value` (VARCHAR): Project property value
  - `create_dte` (DATETIME): Project property value creation time

```sql
CREATE TABLE project_properties_values (
    id INT PRIMARY KEY,
    customer_id INT,
    property_id INT,
    value VARCHAR(255),
    create_dte DATETIME
);

CREATE TABLE project_properties (
    id INT PRIMARY KEY,
    project_id INT,
    label VARCHAR(255)
);
```

## SQL Code

```sql
CREATE VIEW rekrutacja.marketing_dataset AS
SELECT  
    ppv.customer_id, 
    pp.project_id, 
    email.customer_email, 
    volume.avg_message_volume, 
    usd.estimated_client_volume_usd, 
    plan.plan, 
    intr.interested_in_product
FROM
    rekrutacja.project_properties_values ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
JOIN (
    SELECT 
        ppv.customer_id, 
        (CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email,
        ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
    FROM 
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    WHERE 
        pp.label = 'e-mail'
) email ON ppv.customer_id = email.customer_id AND email.row_num = 1        
JOIN (
    SELECT 
        ppv.customer_id, 
        (CASE WHEN pp.label = 'avg_message_volume' THEN CAST(ppv.value AS DECIMAL) END) AS avg_message_volume,
        ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
    FROM 
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    WHERE 
        pp.label = 'avg_message_volume'
) volume ON ppv.customer_id = volume.customer_id AND volume.row_num = 1       
JOIN (
    SELECT 
        ppv.customer_id, 
        (CASE WHEN pp.label = 'estimated_client_volume_usd' THEN CAST(ppv.value AS DECIMAL) END) AS estimated_client_volume_usd,
        ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
    FROM 
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    WHERE 
        pp.label = 'estimated_client_volume_usd'
) usd ON ppv.customer_id = usd.customer_id AND usd.row_num = 1       
JOIN (
    SELECT 
        ppv.customer_id, 
        (CASE WHEN pp.label = 'plan' THEN ppv.value END) AS plan,
        ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
    FROM 
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    WHERE 
        pp.label = 'plan'
) plan ON ppv.customer_id = plan.customer_id AND plan.row_num = 1     
JOIN (
    SELECT 
        ppv.customer_id, 
        (CASE WHEN pp.label = 'interested_in_product' THEN ppv.value END) AS interested_in_product,
        ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
    FROM 
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    WHERE 
        pp.label = 'interested_in_product'
) intr ON ppv.customer_id = intr.customer_id AND intr.row_num = 1    
GROUP BY
    pp.project_id,
    ppv.customer_id,
    email.customer_email,
    volume.avg_message_volume,
    usd.estimated_client_volume_usd,
    plan.plan,
    intr.interested_in_product
HAVING
    avg_message_volume > 5000 
    AND estimated_client_volume_usd > 1000
    AND plan = 'Free'
    AND interested_in_product = 'YES';
```

## Explanation

### Key Points:

1. **View Creation**:
    - The view `marketing_dataset` is created in the `rekrutacja` schema.

2. **Data Selection**:
    - The view consolidates data from `project_properties_values` and `project_properties` tables.

3. **Using Subqueries and Window Functions**:
    - **Subqueries with `ROW_NUMBER()`**: For each property (`e-mail`, `avg_message_volume`, `estimated_client_volume_usd`, `plan`, and `interested_in_product`), we use a subquery to select the latest value based on the `create_dte` column.
    - The `ROW_NUMBER()` window function assigns a unique number to each row within a partition of `customer_id`, ordered by `create_dte` in descending order. This ensures that the most recent row gets the number 1.

4. **Joining Subqueries**:
    - Each subquery is joined on `customer_id` and filtered to include only the rows where `row_num = 1`, ensuring we get the latest property values.

5. **Aggregation and Filtering**:
    - The main query aggregates the data using `MAX` and `CASE` statements to pivot property values into separate columns.
    - The `HAVING` clause filters the results to include only customers meeting specific criteria: `avg_message_volume` > 5000, `estimated_client_volume_usd` > 1000, `plan = 'Free'`, and `interested_in_product = 'YES'`.

## Usage

To create the `marketing_dataset` view, execute the provided SQL code in your MySQL or PostgreSQL database environment where the `rekrutacja` schema and tables are already set up.

1. **Set up the schema and tables**:
    ```sql
    CREATE DATABASE rekrutacja;
    USE rekrutacja;

    CREATE TABLE project_properties_values (
        id INT PRIMARY KEY,
        customer_id INT,
        property_id INT,
        value VARCHAR(255),
        create_dte DATETIME
    );

    CREATE TABLE project_properties (
        id INT PRIMARY KEY,
        project_id INT,
        label VARCHAR(255)
    );
    ```

2. **Execute the view creation SQL code**:
    ```sql
    CREATE VIEW rekrutacja.marketing_dataset AS
    SELECT  
        ppv.customer_id, 
        pp.project_id, 
        email.customer_email, 
        volume.avg_message_volume, 
        usd.estimated_client_volume_usd, 
        plan.plan, 
        intr.interested_in_product
    FROM
        rekrutacja.project_properties_values ppv
    JOIN
        rekrutacja.project_properties pp ON ppv.property_id = pp.id 
    JOIN (
        SELECT 
            ppv.customer_id, 
            (CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email,
            ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
        FROM 
            rekrutacja.project_properties_values ppv
        JOIN
            rekrutacja.project_properties pp ON ppv.property_id = pp.id 
        WHERE 
            pp.label = 'e-mail'
    ) email ON ppv.customer_id = email.customer_id AND email.row_num = 1        
    JOIN (
        SELECT 
            ppv.customer_id, 
            (CASE WHEN pp.label = 'avg_message_volume' THEN CAST(ppv.value AS DECIMAL) END) AS avg_message_volume,
            ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
        FROM 
            rekrutacja.project_properties_values ppv
        JOIN
            rekrutacja.project_properties pp ON ppv.property_id = pp.id 
        WHERE 
            pp.label = 'avg_message_volume'
    ) volume ON ppv.customer_id = volume.customer_id AND volume.row_num = 1       
    JOIN (
        SELECT 
            ppv.customer_id

, 
            (CASE WHEN pp.label = 'estimated_client_volume_usd' THEN CAST(ppv.value AS DECIMAL) END) AS estimated_client_volume_usd,
            ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
        FROM 
            rekrutacja.project_properties_values ppv
        JOIN
            rekrutacja.project_properties pp ON ppv.property_id = pp.id 
        WHERE 
            pp.label = 'estimated_client_volume_usd'
    ) usd ON ppv.customer_id = usd.customer_id AND usd.row_num = 1       
    JOIN (
        SELECT 
            ppv.customer_id, 
            (CASE WHEN pp.label = 'plan' THEN ppv.value END) AS plan,
            ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
        FROM 
            rekrutacja.project_properties_values ppv
        JOIN
            rekrutacja.project_properties pp ON ppv.property_id = pp.id 
        WHERE 
            pp.label = 'plan'
    ) plan ON ppv.customer_id = plan.customer_id AND plan.row_num = 1     
    JOIN (
        SELECT 
            ppv.customer_id, 
            (CASE WHEN pp.label = 'interested_in_product' THEN ppv.value END) AS interested_in_product,
            ROW_NUMBER() OVER (PARTITION BY ppv.customer_id ORDER BY ppv.create_dte DESC) AS row_num
        FROM 
            rekrutacja.project_properties_values ppv
        JOIN
            rekrutacja.project_properties pp ON ppv.property_id = pp.id 
        WHERE 
            pp.label = 'interested_in_product'
    ) intr ON ppv.customer_id = intr.customer_id AND intr.row_num = 1    
    GROUP BY
        pp.project_id,
        ppv.customer_id,
        email.customer_email,
        volume.avg_message_volume,
        usd.estimated_client_volume_usd,
        plan.plan,
        intr.interested_in_product
    HAVING
        avg_message_volume > 5000 
        AND estimated_client_volume_usd > 1000
        AND plan = 'Free'
        AND interested_in_product = 'YES';
    ```

