# Titanic Data Engineering – ETL Pipeline

## Project Overview

This project implements an end-to-end ETL (Extract, Transform, Load) pipeline using Python and MySQL.

The Titanic dataset is extracted using Python, loaded into MySQL, transformed using SQL, and used to create analytical views and data quality checks.

## Project Architecture

The pipeline follows these steps:

1. **Extract:** Load the Titanic dataset using Seaborn.
2. **Load:** Store the original dataset in a MySQL raw table using Python and SQLAlchemy.
3. **Staging:** Create a staging table with renamed columns and standardized values.
4. **Transformation:** Clean missing values, create age groups, calculate family size and categorize fares.
5. **Analytics:** Create SQL views to analyze passenger survival patterns.
6. **Data Quality:** Execute validation checks and report PASS or FAIL results.

## Technologies Used

- Python
- Pandas
- MySQL
- SQL
- SQLAlchemy
- PyMySQL
- Seaborn

## Project Structure

```text
Titanic-Data-Engineering-ETL/
│
├── run_elt.py
├── extract_load.py
├── requirements.txt
│
└── sql/
    ├── 01_stg_titanic.sql
    ├── 02_clean_passengers.sql
    ├── 03_analytics_views.sql
    └── 04_dq_checks.sql
```

## Data Quality Checks

The pipeline validates:

- Raw and cleaned row counts.
- Missing age and embarked port values.
- Duplicate passenger IDs.
- Age values between 0 and 100.
- Valid sex values (0 and 1).

## How to Run

1. Install Python and MySQL.
2. Create and activate a Python virtual environment.
3. Install the required packages:

```bash
pip install -r requirements.txt
```

4. Configure your MySQL connection using environment variables:

```text
MYSQL_HOST
MYSQL_PORT
MYSQL_USER
MYSQL_PASSWORD
MYSQL_DATABASE
```

5. Run the pipeline:

```bash
python run_elt.py
```

The pipeline creates the database if necessary and executes the extraction, loading, transformation, analytics and data-quality steps.

## Learning Outcomes

- Understanding ETL pipeline architecture.
- Connecting Python applications with MySQL.
- Performing SQL-based data transformations.
- Creating analytical views.
- Implementing data quality validation.
- Organizing a multi-file data engineering project.

## Author

Divya Nayana Sri
