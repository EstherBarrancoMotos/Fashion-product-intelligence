-- ============================================================
-- False Bestsellers
-- Top 100 by ordered units that leave the Top 100 by kept units
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

        returned_sales_value
            / NULLIF(ordered_sales_value, 0) AS value_return_rate

    FROM product_performance p
    CROSS JOIN volume_threshold v

    WHERE p.ordered_units >= v.min_ordered_units
),

ranked_products AS (

    SELECT
        *,

        RANK() OVER (
            ORDER BY ordered_units DESC
        ) AS ordered_units_rank,

        RANK() OVER (
            ORDER BY kept_units DESC
        ) AS kept_units_rank

    FROM product_analysis
)

SELECT
    articleID,
    ordered_units,
    returned_units,
    kept_units,
    unit_return_rate,
    value_return_rate,
    ordered_units_rank,
    kept_units_rank,
    kept_units_rank - ordered_units_rank AS rank_drop

FROM ranked_products

WHERE ordered_units_rank <= 100
  AND kept_units_rank > 100

ORDER BY ordered_units_rank;