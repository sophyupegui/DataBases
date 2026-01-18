
--1. Listar todos los productos con nombre, precio y categoría
SELECT p.Name, p.ListPrice, p.ProductCategoryID, pc.Name
FROM SalesLT.Product AS p INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
;


--2. Clientes con su dirección completa en "Main Office" (ciudad, estado, país)
SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer AS c INNER JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
WHERE ca.AddressType = 'Main Office';


-- 3. Total de ventas agrupado y ordenado por año

SELECT *
FROM SalesLT.SalesOrderDetail;
--LineTotal = total de venta

SELECT YEAR(s.ModifiedDate) AS Fecha, SUM(s.LineTotal) AS TotalAnual
FROM SalesLT.SalesOrderDetail AS s
GROUP BY YEAR(s.ModifiedDate)
ORDER BY YEAR(s.ModifiedDate) DESC;


--4. Top 10 productos más vendidos por cantidad

SELECT TOP (10)
	p.ProductID, p.Name, p.ProductNumber, p.Color, SUM(sd.OrderQty) AS CantidadTotal
FROM SalesLT.Product AS p INNER JOIN SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
GROUP BY  p.ProductID, p.Name, p.ProductNumber, p.Color
ORDER BY CantidadTotal DESC;


--5. Clientes que han gastado más de $1,000 en total

SELECT c.CustomerID, c.FirstName, c.LastName, SUM(sd.LineTotal) AS TotalPedido
FROM SalesLT.Customer AS c 
	INNER JOIN SalesLT.SalesOrderHeader AS sh ON c.CustomerID = sh.CustomerID
	INNER JOIN SalesLT.SalesOrderDetail AS sd ON sh.SalesOrderID = sd.SalesOrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING SUM(sd.LineTotal) > 1000
ORDER BY TotalPedido DESC;


--6. Productos sin categoría asignada

SELECT p.ProductID, p.Name, p.ProductNumber, p.ProductCategoryID
FROM SalesLT.Product AS p
WHERE p.ProductCategoryID IS NULL;


-- 7. Ventas por categoría de producto, ordenado por Ventas

SELECT p.ProductCategoryID, pc.Name, SUM(sd.LineTotal) AS Total
FROM SalesLT.Product AS p 
	INNER JOIN SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
	INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductCategoryID, pc.Name
ORDER BY Total DESC
;


-- 8. Pedidos con más de 5 productos distintos

SELECT s.SalesOrderID, COUNT(s.ProductID) AS CantidadProductosDif
FROM SalesLT.SalesOrderDetail AS s
GROUP BY s.SalesOrderID;


-- 9. Productos con precio mayor al promedio de su categoría

-- por aparte: 
SELECT p.ProductID, p.Name, p.ListPrice, p.ProductCategoryID, pc.Name
FROM SalesLT.Product AS p INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
;

SELECT p.ProductCategoryID, pc.Name, AVG(p.ListPrice)
FROM SalesLT.Product AS p INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductCategoryID, pc.Name
;

-- subquery:
SELECT p.ProductID, p.Name AS ProductName, p.ListPrice, p.ProductCategoryID, pc.Name AS CategoryName
FROM SalesLT.Product AS p INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice > (
	SELECT AVG(p2.ListPrice) -- NO puedo poner todas las categorias por el WHERE
	FROM SalesLT.Product AS p2
	WHERE p2.ProductCategoryID = p.ProductCategoryID -- aqui lo relaciono con las categorias
	)
ORDER BY p.ListPrice DESC
;


-- 10. Último pedido de cada cliente


SELECT c.CustomerID, c.FirstName, c.LastName, MAX(sh.OrderDate) AS UltimoPedido
FROM SalesLT.Customer AS c INNER JOIN SalesLT.SalesOrderHeader AS sh ON c.CustomerID = sh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY UltimoPedido ASC;



-- 11. Productos nunca vendidos

-- cuales
SELECT p.ProductID, p.Name, p.ProductCategoryID, p.ListPrice, sd.ProductID, sd.SalesOrderDetailID
FROM SalesLT.Product AS p LEFT OUTER JOIN  SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
WHERE sd.ProductID IS NULL
;

-- cantidad
SELECT COUNT(*) AS ProductosNuncaVendidos
FROM SalesLT.Product AS p LEFT OUTER JOIN SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
WHERE sd.ProductID IS NULL
;



-- 12. Clientes con más de un pedido

SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(sh.SalesOrderID) AS CantidadOrdenes
FROM SalesLT.Customer AS c INNER JOIN SalesLT.SalesOrderHeader AS sh ON c.CustomerID = sh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(sh.SalesOrderID) > 1
;

-- verificar:
SELECT COUNT(*) AS TotalClientes
FROM SalesLT.Customer; -- cantidad total de clientes

SELECT COUNT(DISTINCT CustomerID) AS ClientesConOrden
FROM SalesLT.SalesOrderHeader; -- cantidad de clientes que han hecho una orden

SELECT COUNT(*) AS ClientesSinOrden
FROM SalesLT.Customer AS c LEFT JOIN SalesLT.SalesOrderHeader AS sh ON c.CustomerID = sh.CustomerID
WHERE sh.CustomerID IS NULL; -- cantidad de clientes que NO han realizado una orden


-- 13. Ranking de productos por ventas dentro de cada categoría

-- para ranking global entre todas las categorias
SELECT p.ProductID, p.Name, pc.Name AS Categoria, COUNT(sd.ProductID) AS CantidadVendida
FROM SalesLT.Product AS p 
	INNER JOIN SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
	INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductID, p.Name, pc.Name
ORDER BY pc.Name, COUNT(sd.ProductID) DESC
;

-- pero como quiero dentro de CADA categoria, debo corregir, de forma que:
-- 1. "ventas" se refiere a plata $$, no a cantidad vendida
-- 2. use una funcion RANK 
SELECT p.ProductID, p.Name, pc.Name AS Categoria, SUM(sd.LineTotal) AS TotalVenta,
	RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sd.LineTotal) DESC) AS SalesRank
FROM SalesLT.Product AS p 
	INNER JOIN SalesLT.SalesOrderDetail AS sd ON p.ProductID = sd.ProductID
	INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductID, p.Name, pc.Name
ORDER BY SalesRank DESC
;


-- 14. Pedidos con descuento aplicado (UnitPriceDiscount > 0)

SELECT *
FROM SalesLT.SalesOrderDetail AS sd
WHERE sd.UnitPriceDiscount > 0
;


-- 15. Mostrar clientes de Canadá con sus datos, incluso si no han comprado nada

SELECT c.CustomerID, c.FirstName, c.LastName, a.CountryRegion
FROM SalesLT.Address AS a 
	INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
	INNER JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
WHERE a.CountryRegion = 'Canada'
;


--16. Productos con precio entre $100 y $500

SELECT *
FROM SalesLT.Product AS p
WHERE p.ListPrice > 100 AND p.ListPrice < 500
ORDER BY p.ListPrice ASC
;


--17. Ventas por día de la semana
-- way1:
SELECT 
    DATENAME(WEEKDAY, sh.OrderDate) AS DiaSemana,   -- Nombre del día (Lunes, Martes, etc.)
    SUM(sd.LineTotal) AS TotalVentas                -- Total de ventas de ese día
FROM SalesLT.SalesOrderHeader AS sh INNER JOIN SalesLT.SalesOrderDetail AS sd ON sh.SalesOrderID = sd.SalesOrderID
GROUP BY DATENAME(WEEKDAY, sh.OrderDate)
;

--way2:
SELECT
    -- Asigna un número de 1 a 7 para asegurar el orden cronológico (clave para ordenar)
    DATEPART(dw, soh.OrderDate) AS NumeroDia,
    
    -- Extrae el nombre del día de la semana (ej: Lunes, Martes)
    DATENAME(dw, soh.OrderDate) AS DiaDeLaSemana,

    -- Suma el monto total de ventas (Cantidad * Precio Unitario)
    SUM(sd.OrderQty * sd.UnitPrice) AS MontoTotalVendido

FROM SalesLT.SalesOrderHeader AS soh INNER JOIN SalesLT.SalesOrderDetail AS sd ON soh.SalesOrderID = sd.SalesOrderID
GROUP BY
    DATEPART(dw, soh.OrderDate),
    DATENAME(dw, soh.OrderDate) -- Agrupamos por ambos para sumar correctamente
ORDER BY NumeroDia  -- Ordena por el número del día para ir de Domingo/Lunes a Sábado/Domingo
;

--18. Pedidos más caros (Top 5) con cliente y fecha

SELECT TOP (5)
	c.CustomerID, c.FirstName, c.LastName, sh.OrderDate, sh.DueDate, sd.LineTotal
FROM SalesLT.SalesOrderDetail AS sd 
	INNER JOIN SalesLT.SalesOrderHeader AS sh ON sd.SalesOrderID = sh.SalesOrderID
	INNER JOIN SalesLT.Customer AS c ON sh.CustomerID = c.CustomerID
ORDER BY sd.LineTotal DESC
;


--19. "Lista completa de nombres: Clientes + Ciudades donde están ubicados" usando el comando UNION
-- es decir, para combinar información de clientes y direcciones en un solo resultado,
-- mostrando todos los nombres relevantes (personas y ciudades) en una lista unificada.

-- try1: WRONG porque CustomerID y State tienen tipos de datos diferentes
SELECT c.FirstName, c.CustomerID AS 'Tipo'
FROM SalesLT.Customer AS c
UNION 
SELECT a.City, a.StateProvince AS 'Tipo'
FROM SalesLT.Address AS a

-- try2:
SELECT c.FirstName + ' ' + c.LastName AS Nombre, 'Cliente' AS TipoDeDato
FROM SalesLT.Customer AS c
UNION
SELECT a.City AS Nombre,'Ciudad' AS TipoDeDato 
FROM SalesLT.Address AS a
ORDER BY Nombre;

-- esto que sigue NO es exacto lo que pide el ejercicio (en realidad da datos tergiversados) pero se desarrolla a modo de practica:
SELECT SUM(t.CustomerID) AS 'CustomerIDs', SUM(t.FirstName) AS 'FirstNames', SUM(t.LastName) AS 'LastNames',  SUM(t.City) AS 'Cities', SUM(t.StateProvince) AS 'StateProvinces', SUM(t.CountryRegion) AS 'CountryRegion'
FROM
	(SELECT c.CustomerID, c.FirstName, c.LastName, NULL AS 'City', NULL AS 'StateProvince', NULL AS 'CountryRegion'
	FROM SalesLT.Customer AS c
	UNION 
	SELECT NULL AS 'CustomerID', NULL AS 'FirstName', NULL AS 'LastName', a.City, a.StateProvince, a.CountryRegion
	FROM SalesLT.Address AS a) AS t


--20. Productos (ID) que están en el catálogo pero NUNCA se han vendido
-- (con EXCEPT)

-- my way:
SELECT p.ProductID, p.Name, p.ProductNumber, p.ProductModelID, p.ProductCategoryID
FROM SalesLT.Product AS p
EXCEPT
SELECT p2.ProductID, p2.Name, p2.ProductNumber, p2.ProductModelID, p2.ProductCategoryID
FROM SalesLT.Product AS p2 LEFT OUTER JOIN  SalesLT.SalesOrderDetail AS sd  ON sd.ProductID = p2.ProductID
WHERE sd.ProductID IS NOT NULL
;

-- shorter way:
SELECT p.ProductID
FROM SalesLT.Product AS p
EXCEPT
SELECT sd.ProductID
FROM SalesLT.SalesOrderDetail AS sd
;


-- 21.Total de ventas por mes (solo 2 columnas)
-- usando FORMAT() con respecto al OrderDate...

SELECT
    -- 1. Usa FORMAT para mostrar el nombre completo del mes y el año (ej: "January 2008")
    FORMAT(sh.OrderDate, 'yyyy-MM') AS MesVenta,

    -- 2. Calcula el monto total de ventas
    SUM(sd.LineTotal) AS MontoTotal
FROM SalesLT.SalesOrderHeader AS sh INNER JOIN SalesLT.SalesOrderDetail AS sd ON sh.SalesOrderID = sd.SalesOrderID
GROUP BY FORMAT(sh.OrderDate, 'yyyy-MM') -- Es crucial agrupar por el mismo valor FORMAT() para sumar correctamente.
ORDER BY FORMAT(sh.OrderDate, 'yyyy-MM')
;

SELECT *
FROM SalesLT.SalesOrderDetail

-- 22. Clientes que han gastado más que el promedio general, usando CTE.
--Es decir, Clientes VIP: Los que han gastado más del promedio en total


-- Estructura CTE:
WITH NombreCTE AS (
    SELECT ...
    FROM ...
    WHERE ...
)
SELECT ...
FROM NombreCTE;

-- mi respuesta:
WITH TotalperCustomer AS (
	SELECT  c.FirstName, c.LastName, SUM(sd.LineTotal) AS CustomerTotal --aqui determino cuanto ha gastado cada persona
	FROM SalesLT.Customer AS c
		INNER JOIN SalesLT.SalesOrderHeader AS sh ON c.CustomerID = sh.CustomerID
		INNER JOIN SalesLT.SalesOrderDetail AS sd ON sh.SalesOrderID = sd.SalesOrderID
	GROUP BY c.FirstName, c.LastName
)
SELECT ca.FirstName, ca.LastName, ca.CustomerTotal
FROM TotalperCustomer AS ca
WHERE ca.CustomerTotal > (
	SELECT AVG(ca.CustomerTotal)
	FROM TotalperCustomer AS ca
	)
ORDER BY ca.CustomerTotal DESC
;