/*
==================================================================================
We'll develop a project for a "Fictional Online Retail Company". 
This project will cover creating a database, tables, and indexes, inserting data,
and writing various queries for reporting and data analysis.
==================================================================================

Project Overview: Fictional Online Retail Company
--------------------------------------
A.	Database Design
	-- Database Name: OnlineRetailDB

B.	Tables:
	-- Customers: Stores customer details.
	-- Products: Stores product details.
	-- Orders: Stores order details.
	-- OrderItems: Stores details of each item in an order.
	-- Categories: Stores product categories.

C.	Insert Sample Data:
	-- Populate each table with sample data.

D. Write Queries:
	-- Retrieve data (e.g., customer orders, popular products).
	-- Perform aggregations (e.g., total sales, average order value).
	-- Join tables for comprehensive reports.
	-- Use subqueries and common table expressions (CTEs).
*/

/* LET'S GET STARTED */

-- Create the database
CREATE DATABASE OnlineRetailDB;
GO

-- Use the database
USE OnlineRetailDB;
Go

-- Create the Customers table
CREATE TABLE Customers (
			CustomerID INT PRIMARY KEY IDENTITY(1,1),
			FirstName NVARCHAR(50),
			LastName NVARCHAR(50),
			Email NVARCHAR(100),
			Phone NVARCHAR(50),
			Address NVARCHAR(255),
			City NVARCHAR(50),
			State NVARCHAR(50),
			ZipCode NVARCHAR(50),
			Country NVARCHAR(50),
			CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products Table
CREATE TABLE Products (
			ProductID INT PRIMARY KEY IDENTITY(1,1),
			ProductName NVARCHAR(100),
			CategoryID INT,
			Price DECIMAL(10,2),
			Stock INT,
			CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories Table
CREATE TABLE Categories (
			CategoryID INT PRIMARY KEY IDENTITY(1,1),
			CategoryName NVARCHAR(100),
			Description NVARCHAR(255)
);

-- Create the Orders Table
CREATE TABLE Orders (
			OrderID INT PRIMARY KEY IDENTITY(1,1),
			CustomerID INT,
			OrderDate DATETIME DEFAULT GETDATE(),
			TotalAmount DECIMAL(10,2),
			Foreign KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the OrderItems Table
CREATE TABLE OrderItems (
			OrderItemID INT PRIMARY KEY IDENTITY(1,1),
			OrderID INT,
			ProductID INT,
			Quantity INT,
			Price DECIMAL(10,2)
			Foreign KEY (ProductID) REFERENCES Products(ProductID),
			Foreign KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert sample data into categories table
INSERT INTO Categories(CategoryName, Description)
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronics Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES
('Smartphone',1,699.99,50),
('Laptop',1,999.99,30),
('T-shirt',2,19.99,100),
('Jeans',2,49.99,60),
('Fictional Novel',3,14.99,200),
('Science Journal',3,29.99,150);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerID, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);

-- Query 1: Retrieve all orders for a specific customer
SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM OnlineRetailDB.dbo.Orders o
JOIN OnlineRetailDB.dbo.OrderItems oi ON o.OrderId = oi.OrderID
JOIN OnlineRetailDB.dbo.Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;

-- Query 2: Find the total sales for each product
select p.ProductID, p.ProductName, sum(p.Price * oi.Quantity) as total_sales
from OnlineRetailDB.dbo.Products  p
join OnlineRetailDB.dbo.OrderItems  oi
on p.ProductID = oi.ProductID
group by p.ProductID, p.ProductName
order by total_sales desc;

-- Query 3: Calculate the average order value
select avg(TotalAmount) as average_order_value
from OnlineRetailDB.dbo.Orders o

-- Query 4: List the top 5 customers by total spending
SELECT CustomerID, FirstName, LastName, TotalSpent, rn
FROM
(SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpent,
ROW_NUMBER() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS rn
FROM OnlineRetailDB.dbo.Customers c
JOIN OnlineRetailDB.dbo.Orders o
ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, c.FirstName, c.LastName)
sub WHERE rn <= 5;

-- Query 5: Retrieve the most popular product category
select CategoryID, CategoryName, totalquantitysold
from
(select p.CategoryID, c.CategoryName, SUM(oi.quantity) as totalquantitysold, ROW_NUMBER() over(order by SUM(oi.quantity) desc) as rn  
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.ProductID = p.ProductID
join OnlineRetailDB.dbo.Categories c
on c.CategoryID = p.CategoryID
group by p.CategoryID, c.CategoryName) as a
where rn <= 1;

-- to insert a product with zero stock
INSERT INTO OnlineRetailDB.dbo.Products (ProductName, CategoryID, Price, Stock)
VALUES ('Keyboard',1,39.99,0);

-- Query 6: List all products that are out of stock
Select * from OnlineRetailDB.dbo.Products; 
Select ProductID, ProductName
from OnlineRetailDB.dbo.Products 
where Stock = 0;

-- Query 7: Find customers who placed orders in the last 30 days
Select c.CustomerID, c.FirstName, c.LastName
from OnlineRetailDB.dbo.Customers c
join OnlineRetailDB.dbo.Orders o
on o.CustomerID = c.CustomerID
where o.OrderDate >= DATEADD(Day, -30, GETDATE());

-- Query 8: Calculate the total number of orders placed each month
Select year(orderdate) as year, MONTH(orderdate) as month, count(orderid) as totalorders
from OnlineRetailDB.dbo.Orders o
group by year(orderdate), MONTH(orderdate)

-- Query 9: Retrieve the details of the most recent order
select top 1 
o.OrderID, o.OrderDate, o.TotalAmount
from OnlineRetailDB.dbo.Orders o
order by 2 desc;

-- Query 10: Find the average price of products in each category
select p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, avg(p.Price) as avg_price
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.productID = p.productID
join OnlineRetailDB.dbo.Categories C
on c.CategoryID = p.CategoryID
group by p.ProductID, p.ProductName, p.CategoryID, c.CategoryName

-- Query 11: List customers who have never placed an order
select c.CustomerID, c.FirstName
from OnlineRetailDB.dbo.Orders o
right join OnlineRetailDB.dbo.Customers c
on o.CustomerID = c.CustomerID
where o.OrderID is NULL;

-- Query 12: Retrieve the total quantity sold for each product
select oi.ProductID, sum(oi.quantity) as totalquantity
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.ProductID = p.ProductID
group by oi.ProductID;

-- Query 13: Calculate the total revenue generated from each category
select oi.ProductID, p.ProductName, c.CategoryID, c.CategoryName, sum(oi.Price*oi.Quantity) as total_revenue
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.ProductID = p.ProductID
join OnlineRetailDB.dbo.Categories C
on c.CategoryID = p.CategoryID
group by oi.ProductID, p.ProductName, c.CategoryID, c.CategoryName
order by sum(oi.Price*oi.Quantity) desc

-- Query 14: Find the highest-priced product in each category
SELECT c.CategoryID, c.CategoryName, p1.ProductID, p1.ProductName, p1.Price
FROM OnlineRetailDB.dbo.Categories c 
JOIN OnlineRetailDB.dbo.Products p1
ON c.CategoryID = p1.CategoryID
WHERE p1.Price = (SELECT Max(Price) FROM OnlineRetailDB.dbo.Products p2 WHERE p2.CategoryID = p1.CategoryID)
ORDER BY p1.Price DESC;

-- Query 15: Retrieve orders with a total amount greater than a specific value of 25
select OrderID, sum(Price * Quantity) as total_amount
from OnlineRetailDB.dbo.OrderItems oi
group by OrderID
having sum(Price * Quantity) > 25;

-- Query 16: List products along with the number of orders they appear in
select p.ProductID, p.ProductName, count(oi.OrderID) as OrderCount
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.ProductID = p.ProductID
group by p.ProductID, p.ProductName
order by count(oi.OrderID) desc;

-- Query 17: Find the top 3 most frequently ordered products
select top 3 p.ProductID, p.ProductName, count(oi.OrderID) as OrderCount
from OnlineRetailDB.dbo.OrderItems oi
join OnlineRetailDB.dbo.Products p
on oi.ProductID = p.ProductID
group by p.ProductID, p.ProductName
order by count(oi.OrderID) desc;

-- Query 18: Calculate the total number of customers from each country
select country, count(customerId)
from OnlineRetailDB.dbo.Customers c
group by country
order by count(customerId) desc;

-- Query 19: Retrieve the list of customers along with their total spending
Select o.CustomerID, FirstName, LastName, sum(TotalAmount) as total_spent
from OnlineRetailDB.dbo.Customers c
join OnlineRetailDB.dbo.Orders o
on c.CustomerID = o.CustomerID
join OnlineRetailDB.dbo.OrderItems oi
on oi.OrderID = o.OrderID
group by o.CustomerID, FirstName, LastName

--Query 20: List orders with more than a specified number of items (e.g., 5 items)
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM OnlineRetailDB.dbo.Orders o JOIN OnlineRetailDB.dbo.OrderItems oi
ON o.OrderID = oi.OrderID
JOIN OnlineRetailDB.dbo.Customers c
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(oi.OrderItemID) >= 1
ORDER BY NumberOfItems;

/*
===========================
LOG MAINTENANCE
===========================
Let's create additional queries that involve updating, deleting, and maintaining logs of these operations 
in the OnlineRetailDB database. 

To automatically log changes in the database, you can use triggers in SQL Server. 
Triggers are special types of stored procedures that automatically execute in response 
to certain events on a table, such as INSERT, UPDATE, or DELETE.

Here’s how you can create triggers to log INSERT, UPDATE, and DELETE operations 
for the tables in the OnlineRetailDB.

We'll start by adding a table to keep logs of updates and deletions.

Step 1: Create a Log Table
Step 2: Create Triggers for Each Table
	
	A. Triggers for Products Table
		-- Trigger for INSERT on Products table
		-- Trigger for UPDATE on Products table
		-- Trigger for DELETE on Products table

	B. Triggers for Customers Table
		-- Trigger for INSERT on Customers table
		-- Trigger for UPDATE on Customers table
		-- Trigger for DELETE on Customers table
*/

-- Let's get started

-- Create a Log Table
CREATE TABLE ChangeLog (
		LogID INT PRIMARY KEY IDENTITY(1,1),
		TableName NVARCHAR(50),
		Operation NVARCHAR(10),
		RecordID INT,
		ChangeDate DATETIME DEFAULT GETDATE(),
		ChangedBy NVARCHAR(100)
);
GO

-- A. Triggers for Products Table
-- Trigger for INSERT on products table
CREATE TRIGGER trg_Insert_Product
on OnlineRetailDB.dbo.Products
AFTER INSERT
AS
BEGIN

        --Insert a record into the Changelog Table
		INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
		SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER
		FROM inserted;

		-- Display a message indicating that the trigger has fired
		PRINT 'INSERT operation logged for Products table.';

END;
GO


-- Try to insert one record into the Products table
INSERT INTO OnlineRetailDB.dbo.Products(ProductName, CategoryID, Price, Stock)
VALUES ('Wireless Mouse', 1, 4.99, 20);

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Spiderman Multiverse Comic', 3, 2.50, 150);

-- Display products table
SELECT * FROM OnlineRetailDB.dbo.Products;

-- Display ChangeLog table
SELECT * FROM OnlineRetailDB.dbo.ChangeLog;

-- Trigger for UPDATE on Products table
CREATE TRIGGER trg_Update_Product
ON OnlineRetailDB.dbo.Products
AFTER UPDATE
AS
BEGIN	
	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'UPDATE operation logged for Products table.';
END;
GO

-- Try to update any record from Products table
UPDATE OnlineRetailDB.dbo.Products 
SET Price = Price - 300 
WHERE ProductID = 2;

-- Trigger for DELETE a record from Products table
CREATE OR ALTER TRIGGER trg_delete_Product
ON OnlineRetailDB.dbo.Products
AFTER DELETE
AS
BEGIN
	
	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER
	FROM deleted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'DELETE operation logged for Products table.';
END;
GO

-- Try to delete an existing record to see the effect of Trigger
DELETE FROM OnlineRetailDB.dbo.Products
WHERE ProductID = 9;

-- B. Triggers for Customers Table
-- Trigger for INSERT on Customers table
CREATE OR ALTER TRIGGER trg_Insert_Customers
ON OnlineRetailDB.dbo.Customers
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Customers table.';
END;
GO

-- Trigger for UPDATE on Customers table
CREATE OR ALTER TRIGGER trg_Update_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'UPDATE operation logged for Customers table.';
END;
GO

-- Trigger for DELETE on Customers table
CREATE OR ALTER TRIGGER trg_Delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER
	FROM deleted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'DELETE operation logged for Customers table.';
END;
GO

-- Try to insert a new record to see the effect of Trigger
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 
'Delhi', '5456665', 'INDIA');
GO
	
-- Try to update an existing record to see the effect of Trigger
UPDATE Customers 
SET State = 'Florida' 
WHERE State = 'IL';
GO
	
-- Try to delete an existing record to see the effect of Trigger
DELETE FROM Customers 
WHERE CustomerID = 4;
GO

/*
===============================
Implementing Indexes
===============================

Indexes are crucial for optimizing the performance of your SQL Server database, 
especially for read-heavy operations like SELECT queries. 

Let's create indexes for the OnlineRetailDB database to improve query performance.

A. Indexes on Categories Table
	1. Clustered Index on CategoryID: Usually created with the primary key.
*/

USE OnlineRetailDB;
GO
-- Clustered Index on Categories Table (CategoryID)
CREATE CLUSTERED INDEX IDX_Categories_CategoryID
ON Categories(CategoryID);

/*
B. Indexes on Products Table
	1. Clustered Index on ProductID: This is usually created automatically when 
	   the primary key is defined.
	2. Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
	3. Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
*/

-- Drop Foreign Key Constraint from OrderItems Table - ProductID
ALTER TABLE OrderItems
DROP CONSTRAINT FK__OrderItem__Price__5535A963;

-- Clustered Index on Products Table (ProductID)
CREATE CLUSTERED INDEX IDX_Products_ProductID
on Products(ProductID);

-- Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
on Products(CategoryID);

-- Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
CREATE NONCLUSTERED INDEX IDX_Products_Price
on Products(CategoryID);

-- Recreate Foreign Key Constraint on OrderItems (ProductID Column)
ALTER TABLE OrderItems
ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);

/*
C. Indexes on Orders Table
	1. Clustered Index on OrderID: Usually created with the primary key.
	2. Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
	3. Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
*/

-- Drop Foreign Key Constraint from OrderItems Table - OrderID
ALTER TABLE OrderItems
DROP CONSTRAINT FK__OrderItem__Order__5629CD9C;

-- Clustered Index on OrderID
CREATE CLUSTERED INDEX IDX_Orders_OrderID
on Orders(OrderID);

-- Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
on Orders(CustomerID);

--  Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
on Orders(OrderDate);

-- Recreate Foreign Key Constraint on OrderItems (OrderID Column)
ALTER TABLE OrderItems 
ADD CONSTRAINT FK_OrderItems_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);

/*
D. Indexes on OrderItems Table
	1. Clustered Index on OrderItemID: Usually created with the primary key.
	2. Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
	3. Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
*/

-- Clustered Index on OrderItemID
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

-- Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO

--  Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO


/*

E. Indexes on Customers Table
	1. Clustered Index on CustomerID: Usually created with the primary key.
	2. Non-Clustered Index on Email: To speed up queries filtering by Email.
	3. Non-Clustered Index on Country: To speed up queries filtering by Country.
*/

-- Drop Foreign Key Constraint from Orders Table - CustomerID
ALTER TABLE Orders 
DROP CONSTRAINT FK__Orders__Customer__52593CB8;

-- Clustered Index on CustomerID
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

-- Non-Clustered Index on Email: To speed up queries filtering by Email.
CREATE NONCLUSTERED INDEX IDX_Customers_Email
ON Customers(Email);
GO

--  Non-Clustered Index on Country: To speed up queries filtering by Country.
CREATE NONCLUSTERED INDEX IDX_Customers_Country
ON Customers(Country);
GO

-- Recreate Foreign Key Constraint on Orders (CustomerID Column)
ALTER TABLE Orders 
ADD CONSTRAINT FK_Orders_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO

/*
===============================
Implementing Views
===============================

	Views are virtual tables that represent the result of a query. 
	They can simplify complex queries and enhance security by restricting access to specific data.
	They don't take physical space.

*/

-- View for Product Details: A view combining product details with category names.
CREATE VIEW vw_ProductDetails AS
SELECT ProductID, ProductName, Price, Stock, CategoryName
FROM OnlineRetailDB.dbo.Products as p
INNER JOIN OnlineRetailDB.dbo.Categories as c
on p.CategoryID = c.CategoryID
GO

-- Display product details with category names using view
SELECT *
FROM vw_ProductDetails;

-- View for Customer Orders : A view to get a summary of orders placed by each customer.
CREATE VIEW vw_CustomerOrders AS
SELECT c.CustomerID, FirstName, LastName, COUNT(o.OrderID) as total_orders, sum(Quantity*p.Price) as total_amount
FROM OnlineRetailDB.dbo.Customers as c
INNER JOIN OnlineRetailDB.dbo.Orders as o
on c.CustomerID = o.CustomerID
INNER JOIN OnlineRetailDB.dbo.OrderItems as oi
on oi.OrderID = o.OrderID
INNER JOIN OnlineRetailDB.dbo.Products as p
on p.ProductID = oi.ProductID
group by c.CustomerID, FirstName, LastName;

-- Display customer details with category names using view
SELECT *
FROM vw_CustomerOrders;

-- View for Recent Orders: A view to display orders placed in the last 30 days.
CREATE VIEW vw_RecentOrders AS
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName, sum(Quantity*oi.Price) as Order_amount
FROM OnlineRetailDB.dbo.Customers as c
INNER JOIN OnlineRetailDB.dbo.Orders as o
on c.CustomerID = o.CustomerID
INNER JOIN OnlineRetailDB.dbo.OrderItems as oi
on oi.OrderID = o.OrderID
group by o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName;

-- Display product details with category names using view
SELECT *
FROM vw_RecentOrders;

--Query 31: Retrieve All Products with Category Names
--Using the vw_ProductDetails view to get a list of all products along with their category names.
select *
from vw_ProductDetails;

--Query 32: Retrieve Products within a Specific Price Range
--Using the vw_ProductDetails view to find products priced between $100 and $500.
select *
from vw_ProductDetails
where Price between 10 and 500;

--Query 33: Count the Number of Products in Each Category
--Using the vw_ProductDetails view to count the number of products in each category.
select CategoryName, count(productid)
from vw_ProductDetails
group by CategoryName;

--Query 34: Retrieve Customers with More Than 1 Orders
--Using the vw_CustomerOrders view to find customers who have placed more than 1 orders.
select CustomerID, FirstName, LastName, total_orders
from vw_CustomerOrders
where total_orders > 1;

--Query 35: Retrieve the Total Amount Spent by Each Customer
--Using the vw_CustomerOrders view to get the total amount spent by each customer.
select CustomerID, FirstName, LastName, total_amount
from vw_CustomerOrders
order by total_amount desc;

--Query 36: Retrieve Recent Orders Above a Certain Amount
--Using the vw_RecentOrders view to find recent orders where the total amount is greater than $700.
select OrderID, OrderDate, Order_amount
from vw_RecentOrders
where Order_amount > 700;

--Query 37: Retrieve the Latest Order for Each Customer
--Using the vw_RecentOrders view to find the latest order placed by each customer.
select a.OrderID, a.OrderDate, a.CustomerID, a.FirstName, a.LastName, a.Order_amount
from vw_RecentOrders as a
inner join (select CustomerID, max(orderdate) as LatestOrderDate from vw_RecentOrders group by CustomerID) as latest 
on a.CustomerID = latest.CustomerID and a.OrderDate = latest.LatestOrderDate;

--Query 38: Retrieve Products in a Specific Category
--Using the vw_ProductDetails view to get all products in a specific category, such as 'Electronics'.
Select ProductID, ProductName, CategoryName, Price
from vw_ProductDetails
where CategoryName = 'Books';

--Query 39: Retrieve Total Sales for Each Category
--Using the vw_ProductDetails and vw_CustomerOrders views to calculate the total sales for each category.
SELECT pd.CategoryName, SUM(oi.Quantity * p.Price) AS TotalSales
FROM OnlineRetailDB.dbo.OrderItems oi
INNER JOIN OnlineRetailDB.dbo.Products p ON oi.ProductID = p.ProductID
INNER JOIN vw_ProductDetails pd ON p.ProductID = pd.ProductID
GROUP BY pd.CategoryName
ORDER BY TotalSales DESC;

--Query 40: Retrieve Customer Orders with Product Details
--Using the vw_CustomerOrders and vw_ProductDetails views to get customer orders along with the details 
-- of the products ordered.
select b.CustomerID, FirstName, LastName, a.ProductID, ProductName, a.Price, CategoryName
from OnlineRetailDB.dbo.Orders as o
inner join OnlineRetailDB.dbo.OrderItems as oi
on o.OrderID = oi.OrderID
inner join vw_ProductDetails as a 
on a.ProductID = oi.ProductID
inner join vw_CustomerOrders as b
on b.CustomerID = o.CustomerID

--Query 41: Retrieve Top Customers by Total Spending
--Using the vw_CustomerOrders view to find the top 5 customers based on their total spending.
select top 1 customerid, FirstName, LastName, total_orders, total_amount
from vw_CustomerOrders
order by total_amount desc;

--Query 42: Retrieve Products with Low Stock
--Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 50 units.
select * 
from vw_ProductDetails
where Stock < 50;

--Query 43: Retrieve Orders Placed in the Last 7 Days
--Using the vw_RecentOrders view to find orders placed in the last 7 days.
select *
from vw_RecentOrders
where OrderDate > DATEADD(DAY, -7, GETDATE());

--Query 44: Retrieve Products Sold in the Last Month
--Using the vw_RecentOrders view to find products sold in the last month.
select p.ProductID, ProductName, sum(quantity) as num_products
from vw_RecentOrders as a
inner join OnlineRetailDB.dbo.OrderItems as oi
on oi.OrderID = a.OrderID
inner join OnlineRetailDB.dbo.Products as p
on p.ProductID = oi.ProductID
where a.orderdate >= DATEADD(month, -1, GETDATE())
group by p.ProductID, ProductName;

--Query 45: Retrieve Products Sold in the Last Year
--Using the vw_RecentOrders view to find products sold in the last year.
select p.ProductID, ProductName, sum(quantity) as num_products
from vw_RecentOrders as a
inner join OnlineRetailDB.dbo.OrderItems as oi
on oi.OrderID = a.OrderID
inner join OnlineRetailDB.dbo.Products as p
on p.ProductID = oi.ProductID
where a.orderdate >= DATEADD(YEAR, -1, GETDATE())
group by p.ProductID, ProductName;

/*
=========================================================
Implementing Security / Role-Based Access Control (RBAC)
=========================================================

To manage access control in SQL Server, you'll need to use a combination of SQL Server's security features, 
such as logins, users, roles, and permissions. 

Here's a step-by-step guide on how to do this:

### Step 1: Create Logins
----------------------------------
			First, create logins at the SQL Server level. 
			Logins are used to authenticate users to the SQL Server instance.
*/
-- Create a login with SQL Server Authentication
CREATE LOGIN SalesUser
WITH PASSWORD = 'strongpassword';

/*
### Step 2: Create Users
----------------------------------
			Next, create users in the `OnlineRetailDB` database for each login. 
			Users are associated with logins and are used to grant access to the database.
*/
USE OnlineRetailDB;
GO

-- Create a user in the database for the SQL Server Login
CREATE USER SalesUser
FOR LOGIN SalesUser;

/*
### Step 3: Create Roles
----------------------------------
			Define roles in the database that will be used to group users with similar permissions. 
			This helps simplify permission management.
*/
-- Create roles in the database
CREATE ROLE SalesRole;
CREATE ROLE MarketingRole;

/*
### Step 4: Assign Users to Roles
----------------------------------
			Add the users to the appropriate roles.
*/
-- Add users to roles
EXEC sp_addrolemember 'SalesRole', 'SalesUser';

/*
### Step 5: Grant Permissions
----------------------------------
			Grant the necessary permissions to the roles based on the access requirements
*/
-- GRANT SELECT permission on the Customers Table to the SalesRole
GRANT select 
on Customers TO  SalesRole;

-- GRANT INSERT permission on the Orders Table to the SalesRole
GRANT insert
on Orders To SalesRole;

-- GRANT UPDATE permission on the Orders Table to the SalesRole
GRANT update
on Orders To SalesRole;

-- GRANT SELECT permission on the Products Table to the SalesRole
GRANT select
on Products TO SalesRole;

SELECT * FROM Customers;
DELETE FROM Customers;

SELECT * FROM Orders;
DELETE FROM Orders;
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES (1, GETDATE(), 600);

SELECT * FROM Products;
DELETE FROM Products;

/*
### Step 6: Revoke Permissions (if needed)
----------------------------------
			If you need to revoke permissions, you can use the `REVOKE` statement.
*/
-- REVOKE INSERT permission on the Orders to the SalesRole
REVOKE insert
on orders FROM SalesRole;

/* 
### Step 7: View Effective Permissions
----------------------------------
			You can view the effective permissions for a user using the query
*/
select *
from fn_my_permissions(NULL, 'DATABASE');






/*
==================
Summary
==================
	1. Create Logins: Authenticate users at the SQL Server level.
	2. Create Users: Create users in the database for the logins.
	3. Create Roles: Group users with similar permissions.
	4. Assign Users to Roles: Add users to appropriate roles.
	5. Grant Permissions: Grant necessary permissions to roles.
	6. Revoke Permissions: Revoke permissions if needed.
	7. View Effective Permissions: Check the effective permissions for users.
*/

/*
	Here are 20 different scenarios for access control in SQL Server. 
	These scenarios cover various roles and permissions that can be assigned to users 
	in the `OnlineRetailDB` database.
*/

--- Scenario 1: Read-Only Access to All Tables
CREATE ROLE ReadOnlyRole;
GRANT select 
on SCHEMA::dbo TO ReadOnlyRole;

--- Scenario 2: Data Entry Clerk (Insert Only on Orders and OrderItems)
CREATE ROLE DataEntryClerk;
GRANT insert
on Orders TO DataEntryClerk;
GRANT insert
on OrderItems TO DataEntryClerk;

--- Scenario 3: Product Manager (Full Access to Products and Categories)
CREATE ROLE ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductManagerRole;

--- Scenario 4: Order Processor (Read and Update Orders)
CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

--- Scenario 5: Customer Support (Read Access to Customers and Orders)
CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;

--- Scenario 6: Marketing Analyst (Read Access to All Tables, No DML)
CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;

--- Scenario 7: Sales Analyst (Read Access to Orders and OrderItems)
CREATE ROLE SalesAnalystRole;
GRANT SELECT ON Orders TO SalesAnalystRole;
GRANT SELECT ON OrderItems TO SalesAnalystRole;

--- Scenario 8: Inventory Manager (Full Access to Products)
CREATE ROLE InventoryManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO InventoryManagerRole;

--- Scenario 9: Finance Manager (Read and Update Orders)
CREATE ROLE FinanceManagerRole;
GRANT SELECT, UPDATE ON Orders TO FinanceManagerRole;

--- Scenario 10: Database Backup Operator (Backup Database)
CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;

--- Scenario 11: Database Developer (Full Access to Schema Objects)
CREATE ROLE DatabaseDeveloperRole;
GRANT CREATE TABLE, ALTER, DROP ON SCHEMA::dbo TO DatabaseDeveloperRole;

--- Scenario 12: Restricted Read Access (Read Only Specific Columns)
CREATE ROLE RestrictedReadRole;
GRANT SELECT (FirstName, LastName, Email) ON Customers TO RestrictedReadRole;

--- Scenario 13: Reporting User (Read Access to Views Only)
CREATE ROLE ReportingRole;
GRANT SELECT ON SalesReportView TO ReportingRole;
GRANT SELECT ON InventoryReportView TO ReportingRole;

--- Scenario 14: Temporary Access (Time-Bound Access)
-- Grant access
CREATE ROLE TempAccessRole;
GRANT SELECT ON SCHEMA::dbo TO TempAccessRole;

-- Revoke access after the specified period
REVOKE SELECT ON SCHEMA::dbo FROM TempAccessRole;

--- Scenario 15: External Auditor (Read Access with No Data Changes)
CREATE ROLE AuditorRole;
GRANT SELECT ON SCHEMA::dbo TO AuditorRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AuditorRole;

--- Scenario 16: Application Role (Access Based on Application)
CREATE APPLICATION ROLE AppRole WITH PASSWORD = 'StrongPassword1';
GRANT SELECT, INSERT, UPDATE ON Orders TO AppRole;

--- Scenario 17: Role-Based Access Control (RBAC) for Multiple Roles 
-- Combine roles
CREATE ROLE CombinedRole;
EXEC sp_addrolemember 'SalesRole', 'CombinedRole';
EXEC sp_addrolemember 'MarketingRole', 'CombinedRole';

--- Scenario 18: Sensitive Data Access (Column-Level Permissions)
CREATE ROLE SensitiveDataRole;
GRANT SELECT (Email, Phone) ON Customers TO SensitiveDataRole;

--- Scenario 19: Developer Role (Full Access to Development Database)
CREATE ROLE DevRole;
GRANT CONTROL ON DATABASE::OnlineRetailDB TO DevRole;

--- Scenario 20: Security Administrator (Manage Security Privileges)
CREATE ROLE SecurityAdminRole;
GRANT ALTER ANY LOGIN TO SecurityAdminRole;
GRANT ALTER ANY USER TO SecurityAdminRole;
GRANT ALTER ANY ROLE TO SecurityAdminRole;