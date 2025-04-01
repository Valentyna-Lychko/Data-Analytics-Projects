# Power BI: API Integration for Dashboard Creation

## Sales Data Analysis in a Supermarket

- Various functions were used for data computation and aggregation.
- Different types of visualizations were developed to analyze supermarket sales data.

---

## Project Description

This project demonstrates the process of creating an interactive dashboard in Power BI with API integration. The main goal is to enable automatic data retrieval from an external source, transformation, and visualization in a user-friendly format.

- Analyzed data from the Kaggle dataset "Supermarket Sales."

---

## Dataset Description

The "Supermarket Sales" dataset contains information about products, sellers, and customers who made transactions in a supermarket over a specific period.  
It is designed for analyzing product popularity, customer behavior, and sales trends based on dates.  
The dashboard also includes a currency conversion feature for easy data interpretation.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboard_Images/Sales_Analysis_with_Currency_Conversion.png)

---

## Data Analysis

- Sales analysis was performed using key metrics, including revenue, average product price, and total units sold.
- Interactive visualizations were created to explore trends over time, product categories, and payment methods.
- A single-selection "Currency" filter was added for currency conversion.

---

## External API Integration

- Connected to the National Bank of Ukraine API ([bank.gov.ua](https://bank.gov.ua)).
- Retrieved the latest exchange rate for the US dollar.
- Used the WEB connector in Power BI to load exchange rates.

### Data Sources:

1. National Bank of Ukraine - [bank.gov.ua](https://bank.gov.ua)  
2. Open Data - [bank.gov.ua/ua/open-data/api-dev](https://bank.gov.ua/ua/open-data/api-dev)  
3. Official exchange rates for foreign currencies and bank metals (JSON format).  

---

## Data Processing in Power BI

- Developed charts and visualizations, including time series, bar charts, and pie charts for data analysis.
- Calculated measures for key metrics (total revenue, average product price, etc.).
- Added a new "Currency" table with two rows: UAH and USD.
- Integrated a "Currency" filter to allow switching between currencies.
- Implemented automatic graph updates based on currency selection using DAX formulas.

---

### DAX Formulas Used:

#### Average Price:
```DAX
IF(
    MAX('Currency'[Currency]) = "UAH",
    AVERAGE('supermarket_sales - Sheet1 (2)'[Unit price]) * SUM(USD[rate]),
    AVERAGE('supermarket_sales - Sheet1 (2)'[Unit price])
)
```

#### Total by Currency:
```DAX
IF(
    MAX('Currency'[Currency]) = "UAH",
    SUM('supermarket_sales - Sheet1 (2)'[Total]) * SUM(USD[rate]),
    SUM('supermarket_sales - Sheet1 (2)'[Total])
)
```

- These measures were used for visualization.

---

## Deliverables

- Created a Power BI Desktop file.  
- Developed five visual components on a single dashboard.  
- Integrated an external API.  
- Implemented a currency conversion mechanism.

---

### Implementation Details

- **Sales by Payment Type:** A pie chart was built to analyze the distribution of sales by payment methods.  
- **Average Product Price per Category:** The average price for each product category was calculated and visualized using a bar chart.  
- **Total Revenue by Month:** The total revenue for each month was calculated and displayed on a line chart.  
- **Units Sold by Category and City:** A stacked bar chart was created to analyze sales distribution by city.  
- **Sales Volume Over Time:** A line chart was built to analyze sales trends over time.  

---

### API Integration:

- Connected to the National Bank of Ukraine API.
- Retrieved the latest exchange rate for the US dollar.
- Used the WEB connector in Power BI for exchange rate retrieval.
- Created a new "Currency" table (via Enter Data) with two rows: UAH and USD.
- Added a "Currency" filter for single selection.
- Implemented currency conversion using DAX formulas.

---

## Project Files:

- **[PBIX File](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboards/Sales_Analysis_with_Currency_Conversion.pbix)**  
  Power BI dashboard file.


---

This project enhances Power BI skills by creating analytical solutions based on real-world data.  

Other Power BI projects are available in the **Power BI Repository**.  

---
