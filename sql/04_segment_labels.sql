DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments AS
SELECT
    customer_id, country, recency_days, frequency, monetary,
    r_score, f_score, m_score, rfm_string, rfm_score,

    CASE
        WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 4 AND m_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'
        WHEN r_score >= 4 AND f_score = 1
            THEN 'New Customers'
        WHEN r_score = 3 AND f_score = 3
            THEN 'Need Attention'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        WHEN r_score = 1 AND f_score >= 4 AND m_score >= 4
            THEN 'Cannot Lose Them'
        WHEN r_score = 2 AND f_score <= 2
            THEN 'About to Sleep'
        WHEN r_score = 1 AND f_score = 1
            THEN 'Lost'
		WHEN r_score <= 2 AND f_score <= 2
            THEN 'Hibernating'
        ELSE 'Others'
    END AS segment,

    CASE
        WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 1
        WHEN r_score >= 3 AND f_score >= 4 AND m_score >= 3 THEN 2
        WHEN r_score >= 4 AND f_score <= 2 THEN 3
        WHEN r_score <= 2 AND f_score >= 3 THEN 4
        WHEN r_score <= 2 AND f_score <= 2 THEN 5
        ELSE 6
    END AS marketing_priority

FROM rfm_scored;

-- Verification — Champions must have highest avg spend
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0
          / (SELECT COUNT(*) FROM rfm_segments), 1) AS pct,
    ROUND(AVG(monetary)::NUMERIC, 0) AS avg_spend,
    ROUND(AVG(r_score)::NUMERIC, 1) AS avg_r,
    ROUND(AVG(f_score)::NUMERIC, 1) AS avg_f,
    ROUND(AVG(m_score)::NUMERIC, 1) AS avg_m
FROM rfm_segments
GROUP BY segment
ORDER BY avg_spend DESC;

