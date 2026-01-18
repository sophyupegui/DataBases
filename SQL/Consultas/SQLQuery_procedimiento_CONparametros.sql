-- Procedimiento almacenado

-- CREATE PROCEDURE nombreMiProcedimiento
CREATE PROCEDURE seleccionarTodosLosEmpleados
	@Cargo nvarchar(30) -- al igual que en las funciones, @ es para mi variables. en este caso, sera para mi parametro
AS
BEGIN
	SELECT * 
	FROM Empleado
	WHERE Empleado.Cargo = @Cargo
END;

-- este es un procedimiento CON parametros (@Cargo)

--correr:
EXEC seleccionarTodosLosEmpleados @Cargo = 'Asesor';