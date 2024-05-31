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