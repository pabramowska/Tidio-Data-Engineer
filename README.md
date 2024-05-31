### README

# Recruitment Task Documentation

## Overview
This README provides detailed instructions and explanations for the provided recruitment tasks, including information on the logic implemented, the libraries used, and how to run the code. The repository contains two main projects, each with its own specific task and documentation.

## Projects

### [Project 1: Marketing Dataset View](task2/README.md)
This project involves creating a SQL view named `marketing_dataset` in the `rekrutacja` schema. The view consolidates various project properties and filters the data based on specific business criteria for Tidio's marketing activities.

### [Project 2: URL Query Parameter Extraction](task1/README.md)
This project involves reading URLs from an input file, extracting specific query parameters from these URLs, organizing this information into a structured format, and saving the output to a new file.

## Project 1: Marketing Dataset View

### Task Description
The task involves creating a SQL view that consolidates and filters data from two tables: `project_properties` and `project_properties_values`.

### Schema and Tables
The schema and tables are defined as follows:
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

### SQL Code
The SQL code for creating the view is provided in the [task2/README.md](task2/README.md) file.

### Explanation
The view consolidates data from the `project_properties_values` and `project_properties` tables, using subqueries with window functions to select the latest property values based on `create_dte`. The results are filtered to include only customers meeting specific criteria.

## Project 2: URL Query Parameter Extraction

### Task Description
The task involves reading URLs from an input file, extracting specific query parameters from these URLs, organizing this information into a structured format, and saving the output to a new file.

### Dependencies
The following Python libraries are required to run the script:
- `pandas`: For data manipulation and analysis.
- `numpy`: For handling missing values.
- `re`: For regular expression operations to parse URLs.

You can install these libraries using pip:
```bash
pip install pandas numpy
```

### Files
- `task1_input.tsv`: Input file containing URLs.
- `task1_output.tsv`: Output file with the expected format for validation.
- `solution.tsv`: Generated output file with extracted and formatted data.

### Python script
The Python code for creating the file is provided in the [task1/README.md](task1/README.md) file.

### Conclusion
This script successfully processes the input URLs, extracts the required query parameters, and formats the data as specified. The output is validated against the provided expected output and saved to a TSV file.

