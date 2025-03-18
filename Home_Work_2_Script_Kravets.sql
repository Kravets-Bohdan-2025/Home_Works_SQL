/**
select ad_date, campaign_id, sum(spend) as total_spend, sum(impressions) as total_impr, sum(clicks) as total_clicks, sum(value) as total_value_conver
from facebook_ads_basic_daily
group by ad_date, campaign_id;

/**
select
    ad_date,
    campaign_id,
    sum(spend) as total_spend,
    sum(impressions) as total_impressions,
    sum(clicks) as total_clicks,
    sum(value) as total_value_conversions,
    sum(spend) :: numeric / sum(clicks) as cpc,
    sum(spend)  :: numeric / sum(impressions) * 1000 as cpm,
    sum(clicks)  :: numeric / sum(impressions) * 100 as ctr,
    ((sum(value) - sum(spend))  :: numeric / sum(spend)) * 100 as romi
from
    facebook_ads_basic_daily
where clicks > 0 and impressions > 0 and spend > 0 
group by
    ad_date, campaign_id;
    
BONUS
/**
select *
from (
    select
        campaign_id,
        ((sum(value) - sum(spend)) :: numeric / nullif(sum(spend), 0)) * 100 as romi
    from
        facebook_ads_basic_daily
    group by
        campaign_id
    having
        SUM(spend) > 500000
) as subquery;
**/
