-- Create the raw transaction table
CREATE TABLE IF NOT EXISTS raw_transactions (
	invoice_no VARCHAR(50),
	stock_code VARCHAR(50),
	description VARCHAR(200),
	quantity INT,
	invoice_date VARCHAR(100),
	unit_price NUMERIC(5,2),
	customer_id VARCHAR(50),
	country VARCHAR(50)
);