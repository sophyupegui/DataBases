
-- 1. Lista de todos los datos de la tabla Clientes. 

-- uso * para que me de todo
SELECT * 
FROM Cliente
;
-- como resultado me da una tabla


SELECT *
FROM [Cliente]
;
-- corchetes [] indican que lea completo, no solo hasta el espacio
-- me permite manejar mejor la implementacion


-------------------------------------

-- si NO quiero que me de la CC, puedo definir exactamente que atributos sí quiero:
SELECT Nombre, Apellidos, Telefono
FROM Cliente
;

-- si quiero que me de la CC al final, pongo el orden que yo quiera:
SELECT Nombre, Apellidos, Telefono, CC
FROM Cliente
;

----------------------------------------

-- 2. Lista de los datos de los  clientes que han realizado  órdenes. 

-- tengo que involucrar dos tablas, no importa tanto el orden con tal de que sean las dos correctas
-- como dos tablas pueden tener atributos nombrados igual, pongo NombreTabla.Atributo

-- way 1:
SELECT Cliente.Nombre, Cliente.Apellidos, Cliente.Telefono, OrdenVenta.Nro -- aqui pongo los atributos que quiero que tenga mi tabla resultante
FROM Cliente, OrdenVenta -- aqui pongo las dos tablas que van a ser relacionadas
WHERE Cliente.CC = OrdenVenta.CC -- aqui relaciono las dos tablas
;

-- las dos tablas que quiero relacionar tengo que poder relacionar algun atributo para poder usar el INNER JOIN (con ON)

-- way 2 (diapositivas):
SELECT Cliente.Nombre, Cliente.Apellidos, Cliente.Telefono, OrdenVenta.Nro -- aqui pongo los atributos que quiero que tenga mi tabla resultante
FROM Cliente INNER JOIN OrdenVenta ON Cliente.CC = OrdenVenta.CC -- aqui relaciono mis dos tablas
;


-- generalmente, quiero EVITAR el cross-join (el producto cartesiano)

-------------------------------------------


-- 3. Nro y fecha de solicitud de las órdenes de venta que se  han entregado, con la fecha de entrega. 

-- "entregado" no estaba en nuestro modelo relacional original, entonces toca interpretar
-- "entregado" = venta final = tabla Venta

-- way 1:
SELECT OrdenVenta.Nro, OrdenVenta.Fecha_solicitud, Venta.fecha_venta
FROM OrdenVenta, Venta
WHERE OrdenVenta.Nro = Venta.Nro
;

-- way 2:
SELECT OrdenVenta.Nro, OrdenVenta.Fecha_solicitud, Venta.fecha_venta
FROM OrdenVenta INNER JOIN Venta ON OrdenVenta.Nro = Venta.Nro
;

-----------------------------------------

-- 4. Lista de empleados que han atendido más de dos órdenes de venta, ordenados según la cantidad de atendida. 

-- my try:
SELECT OrdenVenta.Id_Empleado, Empleado.Nombre, Empleado.Apellidos, COUNT (OrdenVenta.Id_Empleado) AS Cantidad_ordenes_por_empleado
FROM OrdenVenta INNER JOIN Empleado ON OrdenVenta.Id_Empleado = Empleado.Id
GROUP BY OrdenVenta.Id_Empleado, Empleado.Nombre, Empleado.Apellidos, Empleado.Id
HAVING COUNT (OrdenVenta.Id_Empleado)>2
ORDER BY Cantidad_ordenes_por_empleado DESC
;

-- correcta:
SELECT OrdenVenta.Id_Empleado, Empleado.Nombre, Empleado.Apellidos, COUNT (OrdenVenta.Nro) AS Cantidad -- AQUI es donde cambia, en el COUNT OrdenVenta.Id vs OrdenVenta.Nro
FROM OrdenVenta INNER JOIN Empleado ON OrdenVenta.Id_Empleado = Empleado.Id
GROUP BY OrdenVenta.Id_Empleado, Empleado.Nombre, Empleado.Apellidos
HAVING COUNT (OrdenVenta.Id_Empleado)>2
ORDER BY Cantidad DESC
;

-- conclusion: en este caso dan el mismo resultado, tener precausion en otros casos

-------------------------------------------

-- 5. Órdenes de venta que NO se han realizado hasta la fecha  (Nro de orden, cliente que la solicitó y empleado que la  atendió). 

SELECT OrdenVenta.Nro, Cliente.Nombre AS CN, Cliente.Apellidos AS CA, Empleado.Nombre AS EN, Empleado.Apellidos AS EA, Venta.fecha_venta
FROM OrdenVenta 
	LEFT OUTER JOIN Venta ON OrdenVenta.Nro = Venta.Nro    -- Aqui tomo todas los # de ordenes que = # de venta final -> este join me pone NULL donde no hay coincidencias
	INNER JOIN Cliente ON OrdenVenta.cc = Cliente.CC
	INNER JOIN Empleado ON Empleado.Id = OrdenVenta.Id_Empleado
WHERE Venta.fecha_venta IS NULL   -- Aqui excluyo las ventas finales que ya SÍ se realizaron
;

-- no todas las ordenes de venta se convierten en ventas (orden venta = add to cart; venta = venta final = pay cart)
-- porque me interesan las que sean ordenes de compra y las ventas que todavia no se han realizado (aka, toda orden de compra que sea solo orden de compra y todavia no venta y todas las ventas que no se han finalizado)

-----------------------------------------------

-- 6. Por cada orden de venta el precio total que se debe pagar. 

SELECT OrdenVenta.Nro, 
	SUM((Producto.Precio-(Producto.Precio*OrdenVenta_Producto.descuento/100))*OrdenVenta_Producto.cantidad) AS Total
FROM Producto 
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
GROUP BY OrdenVenta.Nro 
;

----------------------------------------------

-- 7. Monto total de las ventas realizadas en el año 2012.

-- Total por fecha
SELECT OrdenVenta.Fecha_solicitud, Venta.fecha_venta,
	SUM((Producto.Precio-(Producto.Precio*OrdenVenta_Producto.descuento/100))*OrdenVenta_Producto.cantidad) AS Total
FROM Producto 
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
	INNER JOIN Venta ON Venta.Nro = OrdenVenta.Nro
WHERE Venta.fecha_venta >= '2012-01-01' AND Venta.fecha_venta <  '2013-01-01'
GROUP BY OrdenVenta.Nro, OrdenVenta.Fecha_solicitud, Venta.fecha_venta;
;

-- Total del año
SELECT 
    SUM((Producto.Precio - (Producto.Precio * OrdenVenta_Producto.descuento / 100.0)) * OrdenVenta_Producto.cantidad) AS Total_Año
FROM Producto
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
	INNER JOIN Venta ON Venta.Nro = OrdenVenta.Nro
WHERE Venta.fecha_venta >= '2012-01-01' AND Venta.fecha_venta <  '2013-01-01'
;
-- quito el group by y las fechas del select
-- Si no quiero dividir por grupos, y solo necesitas un único total → no pongas columnas adicionales en el SELECT. Así la suma se hace sobre toda la tabla filtrada

-- Total de todo el negocio
SELECT 
    SUM((Producto.Precio - (Producto.Precio * OrdenVenta_Producto.descuento / 100.0)) * OrdenVenta_Producto.cantidad) AS Total_Año
FROM Producto
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
	INNER JOIN Venta ON Venta.Nro = OrdenVenta.Nro
;

-- Version profe de total para un año especifico:
SELECT 
    SUM((Producto.Precio - (Producto.Precio * OrdenVenta_Producto.descuento / 100.0)) * OrdenVenta_Producto.cantidad) AS Total_Año
FROM Producto
	INNER JOIN OrdenVenta_Producto ON Producto.Código = OrdenVenta_Producto.código
	INNER JOIN OrdenVenta ON OrdenVenta_Producto.Nro = OrdenVenta.Nro
	INNER JOIN Venta ON Venta.Nro = OrdenVenta.Nro
WHERE YEAR(Venta.fecha_venta) = 2012
;