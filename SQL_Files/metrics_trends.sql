-- This code combines and analyzes advertising campaign data from Facebook and Google Ads,
-- calculating key metrics (CPC, CTR, CPM, ROMI) and their dynamics

-- CTE: Combining data from Facebook Campaigns
WITH facebook_home AS (
    SELECT *
    FROM facebook_campaign fc
    LEFT JOIN facebook_ads_basic_daily fabd ON fc.campaign_id = fabd.campaign_id -- Joins with the daily data table
    LEFT JOIN facebook_adset fa ON fa.adset_id = fabd.adset_id -- Joins with the ad set table
),

-- CTE: Creating a unified table for daily data
campaign_name_daily AS (
    SELECT 
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend, -- Replaces NULL values with 0 for spend
        COALESCE(impressions, 0) AS impressions, -- Replaces NULL for impressions
        COALESCE(clicks, 0) AS clicks, -- Replaces NULL for clicks
        COALESCE(value, 0) AS value -- Replaces NULL for conversion value
    FROM facebook_home
    UNION ALL
    SELECT 
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend, -- Data from Google Ads
        COALESCE(impressions, 0) AS impressions,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(value, 0) AS value
    FROM public.google_ads_basic_daily
),

-- CTE: Grouping data by months and calculating metrics
campaign_name_monthly AS (
    SELECT
        DATE_TRUNC('month', ad_date)::date AS ad_month, -- Truncates the date to the start of the month
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&#$]+)')) != 'nan'
                THEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&#$]+)')) -- Extracts utm_campaign
            ELSE NULL
        END AS utm_campaign,
        SUM(spend) AS sum_spend, -- Total spend
        SUM(impressions) AS sum_impressions, -- Total impressions
        SUM(clicks) AS sum_clicks, -- Total clicks
        SUM(value) AS sum_value, -- Total conversions
        CASE WHEN SUM(clicks) > 0 THEN ROUND(SUM(spend)::numeric / SUM(clicks), 2) ELSE 0 END AS cpc, -- Cost per click
        CASE WHEN SUM(impressions) > 0 THEN ROUND(SUM(clicks)::numeric / SUM(impressions) * 100, 2) ELSE 0 END AS ctr, -- Click-through rate
        CASE WHEN SUM(impressions) > 0 THEN ROUND(SUM(spend)::numeric / SUM(impressions) * 1000, 2) ELSE 0 END AS cpm, -- Cost per 1000 impressions
        CASE WHEN SUM(spend) > 0 THEN ROUND(SUM(value - spend)::numeric / SUM(spend) * 100, 2) ELSE 0 END AS romi -- Return on marketing investment
    FROM campaign_name_daily
    GROUP BY ad_month, utm_campaign -- Groups by month and campaign
),

-- CTE: Comparing current and previous metric values
previous_month_campaign_name AS (
    SELECT
        ad_month,
        utm_campaign,
        cpc, ctr, cpm, romi,
        LAG(cpc, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_cpc, -- Previous CPC value
        LAG(ctr, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_ctr, -- Previous CTR value
        LAG(cpm, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_cpm, -- Previous CPM value
        LAG(romi, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_romi -- Previous ROMI value
    FROM campaign_name_monthly
)

-- Final Query: Calculating percentage changes in metrics
SELECT *,
    CASE 
        WHEN previous_cpc > 0 THEN ROUND((cpc::numeric / previous_cpc - 1), 2) -- Percentage change in CPC
        WHEN previous_cpc = 0 AND cpc > 0 THEN 1
    END AS cpc_change,
    CASE 
        WHEN previous_ctr > 0 THEN ROUND((ctr::numeric / previous_ctr - 1), 2) -- Percentage change in CTR
        WHEN previous_ctr = 0 AND ctr > 0 THEN 1
    END AS ctr_change,
    CASE 
        WHEN previous_cpm > 0 THEN ROUND((cpm::numeric / previous_cpm - 1), 2) -- Percentage change in CPM
        WHEN previous_cpm = 0 AND cpm > 0 THEN 1
    END AS cpm_change,
    CASE 
        WHEN previous_romi > 0 THEN ROUND((romi::numeric / previous_romi - 1), 2) -- Percentage change in ROMI
        WHEN previous_romi = 0 AND romi > 0 THEN 1
    END AS romi_change
FROM previous_month_campaign_name;
