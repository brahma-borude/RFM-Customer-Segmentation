-- Full segment summary for manaagement report
SELECT
	segment,
	COUNT(*) AS customers,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_customers,
	ROUND(SUM(monetary), 0) AS total_revenue,
	ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER(), 1) AS pct_revenue,
	ROUND(AVG(monetary), 0) AS avg_customer_value,
	ROUND(AVG(recency_days), 0) AS avg_recency_days,
	ROUND(AVG(frequency), 1) AS avg_orders,
	marketing_priority
FROM rfm_segments
GROUP BY segment, marketing_priority 
ORDER BY marketing_priority;

-- what % of customers drive 80% of revenue?
WITH revenue_by_segment AS (
	SELECT
		segment,
		COUNT(*) AS customers,
		SUM(monetary) AS revenue
	FROM rfm_segments
	GROUP BY segment
),
total AS(
	SELECT 
		SUM(customers) AS total_customers,
		SUM(revenue) AS total_revenue
	FROM revenue_by_segment
)
SELECT
	r.segment,
	r.customers,
	ROUND(r.customers * 100.0 / t.total_customers, 1) AS pct_customers,
	ROUND(r.revenue, 0) as revenue,
	ROUND(r.revenue * 100.0 / t.total_revenue, 1) AS pct_revenue,
	-- revenue per customer vs average
	ROUND(r.revenue / r.customers, 0) AS revenue_per_customer,
	ROUND((r.revenue / r.customers) / 
		  (t.total_revenue / t.total_customers), 2) AS vs_avg_multiplier
FROM revenue_by_segment r, total t
ORDER BY r.revenue DESC;

-- Top countries by segment 
SELECT 
	country,
	segment,
	COUNT(*) AS customers,
	ROUND(SUM(monetary), 0) AS revenue
FROM rfm_segments
GROUP BY country, segment
HAVING COUNT(*) >= 5
ORDER BY country, revenue DESC;

-- at-risk customers by country - who to target first
SELECT 
	country,
	COUNT(*) AS at_risk_customers,
	ROUND(SUM(monetary), 0) AS at_risk_revenue
FROM rfm_segments
WHERE segment = 'At Risk'
GROUP BY country
ORDER BY at_risk_revenue DESC
LIMIT 10;

-- Validate NTILE worked correctly - each score should have ~equal count
SELECT r_score, COUNT(*) AS customers
FROM rfm_segments
GROUP BY r_score ORDER BY r_score;

SELECT f_score, COUNT(*) AS customers
FROM rfm_segments
GROUP BY f_score ORDER BY f_score;

SELECT m_score, COUNT(*) AS customers
FROM rfm_segments
GROUP BY m_score ORDER BY m_score;

-- Average RFM values per score to verify direction
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_customers,
    ROUND(AVG(monetary)::NUMERIC, 0) AS avg_spend,
    ROUND(AVG(recency_days)::NUMERIC, 0) AS avg_recency_days
FROM rfm_segments
GROUP BY segment
ORDER BY avg_spend DESC;


select 
	segment,
	count(*) as customers,
	(sum(monetary)::numeric, 2) as total_revenue,
	round(avg(monetary)::numeric, 0) as avg_spend,
	round(avg(r_score)::numeric, 1) as avg_r,
	round(avg(f_score)::numeric, 1) as avg_f,
	round(avg(m_score)::numeric, 1) as avg_m
from rfm_segments
group by segment
order by avg_spend desc;

select * from rfm_segments;
