-- ==========================================================
-- SEGUIMIENTO 3 - BASES DE DATOS
-- Autoras: ANA MARÍA BARRERO & SOPHIA UPEGUI
-- Universidad EIA - 2025-2
-- ==========================================================

-----------------------------------------------------------------
-- 1. Operaciones matemáticas: COUNT, AVG, MIN, MAX, SUM
-----------------------------------------------------------------
-- Pregunta de negocio: ¿Cuál es el gasto promedio de los clientes en sus pedidos?
-- Estructura:
--   SELECT: columnas que queremos mostrar
--   AVG(): función agregada que calcula el promedio
--   JOIN: unir cliente, pedido y producto
--   GROUP BY: agrupar por cliente

WITH TotalPorOrden AS (
    SELECT p.CC, c.nombre, p.orden_id,
        SUM(pr.precio * pp.cantidad * ((100 - pp.descuento) / 100.0)) AS Total_orden
    FROM cliente AS c
		INNER JOIN pedido_new AS p ON c.CC = p.CC
		INNER JOIN pedido_producto_sd AS pp ON p.orden_id = pp.orden_id
		INNER JOIN producto AS pr ON pr.producto_id = pp.producto_id
    GROUP BY p.CC, c.nombre, p.orden_id
)
SELECT CC, nombre,
	AVG(Total_orden) AS Gasto_promedio_por_orden
FROM TotalPorOrden
GROUP BY CC, nombre
ORDER BY Gasto_promedio_por_orden DESC
;


-----------------------------------------------------------------
-- 2. Condición con HAVING
-----------------------------------------------------------------
-- Pregunta de negocio: ¿Qué clientes han hecho más de 5 pedidos en total?
-- Estructura:
--   COUNT(): contar pedidos
--   GROUP BY: agrupar por cliente
--   HAVING: filtrar grupos (diferente de WHERE, que filtra filas)

SELECT c.CC, c.nombre, 
	COUNT(p.orden_id) AS total_pedidos
FROM cliente AS c INNER JOIN pedido_new AS p ON p.CC = c.CC
GROUP BY c.CC, c.nombre
HAVING COUNT(p.orden_id) > 5
ORDER BY total_pedidos DESC
;


-----------------------------------------------------------------
-- 3. GROUP BY y ORDER BY
-----------------------------------------------------------------
-- Pregunta de negocio: ¿Cuáles son las tiendas que más empleados tienen?
-- Estructura:
--   INNER JOIN: unir tiendas con empleados
--   COUNT(): contar empleados
--   GROUP BY: agrupar por tienda
--   ORDER BY: ordenar de mayor a menor

SELECT t.tienda_id, COUNT(e.id_empleado) AS empleados_totales
FROM tienda AS t INNER JOIN empleados AS e ON e.tienda_id = t.tienda_id
GROUP BY t.tienda_id
ORDER BY empleados_totales DESC
;


-----------------------------------------------------------------
-- 4. JOINs: LEFT JOIN & OUTER JOIN
-----------------------------------------------------------------
-- (a) Pregunta de negocio: Mostrar todas las tiendas y sus proveedores, incluso las que no tengan proveedores (LEFT JOIN).
-- Estructura:
--   LEFT JOIN: devuelve todas las filas de la izquierda aunque no haya coincidencia
--   ORDER BY: ordenar por tienda

SELECT t.tienda_id AS tienda, p.nombre AS proveedor
FROM tienda AS t
	LEFT JOIN tienda_proveedor AS tp ON tp.tienda_id = t.tienda_id
	LEFT JOIN proveedor AS p ON p.proveedor_id = tp.proveedor_id
ORDER BY t.tienda_id
;

-- (b) Pregunta de negocio: Mostrar todas las tiendas y todos los proveedores, incluso si no tienen relación entre sí (FULL OUTER JOIN).
SELECT t.tienda_id, t.tipo_tienda, p.proveedor_id, p.nombre AS proveedor
FROM juanValdez.dbo.tienda AS t 
	FULL OUTER JOIN juanValdez.dbo.tienda_proveedor AS tp ON t.tienda_id = tp.tienda_id
	FULL OUTER JOIN juanValdez.dbo.proveedor AS p ON p.proveedor_id = tp.proveedor_id
ORDER BY t.tienda_id, p.proveedor_id
;

-----------------------------------------------------------------
-- 5. Subconsultas: EXCEPT, NOT IN, UNION
-----------------------------------------------------------------
-- (a) Pregunta: ¿Qué empleados no han atendido pedidos?
-- Estructura:
--   EXCEPT: devuelve elementos en la primera consulta que no están en la segunda

SELECT e.id_empleado, e.nombre
FROM empleados AS e
EXCEPT
SELECT DISTINCT e2.id_empleado, e2.nombre
FROM empleados AS e2 INNER JOIN empleado_pedido_new AS ep ON ep.id_empleado = e2.id_empleado
;


-- (b) Pregunta: Listar clientes y empleados en un solo listado (UNION).
-- Estructura:
--   UNION: une dos consultas con el mismo número de columnas

SELECT c.nombre, c.CC AS ID
FROM cliente AS c
UNION
SELECT e.nombre, e.id_empleado AS ID
FROM empleados AS e
;


-- (c) Pregunta: ¿Qué productos no han tenido pedidos en el mes actual?
-- Estructura:
--   NOT IN: excluir productos que aparecen en subconsulta

SELECT pr.producto_id, pr.tipo_producto
FROM producto AS pr
WHERE pr.producto_id NOT IN (
  SELECT DISTINCT pp.producto_id
  FROM pedido_producto_sd AS pp INNER JOIN pedido_new AS p ON p.orden_id = pp.orden_id
  WHERE MONTH(p.fecha) = MONTH(GETDATE())
    AND YEAR(p.fecha)  = YEAR(GETDATE())
);


-----------------------------------------------------------------
-- 6. CTE (WITH - Common Table Expression)
-----------------------------------------------------------------
-- Pregunta de negocio: ¿Cuáles son los productos más vendidos, mostrando solo los que superen el promedio general?
-- Estructura:
--   WITH: crear una tabla temporal (CTE) con ventas_totales
--   SELECT: consultar la CTE
--   WHERE: comparar con el promedio calculado sobre la CTE

WITH ventas_totales AS (
  SELECT pp.producto_id, 
	SUM(pp.cantidad) AS total_vendido
  FROM pedido_producto_sd AS pp
  GROUP BY pp.producto_id
)
SELECT v.producto_id, pr.tipo_producto, v.total_vendido
FROM ventas_totales AS v INNER JOIN producto AS pr ON pr.producto_id = v.producto_id
WHERE v.total_vendido > (
	SELECT AVG(total_vendido) 
	FROM ventas_totales
	)
ORDER BY v.total_vendido DESC
;


-----------------------------------------------------------------
-- 7. CASE
-----------------------------------------------------------------
-- Pregunta de negocio: Clasificar clientes según nivel de compras
-- Estructura:
--   SUM(): total de compras
--   CASE: clasificar en Bajo, Medio, Alto
--   GROUP BY: agrupar por cliente

SELECT c.CC, c.nombre,
	SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) AS total_compras,
	CASE 
		WHEN SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) < 100 THEN 'Bajo'
		WHEN SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) BETWEEN 100 AND 200 THEN 'Medio'
        ELSE 'Alto'
	END AS nivel_cliente
FROM cliente AS c
	INNER JOIN pedido_new AS p ON p.CC = c.CC
	INNER JOIN pedido_producto_sd AS pp ON pp.orden_id = p.orden_id
	INNER JOIN producto AS pr ON pr.producto_id = pp.producto_id
GROUP BY c.CC, c.nombre
;


-----------------------------------------------------------------
-- 8. UPDATE
-----------------------------------------------------------------
-- Pregunta de negocio: Un proveedor cambio de telefono
-- Estructura:
--   UPDATE: modifica filas
--   SET: nuevo valor de la columna
--   WHERE: condición de selección

SELECT *
FROM proveedor
WHERE proveedor_id = 800002 AND nombre = 'Dulce Sirope Ltda.'
;

UPDATE proveedor
SET telefono = '8011326'
WHERE proveedor_id = 800002 AND nombre = 'Dulce Sirope Ltda.'
;

SELECT *
FROM proveedor
WHERE proveedor_id = 800002 AND nombre = 'Dulce Sirope Ltda.'
;

-----------------------------------------------------------------
-- 9. DISTINCT
-----------------------------------------------------------------
-- Pregunta de negocio: ¿En cuántas ciudades distintas hay proveedores?
-- Estructura:
--   DISTINCT: elimina duplicados
--   COUNT(): contar elementos únicos

SELECT COUNT(DISTINCT ciudad) AS ciudades_con_proveedores
FROM proveedor
;


