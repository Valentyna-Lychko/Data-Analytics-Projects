-- This SQL query is designed for the SQLLookerStudio project.
-- It is used for loading data into Looker Studio.

-- CTE: Joining data from Facebook tables
WITH facebook_home AS (
    SELECT *
    FROM facebook_campaign fc 
    LEFT JOIN facebook_ads_basic_daily fabd ON fc.campaign_id = fabd.campaign_id -- Joining with daily ad data
    LEFT JOIN facebook_adset fa ON fa.adset_id = fabd.adset_id -- Joining with ad set data
),

-- CTE: Merging Facebook and Google Ads data
campaign_name_daily AS (
    SELECT 
        ad_date, -- Ad display date
        campaign_name, -- Campaign name
        spend, -- Ad spend
        impressions, -- Number of impressions
        clicks, -- Number of clicks
        value -- Total conversion value
    FROM facebook_home
    UNION -- Combining with Google Ads data
    SELECT 
        ad_date, 
        campaign_name,
        spend,
        impressions,
        clicks,
        value
    FROM public.google_ads_basic_daily
)

-- Final query: Aggregating data by date and campaign
SELECT 
    ad_date, -- Ad display date
    campaign_name, -- Campaign name
    SUM(spend) AS spend, -- Total ad spend
    SUM(impressions) AS impressions, -- Total number of impressions
    SUM(clicks) AS clicks, -- Total number of clicks
    SUM(value) AS value -- Total conversion value
FROM campaign_name_daily
WHERE clicks > 0 -- Filter: Include only days with clicks
GROUP BY 
    ad_date, -- Grouping by date
    campaign_name -- Grouping by campaign name
ORDER BY ad_date DESC; -- Sorting by date in descending order


	
