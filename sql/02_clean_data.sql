Select * from raw_transactions;

-- Total row count
SELECT COUNT(*) FROM raw_transactions;

-- How many distinct customers?
SELECT COUNT(DISTINCT customer_id) as total_customers
FROM raw_transactions
WHERE customer_id IS NOT NULL AND customer_id !=0;

-- How many rows have null customer_id?
SELECT 
	COUNT(*) AS null_customer_rows,
	ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM raw_transactions), 2) AS pct
FROM raw_transactions
WHERE customer_id IS NULL;

-- How many cancellations? (invoice_no starts with C)
SELECT COUNT(*) AS cancellations
FROM raw_transactions
WHERE invoice_no LIKE 'C%';

-- How many rows with negative or zero quantity?
SELECT COUNT(*) AS bad_quantity
FROM raw_transactions
WHERE quantity <= 0;

-- How many rows with zero or negative unit_price?
SELECT COUNT(*) AS bad_price
FROM raw_transactions
WHERE unit_price <= 0;

-- Date range of the dataset
SELECT 
	MIN(invoice_date) as earliest,
	MAX(invoice_date) as latest
FROM raw_transactions;

/* 
	Create cleaned table excluding all bad data
*/
CREATE TABLE clean_transactions AS 
SELECT 
	invoice_no,
	stock_code,
	description,
	quantity,
	TO_DATE(invoice_date, 'MM/DD/YYYY') as invoice_date,
	unit_price,
	customer_id,
	country,

	-- calculate line total - derived column
	ROUND(quantity * unit_price, 2) AS line_total
FROM raw_transactions
WHERE
	customer_id IS NOT NULL
	AND customer_id != 0
	AND quantity > 0
	AND unit_price > 0
	AND invoice_no NOT LIKE 'C%'


-- verify clean table
SELECT COUNT(*) AS clean_rows FROM clean_transactions;

SELECT COUNT(DISTINCT customer_id) AS customers FROM clean_transactions;

-- Data cleaning log 
SELECT 
	(SELECT COUNT(*) FROM raw_transactions) AS raw_rows,
	(SELECT COUNT(*) FROM clean_transactions) AS clean_rows,
	(SELECT COUNT(*) FROM raw_tran)


