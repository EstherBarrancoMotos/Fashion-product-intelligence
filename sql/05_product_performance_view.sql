-- ============================================================
-- Product Performance View
-- Dashboard-ready semantic layer
-- ============================================================

CREATE OR REPLACE VIEW product_performance AS

WITH product_metrics AS (

    SELECT
        articleID,

        SUM(ordered_units) AS ordered_units,
        SUM(returned_units) AS returned_units,
        SUM(kept_units) AS kept_units,

        SUM(ordered_sales_value) AS ordered_sales_value,
        SUM(returned_sales_value) AS returned_sales_value,
        SUM(kept_sales_value) AS kept_sales_value,

        SUM(returned_units) * 1.0
            / NULLIF(SUM(ordered_units), 0) AS unit_return_rate,

        SUM(kept_units) * 1.0
            / NULLIF(SUM(ordered_units), 0) AS unit_retention_rate,

        SUM(returned_sales_value)
            / NULLIF(SUM(ordered_sales_value), 0) AS value_return_rate,

        AVG(
            CASE
                WHEN price_status = 'below_rrp' THEN 1.0
                ELSE 0.0
            END
        ) AS markdown_share

    FROM fact_transactions

    WHERE is_zero_value_item = FALSE

    GROUP BY articleID
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

    FROM product_metrics
)

SELECT
    r.articleID,
    p.productGroup,
    p.rrp,

    r.ordered_units,
    r.returned_units,
    r.kept_units,

    r.ordered_sales_value,
    r.returned_sales_value,
    r.kept_sales_value,

    r.unit_return_rate,
    r.unit_retention_rate,
    r.value_return_rate,
    r.markdown_share,

    r.ordered_units_rank,
    r.kept_units_rank,

    r.kept_units_rank - r.ordered_units_rank AS rank_drop,

    CASE
        WHEN r.ordered_units_rank <= 100
         AND r.kept_units_rank > 100
        THEN TRUE
        ELSE FALSE
    END AS is_false_bestseller

FROM ranked_products r

LEFT JOIN dim_product p
    ON r.articleID = p.articleID;