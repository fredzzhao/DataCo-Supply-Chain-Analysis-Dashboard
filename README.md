# DataCo Supply Chain Analysis Dashboard

## Project Overview
This project is an end-to-end supply chain analysis built with **Power BI** and **SQL**. It provides actionable insights into delivery performance, financial metrics, and fraud risks for DataCo's global operations.

The dashboard empowers stakeholders to:
* Monitor real-time KPIs (OTD, Profit Margin, Sales).
* Identify bottlenecks in shipping modes (Standard vs. First Class).
* Detect high-risk fraud regions.

---

## Key Insights
Based on the analysis of the dataset:
* **Financials:** Generated **$33.05M** in revenue with a **12.00%** overall profit margin.
* **Logistics Struggle:** The On-Time Delivery (OTD) rate is currently **45.17%**, with "Late Delivery" being a significant pain point in Standard Class shipping.
* **Risk Management:** Identified a **2.26%** fraud rate, with specific hotspots in Western Europe markets requiring immediate attention.

---

## Tech Stack
* **Visualization:** Power BI Desktop (DAX Measures, Interactive Dashboards)
* **Data Validation:** SQL Server (T-SQL)
* **Data Source:** DataCo Global Supply Chain Dataset (CSV/Excel)

---

## Repository Structure
```text
├── assets/                  # Dashboard screenshots (Executive Summary, Risk Analysis)
├── sql_queries/             # SQL scripts used for data validation & reconciliation
│   └── data_validation_and_exploration.sql  # Validates Revenue, Late Rates, and Profit Margins
├── Supply_Chain_Report.pdf  # Full PDF export of the analysis
├── Supply_Chain_Analysis.pbix # Source Power BI file
└── README.md                # Project documentation
