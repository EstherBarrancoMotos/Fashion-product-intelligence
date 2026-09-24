from pathlib import Path
import os
import duckdb


# ============================================================
# Project paths
# ============================================================

ROOT = Path(__file__).resolve().parents[1]
os.chdir(ROOT)

SQL_PATH = ROOT / "sql"

conn = duckdb.connect()


# ============================================================
# Build semantic views
# ============================================================

with open(
    SQL_PATH / "01_build_semantic_views.sql",
    "r",
    encoding="utf-8"
) as file:
    conn.execute(file.read())


# ============================================================
# Product Intelligence
# Top rank drops
# ============================================================

product_intelligence_sql = (
    SQL_PATH / "03_product_intelligence.sql"
).read_text(encoding="utf-8").strip()

if not product_intelligence_sql:
    raise ValueError(
        "03_product_intelligence.sql is empty."
    )

conn.execute(product_intelligence_sql)

columns = [
    column[0]
    for column in conn.description
]

rows = conn.fetchmany(10)

print("\nTOP 10 RANK DROPS\n")

print(" | ".join(columns))
print("-" * 160)

for row in rows:
    print(
        " | ".join(
            str(value)
            for value in row
        )
    )


# ============================================================
# False Bestsellers
# ============================================================

false_bestsellers_sql = (
    SQL_PATH / "04_false_bestsellers.sql"
).read_text(encoding="utf-8").strip()

if not false_bestsellers_sql:
    raise ValueError(
        "04_false_bestsellers.sql is empty."
    )

conn.execute(false_bestsellers_sql)

false_bestsellers = conn.fetchall()

print("\nFALSE BESTSELLERS")
print(
    f"Products leaving Top 100: "
    f"{len(false_bestsellers)}\n"
)

print(
    "articleID | ordered | returned | kept | "
    "unit_return_rate | value_return_rate | "
    "ordered_rank | kept_rank | rank_drop"
)

print("-" * 140)

for row in false_bestsellers:
    print(
        f"{row[0]} | "
        f"{row[1]} | "
        f"{row[2]} | "
        f"{row[3]} | "
        f"{row[4]:.2%} | "
        f"{row[5]:.2%} | "
        f"{row[6]} | "
        f"{row[7]} | "
        f"{row[8]}"
    )


# ============================================================
# False Bestseller Validation
# ============================================================

assert len(false_bestsellers) == 19, (
    f"Expected 19 false bestsellers, "
    f"got {len(false_bestsellers)}"
)

print(
    "\nFalse bestseller validation passed."
)


# ============================================================
# Product Performance View
# ============================================================

product_view_sql = (
    SQL_PATH / "05_product_performance_view.sql"
).read_text(encoding="utf-8").strip()

if not product_view_sql:
    raise ValueError(
        "05_product_performance_view.sql is empty."
    )

conn.execute(product_view_sql)


# ============================================================
# Product Performance View Validation
# ============================================================

product_count, false_bestseller_count = conn.execute("""
    SELECT
        COUNT(*) AS product_count,
        SUM(
            CASE
                WHEN is_false_bestseller = TRUE THEN 1
                ELSE 0
            END
        ) AS false_bestseller_count
    FROM product_performance
""").fetchone()

print("\nPRODUCT PERFORMANCE VIEW VALIDATION")
print(f"Products: {product_count}")
print(
    f"False bestsellers: "
    f"{false_bestseller_count}"
)


assert product_count == 3807, (
    f"Expected 3807 products, "
    f"got {product_count}"
)

assert false_bestseller_count == 19, (
    f"Expected 19 false bestsellers, "
    f"got {false_bestseller_count}"
)

print(
    "\nProduct performance view validation passed."
)


# ============================================================
# Close connection
# ============================================================

conn.close()