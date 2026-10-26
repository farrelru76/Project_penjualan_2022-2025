CREATE OR REPLACE VIEW v_sales AS
SELECT * FROM sales_cleaning2
WHERE Order_Status NOT IN ('Cancelled','Returned');

SELECT COUNT(*) AS transaksi,
       COUNT(DISTINCT Order_ID) AS orders,
       COUNT(DISTINCT Customer_ID) AS pelanggan,
       ROUND(SUM(Sales_Amount)) AS sales,
       ROUND(SUM(Profit)) AS profit,
       ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct,
       ROUND(SUM(Sales_Amount)/COUNT(DISTINCT Order_ID),2) AS avg_order_value
FROM v_sales;

-- Berapa yang hilang karena batal/retur
SELECT ROUND(SUM(Sales_Amount)) AS sales_kotor,
       ROUND(SUM(CASE WHEN Order_Status IN ('Cancelled','Returned') THEN Sales_Amount END)) AS sales_batal_retur
FROM sales_cleaning2;

-- Per tahun + pertumbuhan YoY
WITH t AS (SELECT Order_Year AS th, SUM(Sales_Amount) AS s, SUM(Profit) AS p FROM v_sales GROUP BY Order_Year)
SELECT th, ROUND(s) AS sales, ROUND(p) AS profit,
       ROUND((s / LAG(s) OVER (ORDER BY th) - 1) * 100, 1) AS yoy_pct
FROM t;

-- Per bulan
SELECT DATE_FORMAT(Order_Date,'%Y-%m') AS bulan, ROUND(SUM(Sales_Amount)) AS sales, ROUND(SUM(Profit)) AS profit
FROM v_sales GROUP BY bulan ORDER BY bulan;

-- Musiman: bulan ke berapa yang paling ramai
SELECT MONTH(Order_Date) AS bulan, ROUND(SUM(Sales_Amount)) AS sales
FROM v_sales GROUP BY 1 ORDER BY 1;

-- Hari dan jam
SELECT WEEKDAY(Order_Date) AS no, DAYNAME(Order_Date) AS hari, COUNT(*) AS transaksi
FROM v_sales GROUP BY no, hari ORDER BY no;

SELECT HOUR(Order_Time) AS jam, COUNT(*) AS transaksi FROM v_sales GROUP BY 1 ORDER BY 1;

SELECT Product_Category, ROUND(SUM(Sales_Amount)) AS sales, ROUND(SUM(Profit)) AS profit,
       ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct, SUM(Quantity) AS unit
FROM v_sales GROUP BY 1 ORDER BY sales DESC;

-- 10 produk dengan profit tertinggi
SELECT Product_Name, Product_Category, ROUND(SUM(Sales_Amount)) AS sales, ROUND(SUM(Profit)) AS profit,
       ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct
FROM v_sales GROUP BY Product_Name, Product_Category ORDER BY profit DESC LIMIT 10;

-- 5 produk dengan margin terendah
SELECT Product_Name, ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct, ROUND(SUM(Sales_Amount)) AS sales
FROM v_sales GROUP BY Product_Name ORDER BY margin_pct ASC LIMIT 5;

SELECT Country, ROUND(SUM(Sales_Amount)) AS sales, ROUND(SUM(Profit)) AS profit,
       ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct
FROM v_sales GROUP BY 1 ORDER BY sales DESC;

SELECT Discount_Percentage AS diskon, COUNT(*) AS transaksi, ROUND(AVG(Quantity),2) AS rata2_qty,
       ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct,
       ROUND(SUM(Profit < 0)/COUNT(*)*100,1) AS pct_transaksi_rugi
FROM v_sales GROUP BY 1 ORDER BY 1;

-- Efektivitas kode promo
SELECT COALESCE(Promotion_Code,'(tanpa promo)') AS promo, COUNT(*) AS transaksi,
       ROUND(AVG(Sales_Amount),1) AS rata2_sales, ROUND(SUM(Profit)/SUM(Sales_Amount)*100,1) AS margin_pct
FROM v_sales GROUP BY 1 ORDER BY margin_pct;

SELECT Product_Category, COUNT(*) AS transaksi, SUM(Order_Status='Returned') AS returnn,
       ROUND(SUM(Order_Status='Returned')/COUNT(*)*100,1) AS return_rate_pct
FROM sales_cleaning2 GROUP BY 1 ORDER BY return_rate_pct DESC;

SELECT Return_Reason, COUNT(*) AS jumlah
FROM sales_cleaning2 WHERE Order_Status='Returned' GROUP BY 1 ORDER BY jumlah DESC;

-- Apakah pengiriman lambat berhubungan dengan retur dan rating?
SELECT Shipping_Method, ROUND(AVG(Delivery_Days),1) AS rata2_hari, ROUND(AVG(Customer_Rating),2) AS rata2_rating,
       ROUND(SUM(Order_Status='Returned')/COUNT(*)*100,1) AS return_rate_pct
FROM sales_cleaning2 GROUP BY 1;

-- 10 pelanggan terbesar
SELECT Customer_ID, MAX(Customer_Name) AS nama, COUNT(DISTINCT Order_ID) AS orders, ROUND(SUM(Sales_Amount)) AS sales
FROM v_sales GROUP BY Customer_ID ORDER BY sales DESC LIMIT 10;

-- Berapa persen pelanggan yang membeli lebih dari sekali
SELECT ROUND(SUM(n > 1)/COUNT(*)*100,1) AS repeat_pct
FROM (SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS n FROM v_sales GROUP BY Customer_ID) x;

-- Per segmen dan kelompok umur
SELECT Customer_Segment, COUNT(DISTINCT Customer_ID) AS pelanggan, ROUND(SUM(Sales_Amount)) AS sales,
       ROUND(SUM(Sales_Amount)/COUNT(DISTINCT Order_ID),1) AS avg_order_value
FROM v_sales GROUP BY 1 ORDER BY sales DESC;

SELECT CASE WHEN Customer_Age IS NULL THEN 'Unknown' WHEN Customer_Age < 25 THEN '<25'
            WHEN Customer_Age < 35 THEN '25-34' WHEN Customer_Age < 45 THEN '35-44'
            WHEN Customer_Age < 55 THEN '45-54' ELSE '55+' END AS umur,
       COUNT(DISTINCT Customer_ID) AS pelanggan, ROUND(SUM(Sales_Amount)) AS sales
FROM v_sales GROUP BY 1 ORDER BY 1;