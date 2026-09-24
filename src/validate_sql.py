from pathlib import Path
import os
import duckdb


# Project root
ROOT = Path(__file__).resolve().parents[1]

# Resolve relative paths from project root
os.chdir(ROOT)

SQL_PATH = ROOT / "sql"

conn = duckdb.connect()


# ------------------------------------------------------------
# Build semantic views
# ------------------------------------------------------------

with open(
    SQL_PATH / "01_build_semantic_views.sql",
    "r",
    encoding="utf-8"
) as file:
    conn.execute(file.read())


# ------------------------------------------------------------
# Execute and validate core KPIs
# ------------------------------------------------------------

with open(
    SQL_PATH / "02_core_kpis.sql",
    "r",
    encoding="utf-8"
) as file:
    result = conn.execute(file.read())

columns = [column[0] for column in result.description]
values = result.fetchone()

core_kpis = dict(zip(columns, values))

print("\nCORE KPIs")

for metric, value in core_kpis.items():
    print(f"{metric}: {value}")


expected_units = {
    "ordered_units": 2314801,
    "returned_units": 1212349,
    "kept_units": 1102452
}

for metric, expected_value in expected_units.items():
    actual_value = int(core_kpis[metric])

    assert actual_value == expected_value, (
        f"{metric}: expected {expected_value}, "
        f"got {actual_value}"
    )

print("\nSQL validation passed: unit totals match Python.")


# ------------------------------------------------------------
# Validate order-level grain
# ------------------------------------------------------------

rows, distinct_orders = conn.execute("""
    SELECT
        COUNT(*) AS rows,
        COUNT(DISTINCT orderID) AS distinct_orders
    FROM fact_orders
""").fetchone()

print("\nORDER VALIDATION")
print(f"rows: {rows}")
print(f"distinct_orders: {distinct_orders}")

assert rows == distinct_orders

print("\nOrder grain validation passed.")

conn.close()