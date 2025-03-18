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
)
SELECT 
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
    SUM(leads) AS total_leads,
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
    END AS ROMI
FROM CombinedData
GROUP BY ad_date, utm_campaign;
