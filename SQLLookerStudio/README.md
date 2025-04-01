# SQL and Looker Studio

## Project Description
This project demonstrates the practical application of SQL in PostgreSQL and BigQuery for data processing, as well as the creation of interactive dashboards in Looker Studio. The example uses advertising campaign data from Facebook and Google Ads, as well as user interactions on an eCommerce platform. The dashboards illustrate Looker Studio's ability to integrate with databases, providing convenient access to and processing of information.

The SQL queries use Common Table Expressions (CTEs), window functions, data merging operations (JOIN, UNION), aggregation functions, date and text functions, and conditional logic functions.

---

## SQL in PostgreSQL: Marketing Metrics
Working with advertising platform data from Facebook and Google Ads included two approaches:

### 1. SQL Query for Looker Studio
- Data merging and aggregation of advertising campaign data.
- Uploading to Looker Studio for metric calculations: CTR, CPC, CPM, and ROMI.  
[SQL for Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/prepare_looker.sql)

### 2. Advanced SQL Analysis
- Calculating metrics and their trends directly in SQL.
- Analyzing percentage changes between months.
  
[Advanced SQL Analysis](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/metrics_trends.sql)

### Metrics
The project demonstrates two methods for calculating metrics: within SQL queries and using calculated fields in Looker Studio. Specifically:
- **CPC (Cost per Click)** = Ad Spend / Clicks
- **CPM (Cost per Mille)** = (Ad Spend * 1000) / Impressions
- **CTR (Click-Through Rate)** = (Clicks / Impressions) * 100
- **ROMI (Return on Marketing Investment)** = (Value - Ad Spend) / Ad Spend * 100

---

## SQL in BigQuery: eCommerce Analysis
Data from Google Analytics 4 (GA4) was used to:
- Generate tables with user events, sessions, and purchases.
- Calculate conversion rates between funnel stages.
- Analyze traffic sources and user activity.
- Explore the relationship between user activity and purchases.
- Prepare data for visualization in Looker Studio.  
[SQL in BigQuery for eCommerce](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/BigQueryProject.sql)

---

## Visualization in Looker Studio
Looker Studio enabled interactive data analysis:

### 1. Marketing Metrics from PostgreSQL
- Spending and profitability trends.
- Changes in the number of campaigns over time.
- Comparison of key metrics across campaigns.
   
![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboard_Images/Marketing_metrics_with_looker.png)


### 2. eCommerce Data from BigQuery
- Conversion funnels analyzing visitor stages from product view to purchase.
- User activity analysis by traffic sources, session frequency, and conversions.
  
![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboard_Images/eCommerce_BigQuery.png)

---

## Results
- In PostgreSQL, Facebook and Google Ads data was merged and uploaded to Looker Studio for analysis.
- Two methods of metric calculation were implemented: in PostgreSQL SQL queries and using calculated fields in Looker Studio.
- In BigQuery, eCommerce data was processed and connected to Looker Studio for interactive analysis.
- Dashboards were created to visualize advertising campaigns and user behavior on the eCommerce platform.

---

## Resource Links
- [SQL for Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/prepare_looker.sql)
- [Advanced SQL Analysis](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/metrics_trends.sql)
- [SQL for eCommerce](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/SQL_Files/BigQueryProject.sql)
- [Marketing Metrics Dashboard in Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboard_Images/Marketing_metrics_with_looker.png)
- [eCommerce Data Dashboard in Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects/blob/main/Dashboard_Images/eCommerce_BigQuery.png)

---

## Conclusion

1. **SQL: A Powerful Tool**  
   PostgreSQL and BigQuery enable efficient data aggregation, processing, and complex metric calculations. This project processed advertising campaign data from Facebook and Google Ads, as well as user interactions on an eCommerce platform.  

2. **Looker Studio: Integration and Visualization**  
   Looker Studio demonstrates the ability to integrate with various databases, such as PostgreSQL and BigQuery, providing accessibility for further analysis. The tool allows for the creation of interactive dashboards for deeper analytical insights.  

3. **Flexible Approach to Metric Calculation**  
   Metrics were calculated both in SQL (PostgreSQL and BigQuery) and using calculated fields in Looker Studio, allowing the choice of the most convenient tool depending on the task.


---
