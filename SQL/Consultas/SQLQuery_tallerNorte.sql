-- Taller BD 09/2025-2 – Consultas SQL

-- 1. Listar todos los clientes con su país
SELECT DISTINCT Clientes.ContactoNombre, Clientes.Pais
FROM Clientes
;

--------------------------------------------

-- 2. Listar productos con su proveedor
SELECT p.Nombre, pv.Compania
FROM Productos AS p INNER JOIN Proveedores AS pv ON p.IdProveedor = pv.IdProveedor
;

--------------------------------------------

-- 3. Órdenes con cliente y empleado asociado

SELECT 
FROM Pedidos, Clientes, Empleados
WHERE Pedidos.IdCliente

--------------------------------------------

-- 4. Número de productos por categoría

--------------------------------------------

-- 5. Top 5 clientes con más pedidos

--------------------------------------------

-- 6. Ingresos por pedido (considerando descuentos)

--------------------------------------------

-- 7. Ingresos totales por cliente


--------------------------------------------

-- 8. Clientes que nunca han hecho pedidos

--------------------------------------------

-- 9. Pedidos que tardaron más de 30 días en despacharse

--------------------------------------------

-- 10. Promedio del valor de los pedidos por año

--------------------------------------------

-- 11. Ranking de clientes por ventas

--------------------------------------------

-- 12. Top 3 productos por ventas dentro de cada categoría
-- p.ej. con … Ranked AS …

--------------------------------------------

-- 13. Clientes con ventas por encima del promedio de su país

--------------------------------------------

-- 14. Pedidos con al menos 5 productos distintos

--------------------------------------------

-- 15. Ventas por mes y categoría (pivot)
-- …inténtelo

--------------------------------------------

-- 16. Tiempo promedio de despacho por país de entrega

--------------------------------------------

-- 17. Clasificación de productos según precio (CASE)
--Pista:
--PrecioUnd *1,5 => muy caro
--PrecioUnd *0,5 => muy barrato
--En todos los demás casos: rango normal

--------------------------------------------

-- 18. Lista única de países, tanto de Clientes como de Proveedores.