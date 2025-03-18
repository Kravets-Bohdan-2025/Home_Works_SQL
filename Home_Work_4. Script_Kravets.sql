WITH facebook_data AS (
    SELECT
        ad_date,
        campaign_name,
        adset_name,
        spend,
        impressions,
        CASE WHEN reach <> '0' THEN CAST(reach AS INTEGER) ELSE NULL END AS reach,
        clicks,
        leads,
        CASE WHEN value <> '0' THEN CAST(value AS INTEGER) ELSE NULL END AS value,
        'Facebook Ads' AS media_source
    FROM
        facebook_ads_basic_daily
        INNER JOIN facebook_adset ON facebook_ads_basic_daily.adset_id = facebook_adset.adset_id
        INNER JOIN facebook_campaign ON facebook_ads_basic_daily.campaign_id = facebook_campaign.campaign_id
),
google_data AS (
    SELECT
        ad_date,
        NULL::varchar AS campaign_name,
        adset_name,
        spend,
        impressions,
        NULL::integer AS reach,
        clicks,
        leads,
        CASE WHEN value <> '0' THEN CAST(value AS INTEGER) ELSE NULL END AS value,
        'Google Ads' AS media_source
    FROM
        google_ads_basic_daily
)
SELECT
    ad_date,
    media_source,
    COALESCE(campaign_name, 'Google Ads') AS campaign_name,
    adset_name,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    MAX(reach) AS total_reach,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    MAX(value) AS total_total_value
FROM (
    SELECT * FROM facebook_data
    UNION ALL
    SELECT * FROM google_data
) combined_data
GROUP BY
    ad_date, media_source, campaign_name, adset_name
HAVING
    MAX(reach) IS NOT NULL;