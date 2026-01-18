-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================


-- Consulta
SELECT SUM(p.Precio - (p.Precio * ovp.descuento / 100.0) * ovp.cantidad) AS Total
FROM OrdenVenta AS ov 
	INNER JOIN Cliente AS c ON ov.CC = c.CC
	INNER JOIN OrdenVenta_Producto AS ovp ON ov.Nro = ovp.Nro
	INNER JOIN Producto AS p ON ovp.código = p.Código
;

-- Crear funcion
CREATE FUNCTION dbo.obtenerTotalOrdenesPorCliente(@CCCliente VARCHAR(50))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Total DECIMAL(10,2); -- mismo tipo de dato que el RETURN
	SELECT @Total = SUM(p.Precio - (p.Precio * ovp.descuento / 100.0) * ovp.cantidad) -- aqui simplemente estoy declarando la variable Total
	FROM OrdenVenta AS ov 
		INNER JOIN Cliente AS c ON ov.CC = c.CC
		INNER JOIN OrdenVenta_Producto AS ovp ON ov.Nro = ovp.Nro
		INNER JOIN Producto AS p ON ovp.código = p.Código
	WHERE c.CC = @CCCliente;
	RETURN ISNULL(@Total, 0);
END

-- llamar funcion
SELECT dbo.obtenerTotalOrdenesPorCliente('45299977199') AS Total
;