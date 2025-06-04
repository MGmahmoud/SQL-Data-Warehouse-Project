<!-- Banner -->
<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0E76A8&height=200&section=header&text=SQL%20Data%20Warehouse%20Project&fontSize=35&fontColor=ffffff" alt="banner"/>
</p>

<h1 align="center">🏗️ SQL Data Warehouse Project</h1>
<h3 align="center">End-to-End Data Engineering Project Using Medallion Architecture</h3>


---

## Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.

---
## Data Integration 

I explored the data sources to understand their content and interrelationships.
Then designed a Data Integration Diagram to visualize the source systems and how they connect, making it easy to grasp the structure at a glance.

![DWH-Integration Model](https://github.com/user-attachments/assets/dc0c6f7c-a266-4fc2-9971-c81dd0d1a51a)
---

## Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![DWH Architecture](https://github.com/user-attachments/assets/0613a37f-e13e-47f1-94a6-0a04baba3545)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
## Data Flow 
To clearly communicate how data moves through the architecture, I built a Data Flow Diagram. It maps each source to its destination:

* dim_customers is built from 3 tables
* dim_products is created from 2 tables
* fact_sales is derived from 1 primary source

This diagram makes it easier to trace the lineage of each table and understand dependencies within the model.

![DWH-Data Flow](https://github.com/user-attachments/assets/ee6ddcda-7a16-4f02-9ece-22cb65a749a4)

---
## Data Mart
The final layer is a well-designed Data Mart using a Star Schema that supports fast querying and business-friendly reporting:

* dim_customers: Enriched with geographic and demographic info
* dim_products: Merged from product and category details
* fact_sales: The central table containing sales transactions with foreign keys to dimension tables

I’ve also defined clear relationships and documented key measures to ensure accurate interpretation of metrics during analysis.

![DWH-Sales Data Mart](https://github.com/user-attachments/assets/bc478708-f135-4c54-9fa4-0ad291e78f08)

---

## 📂 Repository Structure
```
Data-Warehouse-Project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── data_architecture.png           # Draw.io file shows the project's architecture
│   ├── data_integration.png            # Draw.io file shows how the data files are related
│   ├── data_flow.png                   # Draw.io file for the data flow diagram
│   ├── data_models.png                 # Draw.io file for data models (star schema)
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository

```
---

## 🌟 About Me

I'm **Mahmoud Elhelaly**, a data analyst with a passion for transforming raw numbers into strategic insights.
Armed with skills in **SQL**, **Power BI**, **Excel**, and **Python**, I build robust data solutions—from clean data pipelines to interactive dashboards.

I enjoy working on end-to-end data projects, especially those that require structured thinking, business understanding, and visual storytelling.
Currently, I’m focused on mastering data engineering and business intelligence by tackling real-world projects like this one.

I believe in continuous learning and love sharing what I build to inspire and connect with others in the data community.

Let’s connect on 
[LinkedIn](https://www.linkedin.com/in/mahmoud--elhelaly/)

or feel free to reach out if you're working on a project that needs a structured thinker and a passionate data enthusiast.

> 📧 elhelalymahmoud001@gmail.com
> 
>📞 +20 100 076 7912
