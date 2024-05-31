### README

# Recruitment Task Documentation

## Overview
This README provides detailed instructions and explanations for the provided recruitment tasks, including information on the logic implemented, the libraries used, and how to run the code. The repository contains two main projects, each with its own specific task and documentation.

## Projects

### [Project 1: Marketing Dataset View](task1/README.md)
This project involves creating a SQL view named `marketing_dataset` in the `rekrutacja` schema. The view consolidates various project properties and filters the data based on specific business criteria for Tidio's marketing activities.

### [Project 2: URL Query Parameter Extraction](task2/README.md)
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
The SQL code for creating the view is provided in the [project1/README.md](project1/README.md) file.

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

### Script Explanation

#### Importing Libraries
The script starts by importing the necessary libraries:
```python
import pandas as pd
import numpy as np
import re
```

#### Reading Input Data
The script reads the input TSV file containing the URLs:
```python
urls = pd.read_csv("task1_input.tsv", sep="\t")
```

#### Processing URLs
The script processes each URL to extract specific query parameters. It initializes a dictionary to store the extracted data:
```python
out_dict = dict()
required_columns = ["a_bucket", "a_type", "a_source", "a_v", "a_g_campaignid", "a_g_keyword", "a_g_adgroupid", "a_g_creative"]
```

For each URL, the script splits the URL into parameters and values using regular expressions, and then it populates the dictionary with the extracted values. If any required parameter is missing, it fills the corresponding entry with `NaN`:
```python
for url in urls.url:
    columns = [val.split("=")[0] for val in re.split(r'[&%?]', url)]
    values = [np.nan if len(val.split("=")) < 2 else val.split("=")[1] for val in re.split(r'[&%?]', url)]
    out_dict.setdefault("url", []).append(url)
    
    for col, val in zip(columns, values):
        if col not in required_columns:
            continue
        out_dict.setdefault(col, []).append(val)
        
    if (set(required_columns) - set(columns)):
        missing_columns = set(required_columns) - set(columns)
        
        for missing_column in missing_columns:
            out_dict.setdefault(missing_column, []).append(np.nan)
```

#### Creating DataFrame
The script converts the dictionary into a pandas DataFrame:
```python
out_df = pd.DataFrame(out_dict)
```

#### Renaming Columns
The script renames the columns to more readable names:
```python
names = {"a_bucket": "ad_bucket", "a_type":"ad_type", "a_source":"ad_source", "a_v":"schema_version", 
        "a_g_campaignid":"ad_campaign_id", "a_g_keyword":"ad_keyword", "a_g_adgroupid":"ad_adgroup_id", "a_g_creative":"ad_creative"}
out_df = out_df.rename(names, axis="columns")
```

#### Reordering Columns
The script reorders the columns to match the expected format:
```python
out_df = out_df[['url', 'ad_bucket', 'ad_type', 'ad_source', 'schema_version', 'ad_campaign_id', 'ad_keyword', 'ad_adgroup_id', 'ad_creative']]
```

#### Validating Output
The script checks if the generated DataFrame matches the expected output:
```python
test_df = pd.read_csv("task1_output.tsv", sep="\t", dtype="str")
print(out_df.equals(test_df))
```

#### Saving Output
The script saves the final DataFrame to a TSV file:
```python
out_df.to_csv('solution.tsv', sep="\t", index=False)
```

### Running the Script
To run the script, open the Jupyter Notebook and run each cell sequentially.

### Conclusion
This script successfully processes the input URLs, extracts the required query parameters, and formats the data as specified. The output is validated against the provided expected output and saved to a TSV file.

