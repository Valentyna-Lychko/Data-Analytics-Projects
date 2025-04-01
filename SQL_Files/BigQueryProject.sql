-- Analysis of eCommerce in BigQuery
-- Data obtained from Google Analytics 4 (GA4) was analyzed to:

-- 1. Create tables with user events, sessions, and purchases

SELECT 
    timestamp_micros(event_timestamp) AS event_timestamp, -- Converts the event timestamp from microseconds into a readable date and time format
    user_pseudo_id, -- Unique pseudo-identifier for the user
    (
        SELECT value.int_value 
        FROM a.event_params 
        WHERE key = 'ga_session_id'
    ) AS session_id, -- User session ID extracted from event parameters
    event_name, -- Name of the event (e.g., item view, add to cart, purchase)
    geo.country AS country, -- The country where the event occurred, based on geolocation
    device.category AS device_category, -- Device category (e.g., desktop, mobile, tablet)
    traffic_source.source AS source, -- Traffic source (e.g., google, shop.googlemerchandisestore.com, <Other>)
    traffic_source.medium AS medium, -- Type of traffic (e.g., organic, cpc, referral, <Other>)
    traffic_source.name AS campaign -- Name of the marketing campaign (e.g., direct, organic, <Other>)
FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*` a -- Retrieves data from a set of tables for the year 2021
WHERE 
    event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase') 
    -- Filters for events related to user interactions with the platform
LIMIT 1000; -- Limits the result to the first 1000 records


-- Step 2: Calculating conversion rates between funnel stages

-- Creating a table with user events, sessions, and purchases
WITH bq_events AS (
    SELECT
        timestamp_micros(event_timestamp) AS event_timestamp, -- Converts the event timestamp from microseconds into a standard date and time format
        event_name, -- Name of the event (e.g., session_start, add_to_cart, purchase, etc.)
        user_pseudo_id || CAST(
            (SELECT value.int_value FROM UNNEST(e.event_params) WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id, -- Unique identifier for the user's session
        traffic_source.source AS source, -- Traffic source
        traffic_source.medium AS medium, -- Traffic medium
        traffic_source.name AS campaign -- Name of the marketing campaign
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Data from GA4 sample eCommerce tables
    WHERE 
        event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase') -- Filters for key events in the funnel
),

-- Aggregating data to calculate metrics between funnel stages
event_name_count AS (
    SELECT
        DATE(event_timestamp) AS event_date, -- Converts the event timestamp to a date format (without time)
        source, -- Traffic source
        medium, -- Traffic medium
        campaign, -- Marketing campaign name
        COUNT(DISTINCT user_session_id) AS user_sessions_count, -- Total number of user sessions
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS added_to_cart_count, -- Number of users who added an item to the cart
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count, -- Number of users who started the checkout process
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchase_count -- Number of purchases
    FROM 
        bq_events -- User event data gathered in the previous step
    GROUP BY 
        1, 2, 3, 4 -- Grouping by date, source, medium, and campaign
)

-- Final calculation of conversion rates
SELECT 
    event_date, -- Event date
    source, -- Traffic source
    medium, -- Traffic medium
    campaign, -- Campaign name
    user_sessions_count, -- Total number of user sessions
    ROUND(added_to_cart_count / user_sessions_count * 100, 2) AS visit_to_cart, -- Percentage of visits that resulted in adding items to the cart
    ROUND(begin_checkout_count / user_sessions_count * 100, 2) AS visit_to_checkout, -- Percentage of visits that resulted in starting checkout
    ROUND(purchase_count / user_sessions_count * 100, 2) AS visit_to_purchase -- Percentage of visits that resulted in a purchase
FROM 
    event_name_count -- Aggregated data with event metrics
ORDER BY 
    1; -- Sorting by the event date


-- Step 3: Analyzing traffic sources and user activity

-- Creating a table for user session events, including page paths, URLs, and traffic sources
WITH bq_events AS (
    SELECT
        -- Unique identifier for the user's session
        user_pseudo_id || 
        CAST(
            (SELECT value.int_value 
             FROM UNNEST(e.event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id,
        
        -- Extracts the page path from the page_location parameter using a regular expression
        REGEXP_EXTRACT(
            (SELECT value.string_value 
             FROM UNNEST(event_params) 
             WHERE key = 'page_location'),
            r'(?:\w+\:\/\/)?[^\/]+\/([^\?#]*)'
        ) AS page_path,
        
        -- Full URL of the page (page_location)
        (SELECT value.string_value 
         FROM UNNEST(event_params) 
         WHERE key = 'page_location') AS page_location
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Data from GA4 tables for the entire year 2020
    WHERE
        _table_suffix BETWEEN '20200101' AND '20201231' -- Filters data for the specified period (entire year 2020)
        AND event_name = 'session_start' -- Events corresponding to user session starts
),

-- Creating a table for user purchase events
event_purchase AS (
    SELECT 
        -- Unique identifier for the user's session
        user_pseudo_id || 
        CAST(
            (SELECT value.int_value 
             FROM e.event_params 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id    
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Data from GA4 tables for the entire year 2020
    WHERE
        _table_suffix BETWEEN '20200101' AND '20201231' -- Filters data for the specified period (entire year 2020)
        AND event_name = 'purchase' -- Events corresponding to user purchases
)

-- Calculating metrics for user activity and purchases
SELECT
    s.page_path, -- Page path
    COUNT(DISTINCT s.user_session_id) AS sessions_count, -- Number of unique sessions
    COUNT(DISTINCT p.user_session_id) AS purchases_count, -- Number of unique purchases
    COUNT(DISTINCT p.user_session_id) / COUNT(DISTINCT s.user_session_id) AS cr_to_purchase -- Conversion rate to purchase
FROM 
    bq_events s  
    LEFT JOIN event_purchase p ON s.user_session_id = p.user_session_id -- Joining sessions with purchases
GROUP BY 
    1 -- Grouping by page path
ORDER BY 
    2 DESC; -- Sorting by session count in descending order


-- Step 4: Examining the relationship between user activity and their purchases

-- Creating a table with user sessions and counting the number of events in each session
WITH user_sessions AS (
    SELECT
        -- Unique identifier for the user's session
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS session_id,
        
        -- Number of events in the session
        COUNT(*) AS events_count 
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` -- Data from GA4 tables
    WHERE 
        _table_suffix BETWEEN '20200101' AND '20201231' -- Filters data for the specified period (entire year 2020)
    GROUP BY 
        session_id -- Groups by the unique user session
),

-- Creating a table with sessions that resulted in a purchase
purchases AS (
    SELECT
        -- Unique identifier for the user's session
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS session_id,
        
        -- Flag indicating the session resulted in a purchase
        1 AS purchase_flag
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` -- Data from GA4 tables
    WHERE 
        _table_suffix BETWEEN '20200101' AND '20201231' -- Filters data for the specified period (entire year 2020)
        AND event_name = 'purchase' -- Filters events to include only purchases
)

-- Relationship between user activity (number of events in a session) and purchases
SELECT
    u.events_count, -- Number of events in a session
    COUNT(p.session_id) AS purchase_count -- Number of purchases in sessions with the given activity level
FROM 
    user_sessions u
LEFT JOIN 
    purchases p ON u.session_id = p.session_id -- Joins the sessions table with the purchases table
GROUP BY 
    u.events_count -- Groups by the number of events in a session
ORDER BY 
    u.events_count; -- Sorts by the number of events in a session


-- Step 5: Preparing data for visualization in Looker Studio

-- Stage 1: Creating a table with key user events and traffic source information
WITH bq_events AS (
    SELECT
        timestamp_micros(event_timestamp) AS event_timestamp, -- Converts event timestamp from microseconds to a standard date and time format
        event_name, -- Event name (session_start, add_to_cart, begin_checkout, purchase)
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(e.event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id, -- Unique session identifier for the user
        traffic_source.source AS source, -- Traffic source (e.g., google, shop.googlemerchandisestore.com, <Other>)
        traffic_source.medium AS medium, -- Type of traffic (e.g., organic, cpc, referral, <Other>)
        traffic_source.name AS campaign -- Marketing campaign name (e.g., direct, organic, <Other>)
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Data from GA4 eCommerce tables
    WHERE 
        event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase') -- Filters events related to the sales funnel
),

-- Stage 2: Aggregating data to calculate the number of events at each funnel stage
event_name_count AS (
    SELECT
        DATE(event_timestamp) AS event_date, -- Converts event timestamp to date format (without time)
        source, -- Traffic source
        medium, -- Type of traffic
        campaign, -- Campaign name
        COUNT(DISTINCT user_session_id) AS user_sessions_count, -- Number of unique user sessions
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS added_to_cart_count, -- Number of sessions with items added to cart
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count, -- Number of sessions with checkout started
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchase_count -- Number of sessions with purchases completed
    FROM 
        bq_events -- Key user event data from Stage 1
    GROUP BY 
        1, 2, 3, 4 -- Grouping by date, source, traffic type, and campaign name
),

-- Stage 3: Creating a table for sales funnel stages with conversion rate calculations
funnel_stages AS (
    SELECT 
        event_date, -- Event date
        source, -- Traffic source
        medium, -- Type of traffic
        campaign, -- Campaign name
        'Session Start' AS stage, -- Funnel stage: Session Start
        user_sessions_count AS value, -- Number of sessions at this stage
        100 AS conversion_rate -- Baseline conversion rate for the first stage (100%)
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Add to Cart' AS stage, -- Funnel stage: Add to Cart
        added_to_cart_count AS value, -- Number of sessions with items added to the cart
        ROUND(added_to_cart_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Conversion rate from sessions to added-to-cart
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Begin Checkout' AS stage, -- Funnel stage: Begin Checkout
        begin_checkout_count AS value, -- Number of sessions with checkout started
        ROUND(begin_checkout_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Conversion rate from added-to-cart to checkout
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Purchase' AS stage, -- Funnel stage: Purchase
        purchase_count AS value, -- Number of completed purchases
        ROUND(purchase_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Conversion rate from checkout to purchase
    FROM 
        event_name_count
)

-- Stage 4: Creating the final table for visualization in Looker Studio
SELECT 
    event_date, -- Event date
    source, -- Traffic source
    medium, -- Type of traffic
    campaign, -- Campaign name
    stage, -- Funnel stage
    value, -- Number of events at the stage
    conversion_rate -- Conversion rate for the stage
FROM 
    funnel_stages -- Data for all funnel stages
ORDER BY 
    event_date, -- Sorting by date
    CASE 
        WHEN stage = 'Session Start' THEN 1
        WHEN stage = 'Add to Cart' THEN 2
        WHEN stage = 'Begin Checkout' THEN 3
        WHEN stage = 'Purchase' THEN 4
    END; -- Sorting by funnel stages
