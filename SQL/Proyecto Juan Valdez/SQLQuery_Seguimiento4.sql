-- ========================================================== 
-- SEGUIMIENTO 4 - BASES DE DATOS 
-- Autoras: ANA MARÍA BARRERO & SOPHIA UPEGUI 
-- Universidad EIA - 2025-2 
-- ==========================================================

----------------------------------------------------------------
-- VISTA
----------------------------------------------------------------
-- Pregunta de negocio: ¿Qué clientes han realizado pedidos en más de una tienda distinta?
-- Esto ayuda a identificar clientes con alta fidelidad a la marca, porque visitan diferentes puntos de venta.
-- Vista: vw_clientes_frecuentes

CREATE VIEW vw_clientes_frecuentes AS
SELECT c.CC, c.nombre,
       COUNT(DISTINCT e.tienda_id) AS tiendas_visitadas
FROM cliente AS c
	INNER JOIN pedido_new AS p ON c.CC = p.CC
	INNER JOIN empleado_pedido_new AS ep ON p.orden_id = ep.orden_id
	INNER JOIN empleados AS e ON e.id_empleado = ep.id_empleado
GROUP BY c.CC, c.nombre
HAVING COUNT(DISTINCT e.tienda_id) > 1
;

--------------------------------------------------------------
-- FUNCIÓN ESCALAR 1
--------------------------------------------------------------
-- Pregunta de negocio: Dado el nombre de un proveedor, ¿cuál es su número de teléfono?
-- Esto permite validar y centralizar el contacto de proveedores clave.
-- Funcion: fn_proveedor_telefono

CREATE OR ALTER FUNCTION dbo.fn_proveedor_telefono(@proveedor_id INT = NULL, @nombre NVARCHAR(50) = NULL)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @tel NVARCHAR(50);
    SELECT @tel = telefono
    FROM proveedor
    WHERE (@proveedor_id IS NOT NULL AND proveedor_id = @proveedor_id)
       OR (@nombre IS NOT NULL AND nombre = @nombre);

    RETURN ISNULL(@tel, 'N/A');
END

-- Buscar por ID:
SELECT dbo.fn_proveedor_telefono(800002, NULL) AS Telefono;

-- Buscar por nombre:
SELECT dbo.fn_proveedor_telefono(NULL, 'Dulce Sirope Ltda.') AS Telefono;

-- Si no existe devuelve 'N/A':
SELECT dbo.fn_proveedor_telefono(999999, NULL) AS Telefono;


--------------------------------------------------------------
-- FUNCIÓN ESCALAR 2
--------------------------------------------------------------
-- Pregunta de negocio: ¿Cuántos empleados tiene una tienda específica?
-- Se usa para medir la dotación de personal por tienda.
-- Funcion: : fn_total_empleados_tienda

CREATE OR ALTER FUNCTION dbo.fn_total_empleados_tienda(@tienda_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;
    SELECT @total = COUNT(*)
    FROM empleados
    WHERE tienda_id = @tienda_id;

    RETURN ISNULL(@total, 0);
END

-- llamar funcion
SELECT dbo.fn_total_empleados_tienda('100001') AS TotalEmpleados;


--------------------------------------------------------------
-- FUNCIÓN TABULAR 1
--------------------------------------------------------------
-- Pregunta de negocio: ¿Qué pedidos se han realizado desde una ciudad específica, con cliente y fecha?
-- Sirve para análisis de ventas por ubicación geográfica.
-- Funcion: fn_pedidos_por_ciudad
 
CREATE OR ALTER FUNCTION dbo.fn_pedidos_por_ciudad(@ciudad NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT p.orden_id, c.nombre AS cliente, p.fecha, t.ciudad
    FROM pedido_new AS p
		INNER JOIN cliente AS c ON p.CC = c.CC
		INNER JOIN empleado_pedido_new AS ep ON ep.orden_id = p.orden_id
		INNER JOIN empleados AS e ON e.id_empleado = ep.id_empleado
		INNER JOIN tienda AS t ON t.tienda_id = e.tienda_id
    WHERE t.ciudad = @ciudad
);

-- llamar funcion
SELECT * 
FROM dbo.fn_pedidos_por_ciudad('Itagui')
;

--------------------------------------------------------------
-- FUNCIÓN TABULAR 2
--------------------------------------------------------------
-- Pregunta de negocio: ¿Qué proveedores están asociados a una tienda en particular, junto con el producto que ofrecen?
-- Funcion: fn_proveedores_por_tienda

CREATE OR ALTER FUNCTION dbo.fn_proveedores_por_tienda(@tienda_id INT)
RETURNS @t TABLE
(
    proveedor_id INT,
    nombre NVARCHAR(50),
    producto NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @t (proveedor_id, nombre, producto)
    
	SELECT p.proveedor_id, p.nombre, p.producto_provee
    FROM tienda_proveedor tp INNER JOIN proveedor p ON p.proveedor_id = tp.proveedor_id
    WHERE tp.tienda_id = @tienda_id;

    RETURN;
END

-- llamar funcion
SELECT * 
FROM dbo.fn_proveedores_por_tienda('100001')
;


--------------------------------------------------------------
-- PROCEDIMIENTO (SIN PARÁMETROS)
--------------------------------------------------------------
-- Pregunta de negocio: ¿Quiénes son los clientes que más han comprado en el mes actual?
-- Útil para campañas de fidelización y recompensas.
-- Procedimiento: sp_top_clientes_mes

CREATE OR ALTER PROCEDURE dbo.sp_top_clientes_mes
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT TOP 10 c.CC, c.nombre,
               SUM(pr.precio * pp.cantidad) AS total_mes
        FROM pedido_new p
			INNER JOIN cliente c ON p.CC = c.CC
			INNER JOIN pedido_producto_sd pp ON pp.orden_id = p.orden_id
			INNER JOIN producto pr ON pr.producto_id = pp.producto_id
        WHERE MONTH(p.fecha) = MONTH(GETDATE()) AND YEAR(p.fecha) = YEAR(GETDATE())
        GROUP BY c.CC, c.nombre
        ORDER BY total_mes DESC;
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_top_clientes_mes: %s', 16, 1, @ErrorMessage);
    END CATCH
END

-- ejecutar proceso
EXEC sp_top_clientes_mes;

-- verificacion
SELECT MONTH(fecha) AS mes, YEAR(fecha) AS año, 
	COUNT(*) AS cantidad_pedidos
FROM dbo.pedido_new
GROUP BY MONTH(fecha), YEAR(fecha)
ORDER BY año DESC, mes DESC;
-- conclusion: efectivamente no hay ventas registradas en octubre



-- --------------------------------------------------------------
-- PROCEDIMIENTO (CON PARÁMETROS)
--------------------------------------------------------------
-- Pregunta de negocio: ¿Cómo actualizar el teléfono de un cliente de forma segura, asegurando rollback si ocurre un error?
-- Procedimiento: sp_actualizar_telefono_cliente

CREATE OR ALTER PROCEDURE dbo.sp_actualizar_telefono_cliente
    @CC BIGINT,
    @nuevoCelular NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        UPDATE cliente
        SET celular = @nuevoCelular
        WHERE CC = @CC;

        IF @@ROWCOUNT = 0
            RAISERROR('Cliente no encontrado.', 16, 1);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_actualizar_telefono_cliente: %s', 16, 1, @ErrorMessage);
    END CATCH
END

-- ejecutar proceso
EXEC sp_actualizar_telefono_cliente;



--------------------------------------------------------------
-- CURSOR
--------------------------------------------------------------
-- Pregunta de negocio: ¿Qué tan “activos” están los proveedores por ciudad?
-- (Contar cuántas tiendas están asociadas a cada proveedor y marcar los que no tienen ninguna asociación para seguimiento).

-- Por qué cursor:
-- Iteramos proveedor por proveedor para generar métricas por ciudad y una bandera de “sin tiendas” (útil para logística/abastecimiento).

-- Estructura:
-- Cursor sobre proveedores
-- Contar tiendas asociadas vía tienda_proveedor
-- Insertar en #EstadoProveedor

IF OBJECT_ID('tempdb..#EstadoProveedor') IS NOT NULL DROP TABLE #EstadoProveedor;
CREATE TABLE #EstadoProveedor (
    proveedor_id INT PRIMARY KEY,
    nombre NVARCHAR(50),
    ciudad NVARCHAR(50),
    tiendas_asociadas INT,
    sin_tiendas BIT
);

DECLARE 
	@prov_id INT, 
	@prov_nom NVARCHAR(50), 
	@prov_ciudad NVARCHAR(50);

DECLARE cur_prov CURSOR FAST_FORWARD FOR
    SELECT proveedor_id, nombre, ciudad
    FROM dbo.proveedor;

OPEN cur_prov;
FETCH NEXT FROM cur_prov INTO @prov_id, @prov_nom, @prov_ciudad;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @n_tiendas INT;
    SELECT @n_tiendas = COUNT(*)
    FROM dbo.tienda_proveedor
    WHERE proveedor_id = @prov_id;

    INSERT INTO #EstadoProveedor (proveedor_id, nombre, ciudad, tiendas_asociadas, sin_tiendas)
    VALUES (@prov_id, @prov_nom, @prov_ciudad, ISNULL(@n_tiendas,0), CASE WHEN ISNULL(@n_tiendas,0)=0 THEN 1 ELSE 0 END);

    FETCH NEXT FROM cur_prov INTO @prov_id, @prov_nom, @prov_ciudad;
END

CLOSE cur_prov;
DEALLOCATE cur_prov;

-- llamar
SELECT * 
FROM #EstadoProveedor 
ORDER BY sin_tiendas DESC, tiendas_asociadas ASC;

-- verificar
SELECT p.proveedor_id, p.nombre AS proveedor, t.tienda_id, t.tipo_tienda, t.ciudad
FROM juanValdez.dbo.proveedor AS p
	INNER JOIN juanValdez.dbo.tienda_proveedor AS tp ON tp.proveedor_id = p.proveedor_id
	INNER JOIN juanValdez.dbo.tienda AS t ON t.tienda_id = tp.tienda_id
WHERE p.nombre = 'Lacteos del Valle & Co.';

