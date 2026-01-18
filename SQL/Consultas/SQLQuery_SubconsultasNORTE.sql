--1. Listar todos los clientes con su país
SELECT DISTINCT Clientes.ContactoNombre, Clientes.Pais
FROM Clientes
;

--2.Listar productos con su proveedor
SELECT Productos.Nombre, Proveedores.Compania
FROM Productos INNER JOIN Proveedores ON Productos.IdProveedor=Proveedores.IdProveedor

--3. Ordenes con cliente y empleado asociado
SELECT Pedidos.IdPedido, Clientes.Compania, Empleados.Apellidos
FROM Pedidos, Clientes, Empleados
WHERE Pedidos.IdCliente = Clientes.IdCliente AND Pedidos.IdEmpleado=Empleados.IdEmpleado
;
--con inner join
SELECT Pedidos.IdPedido, Clientes.Compania, Empleados.Apellidos
FROM Pedidos INNER JOIN Clientes ON Pedidos.IdCliente = Clientes.IdCliente
	INNER JOIN Empleados ON Pedidos.IdEmpleado=Empleados.IdEmpleado
;

--4. Número de productos por categoría
SELECT Categorias.Nombre, COUNT(Categorias.Nombre) AS Cantidad
FROM Categorias INNER JOIN Productos ON  Categorias.IdCategoria=Productos.IdCategoria
GROUP BY Categorias.Nombre
ORDER BY Cantidad DESC

--5. Top 5 clientes con más pedidos
SELECT TOP 5 Clientes.Compania, COUNT(Pedidos.IdPedido) AS Cantidad
FROM Clientes INNER JOIN Pedidos ON Clientes.IdCliente=Pedidos.IdCliente
GROUP BY Clientes.Compania
ORDER BY Cantidad DESC
;

--6. Ingresos por pedido (considerando descuentos)
SELECT Pedidos.IdPedido, 
	ROUND(SUM(Pedidos_Detalles.PrecioUnd * (1-Pedidos_Detalles.Descuento) * 
		Pedidos_Detalles.Cantidad),2) AS Total
FROM Pedidos INNER JOIN Pedidos_Detalles ON Pedidos.IdPedido=Pedidos_Detalles.IdPedido
GROUP BY Pedidos.IdPedido
ORDER BY Total DESC
;

--7. Ingresos totales por cliente
SELECT Clientes.Compania, 
		ROUND(SUM(Pedidos_Detalles.PrecioUnd * (1-Pedidos_Detalles.Descuento) * 
		Pedidos_Detalles.Cantidad),2) AS Total
FROM Clientes INNER JOIN Pedidos ON Clientes.IdCliente=Pedidos.IdCliente
	INNER JOIN Pedidos_Detalles ON Pedidos.IdPedido=Pedidos_Detalles.IdPedido
GROUP BY Clientes.Compania
ORDER BY Total DESC
;

--8. Clientes que nunca han hecho pedidos
SELECT Clientes.Compania, Pedidos.IdPedido
FROM Clientes LEFT JOIN Pedidos ON Clientes.IdCliente=Pedidos.IdCliente
WHERE Pedidos.IdPedido IS NULL
;

-- alternativa con subconsulta
SELECT Clientes.Compania
FROM Clientes 
WHERE Clientes.IdCliente NOT IN
	(
	SELECT Pedidos.IdCliente
	FROM Pedidos
	)
;


--9. Pedidos que tardaron más de 30 días en despacharse
SELECT Pedidos.IdPedido, Pedidos.FPedido, Pedidos.FDespacho,
	DATEDIFF(DAY, Pedidos.FPedido, Pedidos.FDespacho) AS Dias
FROM Pedidos
WHERE DATEDIFF(DAY, Pedidos.FPedido, Pedidos.FDespacho) > 30
	AND Pedidos.FDespacho IS NOT NULL
ORDER BY Dias DESC
;


--10. Promedio del valor de los pedidos por año
SELECT YEAR(FPedido) AS Año,
		AVG(TotalPedido) AS PromedioPedido
FROM (
	SELECT p.IdPedido, p.FPedido,
		SUM(pd.PrecioUnd * (1-pd.Descuento) * 
		pd.Cantidad) AS TotalPedido
	FROM Pedidos AS p INNER JOIN Pedidos_Detalles AS pd ON p.IdPedido=pd.idPedido
	GROUP BY p.IdPedido, p.FPedido
	) AS S
GROUP BY YEAR(FPedido)
ORDER BY Año
;

--11. Ranking de clientes por ventas ($)
WITH Ventas AS 
	(
	SELECT c.IdCliente, c.Compania,
		SUM(pd.PrecioUnd * (1-pd.Descuento) * pd.Cantidad) AS TotalVenta
	FROM Pedidos AS p INNER JOIN Pedidos_Detalles AS pd ON p.IdPedido=pd.idPedido
		INNER JOIN Clientes AS c ON p.IdCliente=c.IdCliente
	GROUP BY c.IdCliente, c.Compania
	)
SELECT *, RANK() OVER (ORDER BY TotalVenta DESC) AS Ranking
FROM Ventas
;

----------------------------------------------

--12. Top 3 productos por ventas dentro de cada categoría
--RANKED

WITH ProdVentas AS (
	SELECT c.Nombre AS Categoria, p.IdProducto, p.Nombre,
		SUM(pd.PrecioUnd * (1-pd.Descuento) * pd.Cantidad) AS Ventas
	FROM Productos AS p
		INNER JOIN Categorias AS c ON p.IdCategoria = c.IdCategoria
		INNER JOIN Pedidos_Detalles AS pd ON p.IdProducto = pd.IdProducto
	GROUP BY  c.Nombre, p.IdProducto, p.Nombre
	),
Ranked AS (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY Categoria ORDER BY Ventas DESC) AS rn
	FROM ProdVentas
	)
SELECT Categoria, IdProducto, Nombre, Ventas
FROM Ranked 
WHERE rn <= 3
;


-----------------------------------

-- 13. Clientes con ventas por encima del promedio de su país

WITH VentasClientes AS (
	SELECT c.IdCliente, c.Compania, c.Pais,
		SUM(pd.PrecioUnd * (1-pd.Descuento) * pd.Cantidad) AS Ventas
	FROM Clientes AS c 
		INNER JOIN Pedidos AS pe ON c.IdCliente = pe.IdCliente
		INNER JOIN Pedidos_Detalles AS pd ON pe.IdPedido = pd.IdPedido
	GROUP BY c.IdCliente, c.Compania, c.Pais
	)
	SELECT v.* 
	FROM VentasClientes AS v
	WHERE v.Ventas > (
		SELECT AVG(v2.Ventas)
		FROM VentasClientes AS v2
		WHERE v2.Pais = v.Pais
		)
	;

-------------------------------

-- 14.

SELECT pe.IdPedido,
	COUNT (DISTINCT pd.IdProducto) AS ProductosDistintos
FROM Pedidos AS pe 
	INNER JOIN Pedidos_Detalles AS pd ON pe.IdPedido = pd.IdPedido
	INNER JOIN Productos AS p ON pd.IdProducto = p.IdProducto
GROUP BY pe.IdPedido
HAVING COUNT (DISTINCT pd.IdProducto) > 5
;


