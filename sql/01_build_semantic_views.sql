-- ============================================================
-- Fashion Product Intelligence
-- Semantic Views
-- ============================================================

CREATE OR REPLACE VIEW fact_transactions AS
SELECT *
FROM read_parquet('data/processed/fact_transactions.parquet');

CREATE OR REPLACE VIEW fact_orders AS
SELECT *
FROM read_parquet('data/processed/fact_orders.parquet');

CREATE OR REPLACE VIEW dim_product AS
SELECT *
FROM read_parquet('data/processed/dim_product.parquet');

CREATE OR REPLACE VIEW dim_date AS
SELECT *
FROM read_parquet('data/processed/dim_date.parquet');