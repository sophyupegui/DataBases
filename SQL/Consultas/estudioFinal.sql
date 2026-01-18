

-- Crear funcion ESCALAR
CREATE FUNCTION dbo.nombreFuncion(@Variable TIPODEDATO)
RETURNS TIPODEDATO
AS
BEGIN
	DECLARE @Variable TIPODEDATO; -- mismo tipo de dato que el RETURN
	SELECT @Variable = algo -- aqui simplemente estoy declarando la variable 
	FROM tabla1 AS t1 INNER JOIN tabla2 AS t2 ON t1.ID = t2.ID
	WHERE condicion = @Variable;
	RETURN ISNULL(@Variable, 0);
END

-- llamar funcion ESCALAR
SELECT dbo.nombreFuncion('algo') AS Variable
;

---------------------------------------

-- Crear funcion TABULAR
CREATE FUNCTION dbo.nombreFuncion(@Variable TIPODEDATO)
RETURNS TABLE
AS
RETURN
(
SELECT columna, columna, columna
FROM tabla1 AS t1 INNER JOIN tabla2 AS t2 ON t1.ID = t2.ID
WHERE condicion = @Variable
);

-- llamar funcion
SELECT * 
FROM dbo.VentasPorClientes('45299977199')
;


----------------------------------------


-- Crear procedimiento SIN parametros
CREATE PROCEDURE nombreMiProcedimiento
AS
BEGIN
	SELECT * 
	FROM tabla
END;
-- me sale en la carpeta de Programmability -> Stored procedures

-- ejecutar
EXEC seleccionarTodosLosEmpleados @Cargo = 'Asesor';


---------------------------------------


-- Crear procedimiento CON parametros
CREATE PROCEDURE nombreMiProcedimiento
	@Variable TIPODEDATO -- al igual que en las funciones, @ es para mi variables. en este caso, sera para mi parametro
AS
BEGIN
	SELECT * 
	FROM tabla AS t
	WHERE condicion = @Variable
END;

-- ejecutar:
EXEC seleccionarTodosLosEmpleados @Cargo = 'Asesor';


-----------------------------------------

-- Crear procedimiento con 2 parametros


CREATE PROCEDURE actualizarPrecioProducto
	@PorcentajeCambio INT,
	@CodigoProducto VARCHAR(50) = NULL -- esto basicamente me deja que sea opcional introducir este parametro
AS
BEGIN
	-- Validar que el porcentaje este dentro un rango razonable
	IF @PorcentajeCambio < -100 OR @PorcentajeCambio > 100
	BEGIN
		RAISERROR ('El porcentaje de cambio debe estar entre -100 y 100', 16,1);
		RETURN
	END
	
	-- Actualizar el precio de un producto
	UPDATE Producto --	en vez de SELECT *
	SET Precio = Precio * (1 + @PorcentajeCambio /100.0)
	FROM Producto 
	WHERE (@CodigoProducto IS NULL OR Producto.Código = @CodigoProducto);

	-- Retornar la cantidad de filas afectadas
	RETURN @@ROWCOUNT;
END;

-- ejecutar (con 2 parametros):
--EXEC nombreProcedimiento parametro1, parametro2;
EXEC actualizarPrecioProducto -10, '26DRE5';


------------------------------------------


