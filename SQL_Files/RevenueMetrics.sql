WITH revenue_month AS (
    -- Creating a temporary table with monthly revenue aggregated by users and games
    SELECT
        DATE(DATE_TRUNC('month', payment_date)) AS payment_month, -- Rounding payment date to the month level
        user_id, -- User identifier
        game_name, -- Game name
        SUM(revenue_amount_usd) AS total_revenue -- Summing up the total revenue for the month
    FROM project.games_payments gp
    GROUP BY 1,2,3 -- Grouping by month, user, and game
),
revenue_lag_lead_months AS (
    -- Adding columns for previous and next months along with their revenue
    SELECT
        *,
        DATE(payment_month - INTERVAL '1' month) AS previous_claendar_month, -- Previous calendar month
        DATE(payment_month + INTERVAL '1' month) AS next_claendar_month, -- Next calendar month
        LAG(total_revenue) OVER(PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month_revenue, -- Revenue from the previous payment month
        LAG(payment_month) OVER(PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month, -- Previous payment month
        LEAD(payment_month) OVER(PARTITION BY user_id ORDER BY payment_month) AS next_paid_month, -- Next payment month
        LEAD(total_revenue) OVER(PARTITION BY user_id ORDER BY payment_month) AS next_total_revenue -- Revenue for the next payment month
    FROM revenue_month
),
revenue_metrics AS (
    -- Calculating revenue metrics, including new customers, churn, and expansion revenue
    SELECT
        payment_month, -- Payment month
        user_id, -- User identifier
        game_name, -- Game name
        total_revenue, -- Total revenue
        previous_claendar_month, -- Previous calendar month
        next_claendar_month, -- Next calendar month
        previous_paid_month_revenue, -- Revenue from the previous payment month
        previous_paid_month, -- Previous payment month
        next_paid_month, -- Next payment month
        next_total_revenue, -- Revenue for the next month
        CASE 
            WHEN previous_paid_month IS NULL 
                THEN total_revenue -- Revenue as new MRR if no previous payments exist
        END AS new_mrr,
        CASE 
            WHEN previous_paid_month = previous_claendar_month 
                AND total_revenue > previous_paid_month_revenue 
                THEN total_revenue - previous_paid_month_revenue -- Expansion MRR
        END AS exprension_mrr,
        CASE 
            WHEN previous_paid_month = previous_claendar_month 
                AND total_revenue < previous_paid_month_revenue 
                THEN total_revenue - previous_paid_month_revenue -- Contraction MRR
        END AS contraction_mrr,
        CASE 
            WHEN previous_paid_month != previous_claendar_month 
                AND previous_paid_month IS NOT NULL
                THEN total_revenue -- Revenue from returning customers
        END AS back_from_churn_revenue,
        CASE 
            WHEN next_paid_month IS NULL 
            OR next_paid_month != next_claendar_month
                THEN total_revenue -- Revenue from churned customers
        END AS churned_revenue,
        CASE 
            WHEN next_paid_month IS NULL 
            OR next_paid_month != next_claendar_month
                THEN next_claendar_month -- Calculated churn date
        END AS culc_churn
    FROM revenue_lag_lead_months
)
-- Final query joining additional user data
SELECT
    rm.*, -- All columns from revenue metrics table
    gpu.language AS user_language, -- User language
    gpu.age AS user_age, -- User age
    gpu.has_older_device_model, -- Indicator if the user has an older device model
    previous_claendar_month, -- Previous calendar month
    next_claendar_month, -- Next calendar month
    previous_paid_month_revenue, -- Revenue from the previous payment month
    previous_paid_month, -- Previous payment month
    next_paid_month, -- Next payment month
    next_total_revenue -- Revenue for the next month
FROM revenue_metrics rm
LEFT JOIN project.games_paid_users gpu USING(user_id); -- Joining with the user data table