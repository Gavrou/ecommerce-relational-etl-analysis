-- Consulta 1: ¿Cómo impacta la demora logística en la satisfacción del cliente?
-- Cruzar ORDERS + REVIEWS usando LEFT JOIN
q_logistica_reviews = """
SELECT
    CASE WHEN o.is_delayed = 1 THEN 'Con Retraso (Delayed)' ELSE 'A Tiempo (On-Time)' END AS estado_entrega,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ROUND(AVG(o.delivery_days), 1) AS promedio_dias_envio,
    ROUND(AVG(r.review_score), 2) AS calificacion_promedio_estrellas
FROM orders o
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND o.delivery_days IS NOT NULL
GROUP BY o.is_delayed;
"""

-- Consulta 2: Top 10 Categorías de Productos por Facturación Total y Volumen de Ventas
-- Cruzar ORDERS + ITEMS + PRODUCTS mediante doble INNER JOIN
q_top_categorias = """
SELECT
    p.product_category_name AS categoria,
    COUNT(DISTINCT i.order_id) AS cantidad_pedidos,
    COUNT(i.order_item_id) AS unidades_vendidas,
    ROUND(SUM(i.price), 2) AS ingresos_totales_brl,
    ROUND(AVG(i.freight_value), 2) AS costo_envio_promedio
FROM items i
INNER JOIN orders o ON i.order_id = o.order_id
INNER JOIN products p ON i.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY ingresos_totales_brl DESC
LIMIT 10;
"""

-- Consulta 3: Top 10 Estados con mayor facturación y su tasa de demoras
-- Cruzar ORDERS + ITEMS + CUSTOMERS
q_estados = """
SELECT
    c.customer_state AS estado,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ROUND(SUM(i.price), 2) AS ingresos_totales_brl,
    ROUND(100.0 * SUM(o.is_delayed) / COUNT(o.order_id), 2) AS tasa_retraso_pct
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
    ORDER BY ingresos_totales_brl DESC
    LIMIT 10;
"""

-- Consulta 4: Análisis de categorías críticas
-- Cruzar ITEMS + PRODUCTS + REVIEWS + ORDERS
q_peores_categorias = """
SELECT
    p.product_category_name AS categoria,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ROUND(AVG(r.review_score), 2) AS calificacion_promedio,
    ROUND(100.0 * SUM(o.is_delayed) / COUNT(DISTINCT o.order_id), 2) AS tasa_retraso_pct
FROM items i
INNER JOIN orders o ON i.order_id = o.order_id
INNER JOIN products p ON i.product_id = p.product_id
INNER JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
HAVING COUNT(DISTINCT o.order_id) >= 500
ORDER BY calificacion_promedio ASC
LIMIT 10;
"""