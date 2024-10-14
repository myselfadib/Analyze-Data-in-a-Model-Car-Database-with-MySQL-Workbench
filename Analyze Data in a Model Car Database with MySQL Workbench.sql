USE mintclassics;

-- The product names and the names of the warehouses where they are stored:
SELECT p.productName, w.warehouseName
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode;

-- Products that have less than 900 total sales but more than 7000 units in stock:
SELECT p.productName, p.quantityInStock, COALESCE(SUM(od.quantityOrdered), 0) AS totalSales
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode
HAVING totalSales < 900 AND p.quantityInStock > 7000;

-- Display all data from the 'products' table:
SELECT * FROM products;

-- Display all data from the 'orderdetails' table:
SELECT * FROM orderdetails;

-- List of all products, how much stock each product has, and which warehouse they are stored in:
SELECT w.warehouseName, p.productName, p.quantityInStock
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
ORDER BY w.warehouseName;

-- List of products that have never been sold but are still sitting in the warehouse:
SELECT p.productName, p.quantityInStock, COALESCE(SUM(od.quantityOrdered), 0) AS totalSales
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode
HAVING totalSales = 0 AND p.quantityInStock > 0;

-- List products by their stock levels, allowing you to see which items are overstocked compared to their sales:
SELECT p.productName, p.quantityInStock, COALESCE(SUM(od.quantityOrdered), 0) AS totalSales
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode
ORDER BY p.quantityInStock DESC;

-- Retrieve the total inventory for each warehouse, helping to identify if one warehouse is underutilized 
-- and could be considered for closure:
SELECT w.warehouseName, SUM(p.quantityInStock) AS totalInventory
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseCode
ORDER BY totalInventory ASC;

-- Show all products stored in the 'South' warehouse:
SELECT p.productName, p.quantityInStock
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
WHERE w.warehouseName = 'South';

-- Calculate the total inventory in the 'South' warehouse (source) and 'West' warehouse (destination), 
-- and provide the combined inventory if items from the South warehouse were moved to the West warehouse:
SELECT 
  'South' AS sourceWarehouse, 
  (SELECT SUM(quantityInStock) FROM products WHERE warehouseCode = 'd') AS sourceTotal,  -- South warehouse code 'd'
  'West' AS destinationWarehouse, 
  (SELECT SUM(quantityInStock) FROM products WHERE warehouseCode = 'c') AS destinationTotal,  -- West warehouse code 'c'
  ( (SELECT SUM(quantityInStock) FROM products WHERE warehouseCode = 'd') + 
    (SELECT SUM(quantityInStock) FROM products WHERE warehouseCode = 'c') ) AS combinedTotal;

-- Show all data from the 'warehouses' table:
SELECT * FROM warehouses;

-- Retrieve the percent capacity (warehousePctCap) for both the West (c) and South (d) warehouses, 
-- to determine whether the West warehouse can hold both inventories combined:
SELECT warehouseName, warehousePctCap
FROM warehouses
WHERE warehouseCode IN ('c', 'd');
---------------------------------------------------------------------------------------------------------------------------------------
-- Calculate full capacity of the West warehouse.
-- West is currently at 50% capacity with 124,880 items.
-- Full capacity of West = current inventory / capacity percentage.
-- Full capacity of West = 124,880 / 0.50 = 249,760 items.

-- Calculate full capacity of the South warehouse.
-- South is at 75% capacity with 79,380 items.
-- Full capacity of South = current inventory / capacity percentage.
-- Full capacity of South = 79,380 / 0.75 = 105,840 items.

-- Determine if West can handle the combined inventory.
-- Total inventory of South + West = 79,380 + 124,880 = 204,260 items.
-- West's full capacity is 249,760, which is greater than 204,260.
-- Since West has enough space to hold both inventories, the South warehouse could be closed.
---------------------------------------------------------------------------------------------------------------------------------------
-- Move all South warehouse inventory to the West warehouse.
-- This update simulates transferring all items from South (warehouseCode 'd') to West (warehouseCode 'c').

UPDATE products
SET warehouseCode = 'c'  -- Move all items to West (warehouseCode = 'c')
WHERE warehouseCode = 'd';  -- Items currently in South (warehouseCode = 'd')

-- Verification.
-- After moving the inventory, verify the new total inventory in each warehouse.
SELECT warehouseCode, SUM(quantityInStock) AS totalInventory
FROM products
GROUP BY warehouseCode;
