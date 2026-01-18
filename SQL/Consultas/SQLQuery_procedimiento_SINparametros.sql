-- Procedimiento almacenado

-- CREATE PROCEDURE nombreMiProcedimiento
CREATE PROCEDURE seleccionarTodosLosClientes
AS
BEGIN
	SELECT * 
	FROM Cliente
END;
-- me sale en la carpeta de Programmability -> Stored procedures
-- este es un procedimiento SIN parametros

-- Ejecutar procedimiento almacenado (es almacenado porque queda guardado en la carpeta como las funciones)

-- esta funcion EXEC esta reservada unicamente para correr procedimientos almacenados
EXEC seleccionarTodosLosClientes;

-- que tiene de diferente un procedimeiento de una funcion?
-- procedures = automatizar (automatizar columnas)
-- functions = ????, se usa insert, etc
-- en las empresas a veces es más común ver procedures en las empresas