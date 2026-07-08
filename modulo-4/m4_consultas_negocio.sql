-- ============================================================
-- RetailPro · Módulo 4 · Consultas de negocio
-- Base de datos: Ventas_Tech_DB
-- Tabla: ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- ============================================================


-- ============================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- ============================================================
SELECT
    EXTRACT(MONTH FROM fecha_venta)          AS mes,
    SUM(cantidad * precio_unitario)          AS total_facturado,
    COUNT(*)                                 AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)          AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- ============================================================
-- Consulta 2 — Ranking de productos (Top 5 por total facturado)
-- ============================================================
SELECT
    id_producto,
    SUM(cantidad)                            AS unidades_vendidas,
    SUM(cantidad * precio_unitario)          AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- ============================================================
-- Consulta 3 — Clientes recurrentes (más de un pedido)
-- ============================================================
SELECT
    id_cliente,
    COUNT(*)                                 AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)          AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ============================================================
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes + etiqueta CASE WHEN comparando
-- contra el promedio mensual general.
-- ============================================================
SELECT
    EXTRACT(MONTH FROM fecha_venta)          AS mes,
    SUM(cantidad * precio_unitario)          AS total_facturado,
    CASE
        WHEN SUM(cantidad * precio_unitario) >= (
            SELECT AVG(total_mes)
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes
                FROM ventas
                GROUP BY EXTRACT(MONTH FROM fecha_venta)
            ) AS totales_mensuales
        )
        THEN 'Por encima'
        ELSE 'Por debajo'
    END                                      AS comparacion_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- ============================================================
-- Hallazgos
-- ============================================================
-- 1. [Ej.] El producto 7 concentra el 38% de la facturación total,
--    muy por encima del resto del Top 5: conviene asegurar su stock.
-- 2. [Ej.] Solo el 22% de los clientes son recurrentes, pero aportan
--    más de la mitad del total gastado: hay margen para fidelizar.
-- 3. [Ej.] Los meses de marzo y julio quedaron por encima del promedio
--    mensual, señalando estacionalidad a reforzar con campañas.
-- ============================================================
