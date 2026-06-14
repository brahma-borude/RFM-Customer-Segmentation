-- calculating R, F, M For each customer
WITH rfm_base AS (
	SELECT 
		customer_id,
		country,
		-- RECENCY: days since last purchase
		('2011-12-10'::DATE - MAX(invoice_date))::INT AS recency_days,
		-- FREQUENCY: number of distinct orders 
		COUNT(DISTINCT invoice_no) AS frequency,
		-- MONETARY: total spend
		ROUND(SUM(line_total), 2)AS monetary
	FROM clean_transactions
	GROUP BY customer_id
),
rfm_scores AS (
	SELECT
		customer_id, country,
		recency_days, frequency, monetary,
		NTILE(5) OVER(ORDER BY recency_days DESC) AS r_score,
		NTILE(5) OVER(ORDER BY frequency ASC) AS f_score,
		NTILE(5) OVER(ORDER BY monetary ASC) AS m_score
	FROM rfm_base
)

SELECT
	customer_id,
	country,
	recency_days,
	frequency,
	monetary,
	r_score,
	f_score,
	m_score,
	CONCAT(r_score, f_score, m_score) as rfm_string,
	ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_score
FROM rfm_scores
ORDER BY rfm_score DESC;


-- Save as a table
CREATE TABLE rfm_scored AS
WITH rfm_base AS (
	SELECT 
		customer_id,
		MODE() WITHIN GROUP (ORDER BY country) AS country,
		('2011-12-10'::DATE - MAX(invoice_date))::INT AS recency_days, 
		COUNT(DISTINCT invoice_no) AS frequency,
		ROUND(SUM(line_total), 2)AS monetary
	FROM clean_transactions
	GROUP BY customer_id
),
rfm_scores AS (
	SELECT
		customer_id, country, 
		recency_days, frequency, monetary,
		NTILE(5) OVER(ORDER BY recency_days DESC) AS r_score,
		NTILE(5) OVER(ORDER BY frequency ASC) AS f_score,
		NTILE(5) OVER(ORDER BY monetary ASC) AS m_score
	FROM rfm_base
)
SELECT
	customer_id, country, 
	recency_days, frequency, monetary,
	r_score, f_score, m_score,
	CONCAT(r_score, f_score, m_score) as rfm_string,
	ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_score
FROM rfm_scores;


-- verify 
SELECT COUNT(*) FROM rfm_scored;
SELECT * FROM rfm_scored LIMIT 5;

SELECT m_score,
	ROUND(AVG(monetary)::numeric, 0) as avg_spend,
	COUNT(*) as customers
from rfm_scored
group by m_score
order by m_score;

select * from rfm_segments;