# SQL Portfolio Project #1

## Project Overview

**Project Title:** ERP Sales Data Analysis
**Level:** Beginner
**Database:** `project1`

This project simulates a real-world SQL task where an ERP sales dataset is imported into MySQL, cleaned, validated, and analyzed based on business requirements.

The objective was to build a complete SQL workflow—from creating a database and importing raw data to preparing the dataset for analysis and answering business questions using SQL.

---

# Objectives

* Create a MySQL database from scratch.
* Import a raw ERP sales dataset into MySQL.
* Clean inconsistent and invalid records.
* Standardize data formatting.
* Validate business rules within the dataset.
* Perform SQL queries to answer business-related questions.

---

# Project Structure

## 1. Database Setup

* Created the database `project1`
* Created the table `data_p1`
* Defined appropriate data types
* Imported the CSV dataset using `LOAD DATA INFILE`

---

## 2. Data Preparation

Before analysis, the dataset required several cleaning steps:

* Removed records with missing dispatch time
* Removed blank quantity values
* Removed blank unit price values
* Removed zero or invalid quantity records
* Standardized **Region** values using `UPPER(TRIM())`
* Standardized **Category** values using `UPPER(TRIM())`

---

## 3. Business Validation

Performed validation checks to identify unusual records, including:

* Orders where **COGS exceeded Unit Price**

These checks help identify pricing or data-entry issues.

---

## SQL Concepts Used

* CREATE DATABASE
* USE
* CREATE TABLE
* LOAD DATA INFILE
* ALTER TABLE
* SELECT
* UPDATE
* DELETE
* WHERE
* LIMIT
* TRIM()
* UPPER()

---

## Dataset

The dataset used for this project is included in this repository.

---

## Key Learnings

Through this project, I gained practical experience with:

* Designing a database schema
* Importing CSV files into MySQL
* Cleaning and preparing real-world data
* Writing SQL queries for business scenarios
* Validating data quality before analysis

---

## Repository Structure

```text
📂 sql-portfolio-project-1
│
├── Project 1.sql
├── README.md
├── screenshots/
│   ├── database.png
│   ├── import.png
│   ├── cleaning.png
│   ├── validation.png
│   └── results.png
```

---

## How to Run

1. Clone this repository.
2. Open the SQL script in MySQL.
3. Create the database and table.
4. Update the `LOAD DATA INFILE` path to match your local CSV file.
5. Execute the script sequentially.
6. Run the analysis queries.

---

## Author

**Jay Mittal**

Aspiring Data Analyst

Building my portfolio one project at a time.
