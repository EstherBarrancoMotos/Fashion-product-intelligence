-- ============================================================
-- Core KPI Definitions
-- Source of truth: docs/metric_dictionary.md
-- ============================================================

SELECT
    SUM(ordered_units) AS ordered_units,
    SUM(returned_units) AS returned_units,
    SUM(kept_units) AS kept_units,

    SUM(returned_units) * 1.0
        / NULLIF(SUM(ordered_units), 0) AS unit_return_rate,

    SUM(kept_units) * 1.0
        / NULLIF(SUM(ordered_units), 0) AS unit_retention_rate,

    SUM(ordered_sales_value) AS ordered_sales_value,
    SUM(returned_sales_value) AS returned_sales_value,
    SUM(kept_sales_value) AS kept_sales_value,

    SUM(returned_sales_value)
        / NULLIF(SUM(ordered_sales_value), 0) AS value_return_rate,

    SUM(kept_sales_value)
        / NULLIF(SUM(ordered_sales_value), 0) AS value_retention_rate

FROM fact_transactions;