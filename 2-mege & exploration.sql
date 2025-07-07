SELECT * FROM sellers

SELECT * FROM order_payments

SELECT * FROM orders

SELECT * FROM order_reviews

SELECT * FROM products

SELECT * FROM order_items


-- needed data

SELECT 
    o.order_id, 
    o.order_purchase_timestamp, 
    o.order_status, 
    op.payment_value, 
    op.payment_type, 
    oi.price, 
    oi.freight_value
FROM orders o
LEFT JOIN order_payments op ON o.order_id = op.order_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id;

---------------------------------------------------------------
-- Total Revenue (Delivered Orders)
SELECT 
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Total Revenue = 15419773.75
--------------------------------------------------
-- Expected Revenue
SELECT 
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'approved';
-- Total approved = 241.08
-----------------------------------------------------
-- Canceled orders
SELECT 
    COUNT(*) AS canceled_orders
FROM orders
WHERE order_status = 'canceled';

-- Total canceled order = 625 orders
------------------------------------------------------
--late delivered order
SELECT 
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- Total lated deliveres = 7827 orders
------------------------------------------------------

--caculate the payment accuracy
SELECT 
    o.order_id, 
    SUM(op.payment_value) AS total_paid, 
    SUM(oi.price + oi.freight_value) AS total_expected, 
    (SUM(op.payment_value) - SUM(oi.price + oi.freight_value)) AS difference
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING SUM(op.payment_value) <> SUM(oi.price + oi.freight_value);
------------------------------------------------------------------------
--save our data to future preprocessing 
CREATE TABLE FinalData (
    order_id NVARCHAR(50), 
    order_purchase_timestamp DATETIME,
    order_status NVARCHAR(50),
    payment_value DECIMAL(10,2),
    payment_type NVARCHAR(50),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
	estimated_date DATE,
	delivered_date Date,
	late_delivary SmallInt );

INSERT INTO FinalData 
SELECT 
    o.order_id, 
    CAST(o.order_purchase_timestamp AS DATE) AS order_date, 
    o.order_status, 
    op.payment_value, 
    op.payment_type, 
    oi.price, 
    oi.freight_value,
    o.order_estimated_delivery_date estimated_date,
	o.order_delivered_customer_date delivered_date,
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS late_delivery
FROM orders o
LEFT JOIN order_payments op ON o.order_id = op.order_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id;

--save our d

SELECT* FROM FinalData 
drop table  FinalData