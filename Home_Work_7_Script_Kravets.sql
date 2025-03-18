WITH CombinedData AS (
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM google_ads_basic_daily gabd
    UNION ALL
    SELECT 
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM facebook_ads_basic_daily fabd 
),
MetricsByMonth AS (
    SELECT 
        DATE_TRUNC('month', ad_date) AS ad_month,
        ad_date,
        LOWER(
            CASE 
                WHEN url_parameters LIKE '%utm_campaign=nan%' THEN NULL
                ELSE SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')
            END
        ) AS utm_campaign,
        SUM(spend) AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(value) AS total_value,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE SUM(clicks) / SUM(impressions)
        END AS CTR,
        CASE 
            WHEN SUM(clicks) = 0 THEN 0
            ELSE SUM(spend) / SUM(clicks)
        END AS CPC,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE (SUM(spend) * 1000) / SUM(impressions)
        END AS CPM,
        CASE 
            WHEN SUM(spend) = 0 THEN 0
            ELSE SUM(value) / SUM(spend)
        END AS ROMI,
        ROW_NUMBER() OVER(PARTITION BY LOWER(
            CASE 
                WHEN url_parameters LIKE '%utm_campaign=nan%' THEN NULL
                ELSE SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')
            END
        ), DATE_TRUNC('month', ad_date) ORDER BY ad_date) AS month_order
    FROM CombinedData
    GROUP BY ad_month, ad_date, utm_campaign
)
SELECT 
    ad_month,
    utm_campaign,
    total_spend,
    total_impressions,
    total_clicks,
    total_value,
    CTR,
    CPC,
    CPM,
    ROMI,
    ROUND(
        (CPM - LAG(CPM) OVER(PARTITION BY utm_campaign ORDER BY ad_month)) / NULLIF(LAG(CPM) OVER(PARTITION BY utm_campaign ORDER BY ad_month), 0) * 100,
        2
    ) AS cpm_difference_perc,
    ROUND(
        (CTR - LAG(CTR) OVER(PARTITION BY utm_campaign ORDER BY ad_month)) / NULLIF(LAG(CTR) OVER(PARTITION BY utm_campaign ORDER BY ad_month), 0) * 100,
        2
    ) AS ctr_difference_perc,
    ROUND(
        (ROMI - LAG(ROMI) OVER(PARTITION BY utm_campaign ORDER BY ad_month)) / NULLIF(LAG(ROMI) OVER(PARTITION BY utm_campaign ORDER BY ad_month), 0) * 100,
        2
    ) AS romi_difference_perc
FROM MetricsByMonth
WHERE month_order = 1;
