SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

-- consulta: ventas por cliente

SELECT
	ov.Nro AS NumeroOrden,
	v.fecha_venta AS FechaVenta,
	p.Código AS CodigoProducto,
	p.Nombre AS NombreProducto,
	ovp.cantidad AS Cantidad,
	ovp.descuento AS Descuento,
	p.Precio As PrecioUnitario,
	(p.Precio * ovp.cantidad * (1-ovp.descuento / 100.0)) AS Subtotal
FROM OrdenVenta AS ov 
	INNER JOIN Cliente AS c On ov.CC = c.CC
	INNER JOIN OrdenVenta_Producto AS ovp On ov.Nro = ovp.Nro
	INNER JOIN Producto AS p ON ovp.código = p.Código
	INNER JOIN Venta AS v ON ov.Nro = v.Nro
WHERE c.CC = '45299977199'
;

-- funcion TABULAR

CREATE FUNCTION dbo.VentasPorClientes(@CCCliente BIGINT)
RETURNS TABLE
AS
RETURN
(
SELECT
	ov.Nro AS NumeroOrden,
	v.fecha_venta AS FechaVenta,
	p.Código AS CodigoProducto,
	p.Nombre AS NombreProducto,
	ovp.cantidad AS Cantidad,
	ovp.descuento AS Descuento,
	p.Precio As PrecioUnitario,
	(p.Precio * ovp.cantidad * (1-ovp.descuento / 100.0)) AS Subtotal
FROM OrdenVenta AS ov 
	INNER JOIN Cliente AS c On ov.CC = c.CC
	INNER JOIN OrdenVenta_Producto AS ovp On ov.Nro = ovp.Nro
	INNER JOIN Producto AS p ON ovp.código = p.Código
	INNER JOIN Venta AS v ON ov.Nro = v.Nro
WHERE c.CC = @CCCliente
);

-- llamar funcion

-- SELECT dbo.VentasPorClientes('45299977199') AS ventasPorCliente

-- asi seria si fuera funcion SCALAR, pero como es TABULAR, debo hacerlo asi:

SELECT * 
FROM dbo.VentasPorClientes('45299977199')
;