WITH google_cte AS (
    SELECT
        ad_date,
        'Google Ads' as media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM
        google_ads_basic_daily
),
facebook_cte AS (
    SELECT
        ad_date,
        'Facebook Ads' as media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM
        facebook_ads_basic_daily
),
Google_Facebook_data AS (
    SELECT * FROM google_cte
    UNION ALL
    SELECT * FROM facebook_cte
)
SELECT
    ad_date,
    media_source,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(reach) AS total_reach,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(value) AS total_value
FROM
    Google_Facebook_data
GROUP BY
    ad_date, media_source
ORDER BY
    ad_date, media_source;