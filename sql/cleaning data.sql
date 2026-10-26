SELECT COUNT(*) AS total_baris
FROM sales2;

select * from sales2;

create table sales_cleaning
like sales2;

insert sales_cleaning 
select * from sales2;

select * from sales_cleaning;

select *, 
row_number () over(
partition by Transaction_ID, Order_ID, Customer_ID, Customer_Name, Customer_Age, Customer_Gender, Customer_Segment,
Order_Date, Order_Time, Sales_Channel, Store_ID, Store_Name, Country, Region, City, Product_ID, Product_Name, Product_Category, Product_Subcategory, Quantity, Unit_Price, Discount_Percentage, Sales_Amount, Cost_Amount, Profit, Payment_Method, Order_Status, 
Delivery_Days, Return_Flag, Return_Reason, Sales_Representative, Promotion_Code, Customer_Rating, Inventory_Level, Order_Year) as row_num
from sales_cleaning;

with duplicate_cte as (
select *, 
row_number () over(
partition by Transaction_ID, Order_ID, Customer_ID, Customer_Name, Customer_Age, Customer_Gender, Customer_Segment,
Order_Date, Order_Time, Sales_Channel, Store_ID, Store_Name, Country, Region, City, Product_ID, Product_Name, Product_Category, 
Product_Subcategory, Quantity, Unit_Price, Discount_Percentage, Sales_Amount, Cost_Amount, Profit, Payment_Method, Order_Status, 
Delivery_Days, Return_Flag, Return_Reason, Sales_Representative, Promotion_Code, Customer_Rating, Inventory_Level, Order_Year) as row_num
from sales_cleaning
) 
select * from duplicate_cte where row_num > 1;

select * from sales_cleaning;


CREATE TABLE `sales_cleaning2` (
  `Transaction_ID` varchar(20) DEFAULT NULL,
  `Order_ID` varchar(20) DEFAULT NULL,
  `Customer_ID` varchar(20) DEFAULT NULL,
  `Customer_Name` varchar(50) DEFAULT NULL,
  `Customer_Age` int DEFAULT NULL,
  `Customer_Gender` varchar(20) DEFAULT NULL,
  `Customer_Segment` varchar(30) DEFAULT NULL,
  `Order_Date` date DEFAULT NULL,
  `Order_Time` time DEFAULT NULL,
  `Sales_Channel` varchar(20) DEFAULT NULL,
  `Store_ID` varchar(20) DEFAULT NULL,
  `Store_Name` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL,
  `Region` varchar(50) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `Product_ID` varchar(20) DEFAULT NULL,
  `Product_Name` varchar(50) DEFAULT NULL,
  `Product_Category` varchar(30) DEFAULT NULL,
  `Product_Subcategory` varchar(30) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Unit_Price` decimal(10,2) DEFAULT NULL,
  `Discount_Percentage` decimal(5,2) DEFAULT NULL,
  `Sales_Amount` decimal(10,2) DEFAULT NULL,
  `Cost_Amount` decimal(10,2) DEFAULT NULL,
  `Profit` decimal(10,2) DEFAULT NULL,
  `Payment_Method` varchar(30) DEFAULT NULL,
  `Order_Status` varchar(20) DEFAULT NULL,
  `Shipping_Method` varchar(20) DEFAULT NULL,
  `Delivery_Days` int DEFAULT NULL,
  `Return_Flag` varchar(5) DEFAULT NULL,
  `Return_Reason` varchar(50) DEFAULT NULL,
  `Sales_Representative` varchar(50) DEFAULT NULL,
  `Promotion_Code` varchar(30) DEFAULT NULL,
  `Customer_Rating` decimal(3,1) DEFAULT NULL,
  `Inventory_Level` int DEFAULT NULL,
  `Order_Year` int DEFAULT NULL,
  `Row_Numb` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from sales_cleaning2;

insert into sales_cleaning2
select *, 
row_number () over(
partition by Transaction_ID, Order_ID, Customer_ID, Customer_Name, Customer_Age, Customer_Gender, Customer_Segment,
Order_Date, Order_Time, Sales_Channel, Store_ID, Store_Name, Country, Region, City, Product_ID, Product_Name, Product_Category, Product_Subcategory, Quantity, Unit_Price, Discount_Percentage, Sales_Amount, Cost_Amount, Profit, Payment_Method, Order_Status, 
Delivery_Days, Return_Flag, Return_Reason, Sales_Representative, Promotion_Code, Customer_Rating, Inventory_Level, Order_Year) as row_num
from sales_cleaning;

select count(*) from sales_cleaning2;

select * from sales_cleaning2 where Row_Numb > 1;

select * from sales_cleaning where Customer_Name = 'James Williams' and Order_ID = 'O0100051';

delete
from sales_cleaning2 where Row_Numb > 1;

select * from sales_cleaning2 where Row_Numb > 1;

-- standardizing data
select * from sales_cleaning2;

select distinct Customer_Gender
from sales_cleaning2;

select *
from sales_cleaning2
where Customer_Gender LIKE 'Non%';

update sales_cleaning2
set Customer_Gender = 'Non Binary'
where Customer_Gender LIKE 'Non%';

select distinct Customer_Segment
from sales_cleaning2;

select distinct Sales_Channel
from sales_cleaning2;

select distinct Store_ID
from sales_cleaning2;

select distinct Store_Name
from sales_cleaning2;

select distinct Country
from sales_cleaning2;

select distinct Region
from sales_cleaning2;

SELECT *
FROM sales_cleaning2
WHERE Region IN ('NRW', 'North Rhine-Westphalia');

update sales_cleaning2
set Region = 'North Rhine-Westphalia'
where Region LIKE 'NRW%';

update sales_cleaning2
set Region = 'North East'
where Region LIKE 'Northeast';

select distinct City
from sales_cleaning2;

UPDATE sales_cleaning2
SET City = TRIM(City);

select distinct City
from sales_cleaning2;

select distinct Product_ID
from sales_cleaning2
order by Product_ID desc;

select distinct Product_Name
from sales_cleaning2;

select * from sales_cleaning2
where Product_Name like '';

SELECT Product_ID, COUNT(DISTINCT Product_Name) AS jml_nama
FROM sales_cleaning2
WHERE Product_Name IS NOT NULL
GROUP BY Product_ID
HAVING COUNT(DISTINCT Product_Name) > 1;

UPDATE sales_cleaning2 SET
    Customer_Name   = NULLIF(Customer_Name,''),
    Customer_Gender = NULLIF(Customer_Gender,''),
    Product_Name    = NULLIF(Product_Name,''),
    Payment_Method  = NULLIF(Payment_Method,''),
    Return_Reason   = NULLIF(Return_Reason,''),
    Promotion_Code  = NULLIF(Promotion_Code,'');
    
SELECT Product_ID, CONCAT('[', Product_Name, ']') AS nama, COUNT(*) AS jml
FROM sales_cleaning2
GROUP BY Product_ID, Product_Name
ORDER BY Product_ID;

UPDATE sales_cleaning2 t
JOIN (SELECT DISTINCT Product_ID, Product_Name FROM sales_cleaning2
      WHERE Product_Name IS NOT NULL) AS p ON t.Product_ID = p.Product_ID
SET t.Product_Name = p.Product_Name
WHERE t.Product_Name IS NULL;

select distinct Product_Category
from sales_cleaning2;

select * from sales_cleaning2;

select distinct Product_Subcategory
from sales_cleaning2;

select distinct Quantity
from sales_cleaning2
order by Quantity;

select * from sales_cleaning2
where Quantity <= 0;


SELECT Transaction_ID, Quantity, Unit_Price, Discount_Percentage, Sales_Amount,
       ROUND(Sales_Amount / (Unit_Price * (1 - Discount_Percentage/100))) AS qty_seharusnya
FROM sales_cleaning2
WHERE Quantity <= 0;


UPDATE sales_cleaning2
SET Quantity = ROUND(Sales_Amount / (Unit_Price * (1 - Discount_Percentage/100)))
WHERE Quantity <= 0;


SELECT COUNT(*) FROM sales_cleaning2 WHERE Quantity <= 0;

SELECT
  COUNT(*) AS total_baris,
  COUNT(*) - COUNT(DISTINCT Transaction_ID) AS duplikat,
  SUM(Quantity <= 0) AS qty_nol_minus,
  SUM(Customer_Age < 16 OR Customer_Age > 90) AS umur_aneh,
  SUM(Discount_Percentage > 25) AS diskon_tinggi,
  SUM(Product_Name = '' OR Customer_Name = '' OR Customer_Gender = ''
      OR Payment_Method = '' OR Promotion_Code = '' OR Return_Reason = '') AS kosong_string,
  SUM(Product_Name IS NULL) AS produk_null,
  SUM(YEAR(Order_Date) <> Order_Year) AS tahun_tidak_cocok,
  SUM(ABS(Quantity*Unit_Price*(1-Discount_Percentage/100) - Sales_Amount) > 0.05) AS sales_tidak_cocok,
  SUM(ABS(Sales_Amount - Cost_Amount - Profit) > 0.05) AS profit_tidak_cocok,
  SUM(Return_Flag = 'Yes' AND Order_Status <> 'Returned') AS retur_tidak_sinkron
FROM sales_cleaning2;

UPDATE sales_cleaning2 SET Customer_Age = NULL
WHERE Customer_Age < 16 OR Customer_Age > 90;



SELECT 'Order_Status' AS kolom, Order_Status COLLATE utf8mb4_bin AS nilai, COUNT(*) AS jml
FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Payment_Method',  Payment_Method  COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Customer_Gender', Customer_Gender COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Product_Category',Product_Category COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Region', Region COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'City', CONCAT('[', City, ']') COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
ORDER BY 1, 2;

SELECT COUNT(*) AS baris, SUM(Sales_Amount) AS total_sales, SUM(Cost_Amount) AS total_cost
FROM sales_cleaning2;

SELECT COUNT(*) AS baris, SUM(Sales_Amount) AS total_sales, SUM(Cost_Amount) AS total_cost
FROM (SELECT DISTINCT * FROM sales2) x;

UPDATE sales_cleaning2 SET
    Customer_Name       = TRIM(Customer_Name),
    Customer_Gender     = TRIM(Customer_Gender),
    Customer_Segment    = TRIM(Customer_Segment),
    Sales_Channel       = TRIM(Sales_Channel),
    Store_Name          = TRIM(Store_Name),
    Country             = TRIM(Country),
    Region              = TRIM(Region),
    City                = TRIM(City),
    Product_Name        = TRIM(Product_Name),
    Product_Category    = TRIM(Product_Category),
    Product_Subcategory = TRIM(Product_Subcategory),
    Payment_Method      = TRIM(Payment_Method),
    Order_Status        = TRIM(Order_Status),
    Shipping_Method     = TRIM(Shipping_Method);
    
UPDATE sales_cleaning2 SET Order_Status = CASE LOWER(Order_Status)
    WHEN 'cancelled'  THEN 'Cancelled'
    WHEN 'completed'  THEN 'Completed'
    WHEN 'processing' THEN 'Processing'
    WHEN 'returned'   THEN 'Returned'
    WHEN 'shipped'    THEN 'Shipped'
    ELSE Order_Status END;

UPDATE sales_cleaning2 SET Payment_Method = CASE LOWER(Payment_Method)
    WHEN 'apple pay'      THEN 'Apple Pay'
    WHEN 'bank transfer'  THEN 'Bank Transfer'
    WHEN 'cash'           THEN 'Cash'
    WHEN 'credit card'    THEN 'Credit Card'
    WHEN 'debit card'     THEN 'Debit Card'
    WHEN 'debitcard'      THEN 'Debit Card'
    WHEN 'paypal'         THEN 'PayPal'
    ELSE Payment_Method END;

UPDATE sales_cleaning2 SET Customer_Gender = CASE LOWER(Customer_Gender)
    WHEN 'female'     THEN 'Female'
    WHEN 'male'       THEN 'Male'
    WHEN 'non-binary' THEN 'Non-binary'
    WHEN 'non binary' THEN 'Non-binary'
    ELSE Customer_Gender END;

UPDATE sales_cleaning2 SET Product_Category = CASE LOWER(Product_Category)
    WHEN 'appliances'      THEN 'Appliances'
    WHEN 'electronics'     THEN 'Electronics'
    WHEN 'furniture'       THEN 'Furniture'
    WHEN 'office supplies' THEN 'Office Supplies'
    ELSE Product_Category END;

UPDATE sales_cleaning2 SET City = CASE LOWER(City)
    WHEN 'austin'      THEN 'Austin'
    WHEN 'chicago'     THEN 'Chicago'
    WHEN 'cologne'     THEN 'Cologne'
    WHEN 'los angeles' THEN 'Los Angeles'
    WHEN 'london'      THEN 'London'
    WHEN 'manchester'  THEN 'Manchester'
    WHEN 'munich'      THEN 'Munich'
    WHEN 'new york'    THEN 'New York'
    WHEN 'paris'       THEN 'Paris'
    WHEN 'sydney'      THEN 'Sydney'
    WHEN 'toronto'     THEN 'Toronto'
    WHEN 'vancouver'   THEN 'Vancouver'
    ELSE City END;

UPDATE sales_cleaning2 SET Region = CASE LOWER(Region)
    WHEN 'british columbia'        THEN 'British Columbia'
    WHEN 'nrw'                     THEN 'North Rhine-Westphalia'
    WHEN 'north rhine-westphalia'  THEN 'North Rhine-Westphalia'
    WHEN 'north east'              THEN 'Northeast'
    WHEN 'northeast'               THEN 'Northeast'
    ELSE Region END;
    
UPDATE sales_cleaning2 SET Customer_Gender = 'Unknown' WHERE Customer_Gender IS NULL;
UPDATE sales_cleaning2 SET Payment_Method  = 'Unknown' WHERE Payment_Method  IS NULL;

SELECT Store_ID,
       COUNT(DISTINCT City    COLLATE utf8mb4_bin) AS kota,
       COUNT(DISTINCT Region  COLLATE utf8mb4_bin) AS region,
       COUNT(DISTINCT Country COLLATE utf8mb4_bin) AS negara
FROM sales_cleaning2
GROUP BY Store_ID
HAVING kota > 1 OR region > 1 OR negara > 1;

SELECT 'Order_Status' AS kolom, Order_Status COLLATE utf8mb4_bin AS nilai, COUNT(*) AS jml
FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Payment_Method',   Payment_Method   COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Customer_Gender',  Customer_Gender  COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Product_Category', Product_Category COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'Region',           Region           COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
UNION ALL SELECT 'City',             CONCAT('[', City, ']') COLLATE utf8mb4_bin, COUNT(*) FROM sales_cleaning2 GROUP BY 2
ORDER BY 1, 2;

ALTER TABLE sales_cleaning2
  ADD COLUMN flag_sales_mismatch TINYINT DEFAULT 0,
  ADD COLUMN flag_profit_fix     TINYINT DEFAULT 0;

UPDATE sales_cleaning2 SET flag_sales_mismatch = 1
WHERE ABS(Quantity*Unit_Price*(1-Discount_Percentage/100) - Sales_Amount) > 0.05;

UPDATE sales_cleaning2 SET flag_profit_fix = 1
WHERE ABS(Sales_Amount - Cost_Amount - Profit) > 0.05;

UPDATE sales_cleaning2
SET Profit = ROUND(Sales_Amount - Cost_Amount, 2)
WHERE flag_profit_fix = 1;

SELECT s.Transaction_ID, s.Product_ID, s.Unit_Price, ROUND(a.rata2,2) AS harga_rata2_produk,
       ROUND(s.Sales_Amount / (s.Quantity*(1-s.Discount_Percentage/100)),2) AS harga_dari_sales
FROM sales_cleaning2 s
JOIN (SELECT Product_ID, AVG(Unit_Price) AS rata2 FROM sales_cleaning2 GROUP BY Product_ID) a
  ON s.Product_ID = a.Product_ID
WHERE ABS(s.Unit_Price / a.rata2 - 1) > 0.5;

UPDATE sales_cleaning2 s
JOIN (SELECT Product_ID, AVG(Unit_Price) AS rata2 FROM sales_cleaning2 GROUP BY Product_ID) a
  ON s.Product_ID = a.Product_ID
SET s.Unit_Price = ROUND(s.Sales_Amount / (s.Quantity*(1-s.Discount_Percentage/100)), 2)
WHERE ABS(s.Unit_Price / a.rata2 - 1) > 0.5;

SELECT Transaction_ID, Discount_Percentage,
       ROUND((1 - Sales_Amount/(Quantity*Unit_Price))*100, 1) AS diskon_dari_sales
FROM sales_cleaning2
WHERE Discount_Percentage > 30;

UPDATE sales_cleaning2
SET Discount_Percentage = ROUND((1 - Sales_Amount/(Quantity*Unit_Price))*100 / 5) * 5
WHERE Discount_Percentage > 30;

SELECT * FROM sales_cleaning2 WHERE Profit < 0 AND Discount_Percentage <= 10;

SELECT
  SUM(ABS(Sales_Amount - Cost_Amount - Profit) > 0.05)  AS profit_tidak_cocok,
  SUM(Discount_Percentage > 30)                         AS diskon_di_atas_30,
  SUM(Discount_Percentage > 25)                         AS diskon_tinggi,
  SUM(Quantity <= 0)                                    AS qty_nol_minus,
  SUM(Product_Name IS NULL)                             AS produk_null,
  COUNT(*)                                              AS total_baris
FROM sales_cleaning2;

select * from sales_cleaning2;

alter table sales_cleaning2
drop column Row_Numb;

alter table sales_cleaning2
drop column flag_sales_mismatch;

alter table sales_cleaning2
drop column flag_profit_fix;

select count(*) from sales_cleaning2;

SELECT SUM(Customer_Rating IS NULL)                         AS rating_null,
       SUM(Customer_Rating = 0)                             AS rating_nol,
       SUM(Customer_Age IS NULL)                            AS umur_null,
       SUM(Customer_Age = 0)                                AS umur_nol,
       SUM(Delivery_Days = 0 AND Shipping_Method <> 'Pickup') AS kirim_nol_bukan_pickup
FROM sales_cleaning2;

UPDATE sales_cleaning2 SET Customer_Rating = NULL WHERE Customer_Rating = 0;
UPDATE sales_cleaning2 SET Customer_Age    = NULL WHERE Customer_Age = 0;
UPDATE sales_cleaning2 SET Delivery_Days   = NULL WHERE Delivery_Days = 0 AND Shipping_Method <> 'Pickup';

SELECT
    Transaction_ID,Order_ID,Customer_ID,
    NULLIF(TRIM(Customer_Name), '') AS Customer_Name,
    NULLIF(Customer_Age, 0)  AS Customer_Age, 
    Customer_Gender, Customer_Segment,
    CAST(Order_Date AS DATE) AS Order_Date,
    Order_Time, Sales_Channel,
    Store_ID, Store_Name, Country, Region, City,
    Product_ID, Product_Name, Product_Category, Product_Subcategory,
    Quantity, Unit_Price, Discount_Percentage, Sales_Amount, Cost_Amount,
    Profit, Payment_Method,
    Order_Status, Shipping_Method, Delivery_Days, Return_Flag,
    NULLIF(TRIM(Return_Reason), '') AS Return_Reason, Sales_Representative,
    NULLIF(TRIM(Promotion_Code), '') AS Promotion_Code,
    NULLIF(Customer_Rating, 0) AS Customer_Rating,  Inventory_Level, Order_Year,
    CASE WHEN Order_Status = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled,
    CASE WHEN Order_Status = 'Returned'  THEN 1 ELSE 0 END AS is_returned_status,
    CASE WHEN Return_Flag = 'Yes'        THEN 1 ELSE 0 END AS is_returned_flag,
    CASE WHEN Order_Status IN ('Completed','Shipped','Processing')
         THEN 1 ELSE 0 END AS is_revenue_order,
    CASE WHEN ABS(Quantity * Unit_Price * (1 - Discount_Percentage/100.0)
                  - Sales_Amount) > 0.05
         THEN 1 ELSE 0 END AS is_sales_mismatch,
    CASE WHEN Profit < 0 THEN 1 ELSE 0 END AS is_loss
FROM sales_cleaning2;

SELECT
    COUNT(*) AS total_rows,
    SUM(Customer_Rating = 0)  AS rating_kosong,
    SUM(Customer_Age = 0) AS umur_kosong,
    SUM(Order_Status IN ('Completed','Shipped','Processing')) AS baris_pendapatan, 
    ROUND(AVG(NULLIF(Customer_Rating, 0)), 2) AS rata_rating
FROM sales_cleaning2;

SELECT
    COUNT(*) - COUNT(Customer_Rating) AS rating_null,
    COUNT(*) - COUNT(Customer_Age)    AS umur_null
FROM sales_cleaning2;

CREATE TABLE sales_final AS
SELECT
    s.*,
    CASE WHEN Order_Status = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled,
    CASE WHEN Order_Status = 'Returned'  THEN 1 ELSE 0 END AS is_returned_status,
    CASE WHEN Return_Flag = 'Yes'        THEN 1 ELSE 0 END AS is_returned_flag,
    CASE WHEN Order_Status IN ('Completed','Shipped','Processing')
         THEN 1 ELSE 0 END                                  AS is_revenue_order,
    CASE WHEN ABS(Quantity * Unit_Price * (1 - Discount_Percentage/100.0)
                  - Sales_Amount) > 0.05
         THEN 1 ELSE 0 END                                  AS is_sales_mismatch,
    CASE WHEN Profit < 0 THEN 1 ELSE 0 END                  AS is_loss
FROM sales_cleaning2 ;

SELECT
    Transaction_ID,
    Quantity,
    Unit_Price,
    Discount_Percentage,
    Sales_Amount,
    ROUND(Quantity * Unit_Price * (1 - Discount_Percentage/100.0), 2) AS sales_seharusnya,
    ROUND(Sales_Amount - Quantity * Unit_Price * (1 - Discount_Percentage/100.0), 2) AS selisih
FROM sales_final
WHERE is_sales_mismatch = 1
ORDER BY ABS(selisih) DESC;

SELECT SUM(is_sales_mismatch) FROM sales_final;

SELECT
    ROUND(SUM(CASE WHEN is_sales_mismatch = 1 THEN Sales_Amount END), 2) AS sales_mismatch,
    ROUND(SUM(Sales_Amount), 2)                                          AS sales_total,
    ROUND(100 * SUM(CASE WHEN is_sales_mismatch = 1 THEN Sales_Amount END)
          / SUM(Sales_Amount), 2)                                        AS persen
FROM sales_final;