-- stored procedures
-- con 2 parametros

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

-- ejecutar (con 1 parametro):
--EXEC nombreProcedimiento parametro;
EXEC actualizarPrecioProducto 5; -- si lo corro asi, significa que a toda la tabla se aumenta el precio por 5%
-- think: tax, aumento costos, etc.

-- ejecutar (con 2 parametros):
--EXEC nombreProcedimiento parametro1, parametro2;
EXEC actualizarPrecioProducto -10, '26DRE5'; -- disminuición del precio del producto 26DRE5