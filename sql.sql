


CREATE TABLE procurement (
    PO_ID VARCHAR(20),
    Supplier VARCHAR(100),
    Order_Date DATE,
    Delivery_Date DATE,
    Item_Category VARCHAR(50),
    Order_Status VARCHAR(30),
    Quantity INT,
    Unit_Price FLOAT,
    Negotiated_Price FLOAT,
    Defective_Units FLOAT,
    Compliance VARCHAR(10),
    Price_Gap_Pct FLOAT,
    Invoice_Number VARCHAR(20),
    Payment_Date DATE,
    is_fraud INT
);

SELECT COUNT(*) FROM procurement;

select *from procurement;


--SQL Fraud Detection Queries

-- Query 1: Duplicate Invoice Detection

SELECT 
    invoice_number, 
    COUNT(*) AS duplicate_count,
    STRING_AGG(po_id, ', ') AS related_pos
FROM procurement
GROUP BY invoice_number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Query 2: Price Volatility / Price Manipulation Detection
SELECT 
    po_id,
    supplier,
    item_category,
    unit_price,
    negotiated_price,
    price_gap_pct,
    is_fraud
FROM procurement
WHERE price_gap_pct > 30
ORDER BY price_gap_pct DESC;

-- Query 3: Unusual Payment Detection
SELECT 
    po_id,
    supplier,
    order_date,
    payment_date,
    (payment_date - order_date) AS days_to_payment,
    is_fraud
FROM procurement
WHERE (payment_date - order_date) < 5 
   OR (payment_date - order_date) > 80
ORDER BY days_to_payment DESC;



-- Query 4: Supplier Risk Aggregation
SELECT 
    supplier,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS flagged_transactions,
    ROUND(AVG(price_gap_pct)::numeric, 2) AS avg_price_gap_pct,
    ROUND((SUM(is_fraud) * 100.0 / COUNT(*))::numeric, 2) AS fraud_rate_pct,
    SUM(CASE WHEN compliance = 'No' THEN 1 ELSE 0 END) AS non_compliant_count
FROM procurement
GROUP BY supplier
HAVING SUM(is_fraud) > 0
ORDER BY fraud_rate_pct DESC, flagged_transactions DESC;



-- Query 4: Supplier Risk Aggregation
SELECT 
    supplier,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS flagged_transactions,
    AVG(price_gap_pct) AS avg_price_gap_pct
FROM procurement
GROUP BY supplier
HAVING SUM(is_fraud) > 0
ORDER BY flagged_transactions DESC;





-- Query 5: Fraud by Item Category
SELECT 
    item_category,
    COUNT(*) AS total_orders,
    SUM(is_fraud) AS fraud_orders
FROM procurement
GROUP BY item_category
ORDER BY fraud_orders DESC;





-- Query 6: Compliance vs Fraud Relationship
SELECT 
    compliance,
    COUNT(*) AS total_orders,
    SUM(is_fraud) AS fraud_orders
FROM procurement
GROUP BY compliance;





-- Query 7: Overall Fraud Summary
SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud_cases,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_percentage
FROM procurement;