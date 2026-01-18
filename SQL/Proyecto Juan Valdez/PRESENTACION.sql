
-- ==========================================================
-- BASES DE DATOS
-- ANA MARÍA BARRERO & SOPHIA UPEGUI
-- Universidad EIA - 2025-2
-- ==========================================================


-- Pregunta de negocio: ¿Cuál es el gasto promedio de los clientes en sus pedidos?

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

--------------------------------------------------------------

-- Pregunta de negocio: ¿Qué empleados no han atendido pedidos?

SELECT e.id_empleado, e.nombre
FROM empleados AS e
EXCEPT
SELECT DISTINCT e2.id_empleado, e2.nombre
FROM empleados AS e2 INNER JOIN empleado_pedido_new AS ep ON ep.id_empleado = e2.id_empleado
;

-- Pregunta de negocio: cuantos pedidos ha atendido cada empleado?
SELECT e.id_empleado, e.nombre, COUNT(ep.orden_id) AS CantidadPedidosAtendidos
FROM empleados AS e INNER JOIN empleado_pedido_new AS ep ON ep.id_empleado = e.id_empleado
GROUP BY e.id_empleado, e.nombre
ORDER BY CantidadPedidosAtendidos DESC
;

--------------------------------------------------------------

-- Pregunta de negocio: ¿Qué productos no han tenido pedidos en el mes actual?

SELECT pr.producto_id, pr.tipo_producto
FROM producto AS pr
WHERE pr.producto_id NOT IN (
  SELECT DISTINCT pp.producto_id
  FROM pedido_producto_sd AS pp INNER JOIN pedido_new AS p ON p.orden_id = pp.orden_id
  WHERE MONTH(p.fecha) = MONTH(GETDATE())
    AND YEAR(p.fecha)  = YEAR(GETDATE())
);

--------------------------------------------------------------

-- Pregunta de negocio: ¿Cuáles son los productos más vendidos (los que superen el promedio general)?

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

----------------------------------------------------------------

-- Pregunta de negocio: Clasificar clientes según nivel de compras

SELECT c.CC, c.nombre,
	SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) AS total_compras,
	CASE 
		WHEN SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) < 180 THEN 'Bajo'
		WHEN SUM(pr.precio * pp.cantidad * ((100 - ISNULL(pp.descuento, 0)) / 100.0)) BETWEEN 180 AND 220 THEN 'Medio'
        ELSE 'Alto'
	END AS nivel_cliente
FROM cliente AS c
	INNER JOIN pedido_new AS p ON p.CC = c.CC
	INNER JOIN pedido_producto_sd AS pp ON pp.orden_id = p.orden_id
	INNER JOIN producto AS pr ON pr.producto_id = pp.producto_id
GROUP BY c.CC, c.nombre
ORDER BY total_compras DESC
;

----------------------------------------------------------------

-- Pregunta de negocio: Un proveedor cambio de telefono

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


---------------------------------------------------------------

-- Ejemplo de funcion:
CREATE OR ALTER FUNCTION dbo.fn_proveedor_telefono(@proveedor_id INT = NULL, @nombre NVARCHAR(50) = NULL)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @tel NVARCHAR(50);
    SELECT @tel = telefono
    FROM proveedor
    WHERE (@proveedor_id IS NOT NULL AND proveedor_id = @proveedor_id)
       OR (@nombre IS NOT NULL AND nombre = @nombre);

    RETURN ISNULL(@tel, 'N/A');
END

-- Buscar por ID:
SELECT dbo.fn_proveedor_telefono(800002, NULL) AS Telefono;

-- Buscar por nombre:
SELECT dbo.fn_proveedor_telefono(NULL, 'Dulce Sirope Ltda.') AS Telefono;

-- Si no existe devuelve 'N/A':
SELECT dbo.fn_proveedor_telefono(999999, NULL) AS Telefono;



-- ========================================================== -- 
-- Comparacion con MONGODB
-- ========================================================== -- 

-- Empleados por cargo en una tienda específica:
SELECT e.cargo, t.tienda_id, COUNT(e.id_empleado) AS cantidad_empleados
FROM empleados AS e INNER JOIN tienda AS t ON e.tienda_id=t.tienda_id
GROUP BY e.cargo, t.tienda_id
;


-- Cantidad de empleados por cargo (a través de todas las tiendas)
SELECT e.cargo, COUNT(e.id_empleado) AS cantidad_empleados
FROM empleados AS e 
GROUP BY e.cargo
;

-- Tiendas en ciudades objetivo
SELECT t.tienda_id, t.tipo_tienda, t.ciudad
FROM tienda AS t
WHERE t.ciudad IN ('Medellin', 'Itagui', 'Envigado')   -- <-- cambia tu lista objetivo
ORDER BY t.ciudad, t.tienda_id
;

-- Cantidad de tiendas por tipo (física vs virtual) en filas
SELECT t.tipo_tienda, COUNT(t.tienda_id) AS cantidad
FROM tienda AS t
GROUP BY t.tipo_tienda
ORDER BY cantidad DESC, t.tipo_tienda
;


-- Top 5 tiendas con más empleados (incluye datos de la tienda)
SELECT TOP (5) WITH TIES 
	t.tienda_id, t.tipo_tienda, t.ciudad, COUNT(e.id_empleado) AS empleados
FROM tienda AS t LEFT OUTER JOIN empleados AS e ON e.tienda_id = t.tienda_id
GROUP BY t.tienda_id, t.tipo_tienda, t.ciudad
ORDER BY empleados DESC
;


-- Pedidos por tipo de entrega (domicilio vs. tienda) en filas
SELECT 
  CASE 
    WHEN p.domicilio = 'X' THEN 'Domicilio'
    ELSE 'En tienda'
  END AS tipo_entrega,
  COUNT(*) AS cantidad_pedidos
FROM pedido_new AS p
GROUP BY 
  CASE 
    WHEN p.domicilio = 'X'        THEN 'Domicilio'
    ELSE 'En tienda'
  END
ORDER BY cantidad_pedidos DESC
;


