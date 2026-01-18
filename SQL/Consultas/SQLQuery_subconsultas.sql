
-- Mostrar los productos donde el precio es máximo 

-- primero analizo los productos
SELECT *
FROM Producto
;
-- varios productos pueden tener el mismo precio = más de un producto puede tener el precio max, entonces:

SELECT Producto.Nombre, Producto.Precio
FROM Producto
WHERE Producto.Precio =
	(
	SELECT MAX (Producto.precio)
	FROM Producto
	)
;

-- el compu primero procesa lo más interno a lo más externo (o sea desde el anidado al global / general)


------------------------------------------------

-- Por cada empleado cantidad de órdenes que se han realizado ya.
SELECT Empleado.nombre, Empleado.apellidos, COUNT(Nro) AS CantidadVendidas 
FROM Empleado INNER JOIN OrdenVenta ON Empleado.Id=OrdenVenta.Id_empleado 
GROUP BY Empleado.nombre, Empleado.apellidos
;

-- y la cantidad que no se cumplieron.
SELECT NC.nombre, NC.apellidos, COUNT(NC.Nro) AS CantidadNoVendidas 
FROM (
	SELECT OrdenVenta.Nro, Empleado.Id, Empleado.nombre, Empleado.apellidos, OrdenVenta.fecha_solicitud 
	FROM OrdenVenta INNER JOIN Empleado ON OrdenVenta.Id_empleado=Empleado.Id 
	WHERE OrdenVenta.Nro NOT IN -- NOT IN es casi que lo mismo que el LEFT OUTER JOIN 
		(
		SELECT Nro 
		FROM Venta 
		)
	) AS NC 
GROUP BY NC.Id, NC.nombre, NC.apellidos
;

-- Si tengo 2+ SELECT's, debo ponerle alias (AS nuevoNombre)


-----------------------------------------------


-- Aquellos productos para los que no se hicieron ordenes en el mes actual

-- way 1: NOT IN
SELECT Producto.Código, Producto.Nombre
FROM Producto
WHERE Producto.Código NOT IN (
	SELECT OrdenVenta_Producto.código
	FROM OrdenVenta_Producto INNER JOIN OrdenVenta ON OrdenVenta.Nro = OrdenVenta_Producto.Nro
	WHERE MONTH (OrdenVenta.fecha_solicitud) = MONTH(getdate()) AND YEAR(getdate()) = YEAR(OrdenVenta.fecha_solicitud)
) 
;
-- "getdate()" accede a la fecha actual del sistema operativo y lo asume como la fecha actual


-- way 2: EXCEPT
SELECT Producto.Código 
FROM  Producto 
EXCEPT 
SELECT OrdenVenta_Producto.código 
FROM OrdenVenta inner join OrdenVenta_Producto ON OrdenVenta.Nro=OrdenVenta_Producto.Nro 
WHERE MONTH(OrdenVenta.fecha_solicitud) = MONTH(getdate()) and YEAR(getdate())=YEAR(OrdenVenta.fecha_solicitud); 

-- NOT IN es similar al EXCEPT, pero el EXCEPT es más estricto, no me deja combinar tanto


--------------------------------------------

-- Listado de todos los que están en la base de datos (nombre y apellidos de clientes y empleados). Que especifique cuál es cliente y cuál es empleado. 

SELECT Empleado.Nombre, Empleado.Apellidos, 'Empleado' AS Tipo
FROM Empleado
UNION -- UNION me une dos tablas (uniendo dos consultas) siempre y cuando ambas tablas tengan las mismas columnas. El resultado es una sola tabla
SELECT Cliente.Nombre, Cliente.Apellidos, 'Cliente' AS Tipo
FROM Cliente
;

-- NO me sirve "texto" tiene que ser obligatorio con 'texto'

--------------------------------------------


--Órdenes de venta que no se han realizado hasta la fecha (Nro de orden, cliente que la solicitó y empleado que la atendió) utilizando subconsultas

SELECT 
	OrdenVenta.Nro, 
	Cliente.CC, Cliente.Nombre AS 'Nombre Cliente', Cliente.Apellidos AS 'Apellido Cliente',
	Empleado.Id, Empleado.Nombre AS 'Nombre Empleado', Empleado.Apellidos AS 'Apellido Empleado'
FROM OrdenVenta 
	INNER JOIN Cliente ON Cliente.CC = OrdenVenta.CC
	INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	)
;

--------------------------------------------

--Aquellas órdenes (cantidad) por empleado que no se cumplieron

-- my try:
SELECT OrdenVenta.Nro, Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) AS 'Cantidad NO Completada'
FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	)
GROUP BY OrdenVenta.Nro, Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
-- Poner # orden de venta hace que los separe por cada orden de venta, pero yo quiero saber el total entonces:

-- solución correcta:
SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) AS 'Cantidad NO Completada'
FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	)
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 


------------------------------------------------------

-- Por cada empleado cantidad de órdenes que no se cumplieron y tienen más de 15 meses de pedidas.

-- my try:
SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) AS 'Cantidad NO Completada'
FROM OrdenVenta
	INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
	LEFT OUTER JOIN Venta ON OrdenVenta.Nro = Venta.Nro    -- Aqui tomo todas los # de ordenes que = # de venta final -> este join me pone NULL donde no hay coincidencias
WHERE Venta.fecha_venta IS NULL -- Aqui excluyo las ventas finales que ya SÍ se realizaron
	AND
	(DATEDIFF (MONTH, OrdenVenta.Fecha_solicitud, GETDATE()) > 15)
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
;

-- version profe:
SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) AS 'Cantidad NO Completada'
FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	) AND DATEDIFF (MONTH, OrdenVenta.Fecha_solicitud, GETDATE()) > 15
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
;
-- con F1 me manda a la pagina de ayuda al seleccionar la funcion que quiero

-- En Edit -> InteliSense --> Refresh Local Cache


---------------------------------------------


-- Cantidad de órdenes vendidas y no vendidas por cada Empleado (el resultado se debe mostrar en una solo tabla)

-- my try:
SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, COUNT(OrdenVenta.Nro) AS 'Cantidad Completada'
FROM OrdenVenta 
	INNER JOIN Empleado ON OrdenVenta.Id_Empleado = Empleado.Id
	INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos
UNION
SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) AS 'Cantidad NO Completada'
FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	)
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
;
-- asi NO funciona porque las columnas tienen que ser las mismas categorias, asi sobre escribo mi cantidad completada, no me agrega la otra, entonces lo que hago es que creo las dos columnas de tacazo al inicio y dejo una vacia y luego sobre escribo (ish)
-- tal que:

SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	COUNT(OrdenVenta.Nro) As 'Vendidas', 
	NULL AS 'No Vendidas'
FROM OrdenVenta 
	INNER JOIN Empleado ON OrdenVenta.Id_Empleado = Empleado.Id
	INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos

UNION

SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
	NULL As 'Vendidas', 
	COUNT(OrdenVenta.Nro) AS 'No Vendidas' 
FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	)
GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
;

-- PERO de dejarlo asi, se me crean como dos filas por empleado que tenga unas ordenes vendidas y otras NO vendidas
-- entonces meto todo a una subconsulta:

SELECT VS.Nombre, VS.Apellidos, SUM(VS.Vendidas) AS Vendidas, SUM(VS.NoVendidas) AS 'No Vendidas'
FROM
	(
	SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
		COUNT(OrdenVenta.Nro) As Vendidas, 
		0 AS NoVendidas
	FROM OrdenVenta 
		INNER JOIN Empleado ON OrdenVenta.Id_Empleado = Empleado.Id
		INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
	GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos

	UNION

	SELECT Empleado.Id, Empleado.Nombre, Empleado.Apellidos, 
		0 As Vendidas, 
		COUNT(OrdenVenta.Nro) AS NoVendidas
	FROM OrdenVenta INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
	WHERE OrdenVenta.Nro NOT IN
		(
		SELECT Venta.Nro
		FROM Venta
		)
	GROUP BY Empleado.Id, Empleado.Nombre, Empleado.Apellidos 
	) AS VS
GROUP BY VS.Nombre, VS.Apellidos
;

-----------------------------------------------

-- aquellos productos para los que no se han hecho órdenes en el mes actual

-- normal
SELECT Producto.Código, Producto.Nombre
FROM Producto 
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta.Nro = OrdenVenta_Producto.Nro
WHERE OrdenVenta.Nro NOT IN
	(
	SELECT Venta.Nro
	FROM Venta
	) 
	-- FALTA POR TERMINAR
;

-- utilizando EXCEPT:
-- con except necesito igualdad en atributos

-- my try:
SELECT Producto.Código, Producto.Nombre
FROM Producto 
-- aqui primero cojo TODOS los productos

EXCEPT -- menos (excluyo):

SELECT Producto.Código, Producto.Nombre
FROM Producto 
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta.Nro = OrdenVenta_Producto.Nro
-- FALTA POR TERMINAR
;

-- version profe:
SELECT Producto.Código, Producto.Nombre
FROM Producto 

EXCEPT 

SELECT OrdenVenta_Producto.código, Producto.Nombre
FROM OrdenVenta_Producto 
	INNER JOIN OrdenVenta ON OrdenVenta.Nro = OrdenVenta_Producto.Nro
	INNER JOIN Producto ON Producto.Código = OrdenVenta_Producto.código
WHERE MONTH(getDate()) = MONTH(OrdenVenta.Fecha_solicitud) 
	AND 
	YEAR(getDate()) = YEAR(OrdenVenta.Fecha_solicitud) -- o sea, no los que se han echo en cualquier diciembre, solo en este diciembre de este año, en los de este mes
;


--------------------------------------------

--Mostrar todos los clientes con la cantidad de órdenes de venta que han realizado


--------------------------------------------

--Productos que se han vendido más

SELECT Producto.Código, SUM(OrdenVenta_Producto.Cantidad) AS Cantidad
FROM Producto 
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
	INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
GROUP BY Producto.Código
HAVING SUM(OrdenVenta_Producto.Cantidad) = 
	(
	SELECT MAX(cantidad)
	FROM
		(
		SELECT Producto.Código, SUM(OrdenVenta_Producto.cantidad) AS Cantidad
		FROM Producto 
			INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
			INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
			INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
		GROUP BY Producto.Código
		) AS NC
	)
;
