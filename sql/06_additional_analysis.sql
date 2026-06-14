create view v_recency_by_segment AS
select 	
	segment, 
	round(avg(recency_days)::numeric, 0) as avg_recency_days,
	min(recency_days) as min_days,
	max(recency_days) as max_days,
	count(*) as customers
from rfm_segments
group by segment
order by avg_recency_days ASC;

create view v_segment_contribution as 
select
	segment,
	round(count(*) * 100.0/ sum(count(*)) over(), 1) as pct_customers,
	round(sum(monetary) * 100.0 / sum(sum(monetary)) over(), 1) as pct_revenue
from rfm_segments
group by segment;