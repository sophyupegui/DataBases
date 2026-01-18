-------------------------------------------------------
-- SOPHIA UPEGUI ROBLEDO
-- BASES DE DATOS 2025-2
-------------------------------------------------------


-- a) Muestre todos los pedidos de los clientes entre el 1. de julio 1997 y el 30. de octubre 1997 con sus datos 
-- (con el Id del pedido, el nombre del cliente (compañía) y la fecha del pedido). 
-- El resultado debe mostrar los pedidos más recientes primero.

SELECT p.IdPedido, c.Compania AS 'Compañia', p.FPedido AS FechaPedido
FROM Clientes AS c INNER JOIN Pedidos AS p ON c.IdCliente = p.IdCliente
ORDER BY p.FPedido DESC
;


-- b) Muestre todos los productos con su Id y nombre cuyo precio (PrecioUnd) es mayor al promedio de todos los productos.

SELECT p.IdProducto, p.Nombre, p.PrecioUnd
FROM Productos AS p
WHERE p.PrecioUnd > (
	SELECT AVG(p2.PrecioUnd)
	FROM Productos AS p2
)
ORDER BY p.IdProducto ASC
;


-- c) Muestre todas las zonas (nombre), donde no hay empleados.

SELECT z.IdZona, z.Nombre, ez.IdEmpleado
FROM Zonas AS z LEFT OUTER JOIN Empleados_Zonas AS ez ON z.IdZona = ez.IdZona
WHERE ez.IdZona IS NULL
;


-- d) Muestre en una sola tabla los proveedores y despachadores (nombres), 
-- indicando cuál entrada de la tabla resultante se refiere a un proveedor y cual a un despachador.


SELECT p.Compania AS Nombre, 'Proveedor' AS Tipo
FROM Proveedores AS p
UNION
SELECT d.Compania AS Nombre, 'Despachador' AS Tipo
FROM Despachadores AS d
;


-- e) Genere un procedimiento almacenado para mostrar los pedidos realizados por un cliente específico, 
-- recibiendo como parámetro el IdCliente. Indique cómo se invoca este procedimiento.
CREATE PROCEDURE MostrarPedidos @IdCliente nchar(5)
AS
	SELECT p.IdPedido, c.Compania AS 'Compañia', p.FPedido AS FechaPedido, p.FDespacho AS FechaDespacho
	FROM Clientes AS c INNER JOIN Pedidos AS p ON c.IdCliente = p.IdCliente
	WHERE c.IdCliente = @IdCliente
GO
;
-- profe aqui tirará error porque debe ser lo unico en el codigo, pero por temas del examen esta en la misma consulta
-- al pegarlo en otro query y ejecutar, se almacena el procedimiento
-- se invoca este procedimiento a continuacion:

SELECT * 
FROM Clientes -- aqui solo visualizo tabla para elegir un IdCliente a llamar para probar procedimiento

-- llamo el procedimiento:
EXEC MostrarPedidos @IdCliente = 'ALFKI';