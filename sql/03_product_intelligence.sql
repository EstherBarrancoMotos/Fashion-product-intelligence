-- ============================================================
-- Product Intelligence
-- Gross demand vs retained demand
-- ============================================================

WITH product_performance AS (

    SELECT
        articleID,

        SUM(ordered_units) AS ordered_units,
        SUM(returned_units) AS returned_units,
        SUM(kept_units) AS kept_units,

        SUM(ordered_sales_value) AS ordered_sales_value,
        SUM(returned_sales_value) AS returned_sales_value,
        SUM(kept_sales_value) AS kept_sales_value

    FROM fact_transactions

    WHERE is_zero_value_item = FALSE

    GROUP BY articleID
),

volume_threshold AS (

    SELECT
        quantile_cont(ordered_units, 0.25) AS min_ordered_units
    FROM product_performance
),

product_analysis AS (

    SELECT
        p.*,

        returned_units * 1.0
            / NULLIF(ordered_units, 0) AS unit_return_rate,

        kept_units * 1.0
            / NULLIF(ordered_units, 0) AS unit_retention_rate

    FROM product_performance p
    CROSS JOIN volume_threshold v

    WHERE p.ordered_units >= v.min_ordered_units
),

product_ranking AS (

    SELECT
        *,

        RANK() OVER (
            ORDER BY ordered_units DESC
        ) AS ordered_units_rank,

        RANK() OVER (
            ORDER BY kept_units DESC
        ) AS kept_units_rank

    FROM product_analysis
),

rank_analysis AS (

    SELECT
        *,

        kept_units_rank - ordered_units_rank AS rank_drop,

        ABS(
            kept_units_rank - ordered_units_rank
        ) AS abs_rank_shift

    FROM product_ranking
)

SELECT *
FROM rank_analysis
ORDER BY rank_drop DESC;