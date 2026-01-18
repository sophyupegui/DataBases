-- consulta: ordenes con clientes y empleados
SELECT 
	ov.Nro AS NumeroOrden,
	ov.Fecha_solicitud AS FechaSolicitud,
	c.Nombre + ' ' + c.Apellidos AS Clientes,
	c.Telefono,
	e.Nombre + ' ' + e.Apellidos AS Empleados,
	e.Cargo,
	ov.domicilio
FROM OrdenVenta AS ov 
	INNER JOIN Cliente AS c On ov.CC = c.CC
	INNER JOIN Empleado AS e ON e.Id = ov.Id_Empleado
;

-- crear vista
CREATE VIEW v_OrdenesConClientesEmpleados
AS
SELECT 
	ov.Nro AS NumeroOrden,
	ov.Fecha_solicitud AS FechaSolicitud,
	c.Nombre + ' ' + c.Apellidos AS Clientes,
	c.Telefono,
	e.Nombre + ' ' + e.Apellidos AS Empleados,
	e.Cargo,
	ov.domicilio
FROM OrdenVenta AS ov 
	INNER JOIN Cliente AS c On ov.CC = c.CC
	INNER JOIN Empleado AS e ON e.Id = ov.Id_Empleado
;

-- la consulta NO es permanente, pero el VIEW sí
-- se guarda en la base de datos, en la carpeta "Views"

-- usar el view:
SELECT * 
FROM v_OrdenesConClientesEmpleados;
-- lo llamo igual que a una funcion tabular
	

