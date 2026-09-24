# Metric Dictionary

Este documento define las métricas oficiales utilizadas en el proyecto `fashion-product-intelligence`.

El objetivo es mantener una única definición de cada KPI, independientemente de la herramienta utilizada posteriormente para su análisis o visualización.

## Principios de modelado

Las métricas se calculan respetando la granularidad de cada tabla:

- `fact_transactions`: análisis de producto, variantes, pricing y devoluciones.
- `fact_orders`: análisis de pedidos, clientes y vouchers.
- `dim_product`: atributos descriptivos del producto.
- `dim_date`: atributos temporales.

Los importes de venta representan valor transaccional asociado a las unidades y no deben interpretarse como margen, beneficio o revenue contable neto.

## Core KPIs

### Product & Return KPIs

| KPI | Definición | Fórmula | Fuente |
| --- | --- | --- | --- |
| Ordered Units | Unidades inicialmente pedidas | `SUM(ordered_units)` | `fact_transactions` |
| Returned Units | Unidades devueltas | `SUM(returned_units)` | `fact_transactions` |
| Kept Units | Unidades retenidas por el cliente | `SUM(kept_units)` | `fact_transactions` |
| Unit Return Rate | Porcentaje de unidades pedidas que fueron devueltas | `SUM(returned_units) / SUM(ordered_units)` | `fact_transactions` |
| Unit Retention Rate | Porcentaje de unidades pedidas que fueron retenidas | `SUM(kept_units) / SUM(ordered_units)` | `fact_transactions` |
| Ordered Sales Value | Valor asociado a las unidades pedidas | `SUM(ordered_sales_value)` | `fact_transactions` |
| Returned Sales Value | Valor asociado a las unidades devueltas | `SUM(returned_sales_value)` | `fact_transactions` |
| Kept Sales Value | Valor asociado a las unidades retenidas | `SUM(kept_sales_value)` | `fact_transactions` |
| Value Return Rate | Porcentaje del valor pedido asociado a devoluciones | `SUM(returned_sales_value) / SUM(ordered_sales_value)` | `fact_transactions` |
| Value Retention Rate | Porcentaje del valor pedido asociado a unidades retenidas | `SUM(kept_sales_value) / SUM(ordered_sales_value)` | `fact_transactions` |

### Order & Customer KPIs

| KPI | Definición | Fórmula | Fuente |
| --- | --- | --- | --- |
| Orders | Número total de pedidos | `COUNT(orderID)` | `fact_orders` |
| Customers | Número de clientes únicos | `DISTINCTCOUNT(customerID)` | `fact_orders` |
| Average Order Value | Valor medio inicial por pedido | `SUM(ordered_sales_value) / COUNT(orderID)` | `fact_orders` |
| Average Kept Order Value | Valor medio retenido por pedido | `SUM(kept_sales_value) / COUNT(orderID)` | `fact_orders` |
| Voucher Orders | Número de pedidos con voucher aplicado | `COUNT(orderID WHERE has_voucher = TRUE)` | `fact_orders` |
| Voucher Amount | Importe total de vouchers aplicados | `SUM(voucherAmount)` | `fact_orders` |

## Pricing KPIs

### Markdown Share

Proporción de líneas comerciales cuyo `price_status` es `below_rrp`.

Esta métrica representa exposición a markdown a nivel de línea y no debe interpretarse como porcentaje de unidades salvo que se defina explícitamente de esa forma.

### Average Markdown %

Profundidad media del descuento entre las líneas clasificadas como `below_rrp`.

Los productos con RRP desconocido o valor cero quedan fuera de esta métrica.

## Product Performance

El rendimiento de producto debe analizarse combinando demanda bruta y demanda retenida.

- `ordered_units` representa la demanda inicial.
- `returned_units` representa las unidades devueltas.
- `kept_units` representa las unidades que permanecen en manos del cliente.

Esta distinción permite identificar productos con elevada demanda inicial cuyo rendimiento se deteriora después de incorporar las devoluciones.

## Reglas de gobernanza

### Return Rates

`Unit Return Rate` debe calcularse siempre como:

`SUM(returned_units) / SUM(ordered_units)`

No debe calcularse como la media de tasas de devolución individuales.

Del mismo modo, `Value Return Rate` debe calcularse como:

`SUM(returned_sales_value) / SUM(ordered_sales_value)`

### Voucher Amount

`voucherAmount` solo debe agregarse desde `fact_orders`.

El voucher pertenece al pedido y puede aparecer repetido en las líneas transaccionales originales. Sumarlo desde una tabla a nivel de producto provocaría duplicidades.

### Kept Sales Value

`kept_sales_value` representa el valor asociado a las unidades que no fueron devueltas.

No equivale a beneficio, margen ni revenue contable neto, ya que el dataset no contiene información suficiente sobre costes, impuestos o asignación de vouchers a nivel de producto.

## Objetivo de la capa semántica

Este diccionario actúa como fuente única de definición para los KPIs del proyecto.
