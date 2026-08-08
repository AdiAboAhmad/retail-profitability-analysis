USE retail_analytics;

-- 1. HOW MANY RECORDS DO WE HAVE IN EACH TABLE?

SELECT
    (SELECT COUNT(*) FROM customers) AS Customers,
    (SELECT COUNT(*) FROM products) AS Products,
    (SELECT COUNT(*) FROM stores) AS Stores,
    (SELECT COUNT(*) FROM transactions) AS Transactions;


-- 2. ARE THERE ANY DUPLICATE TRANSACTION IDS?
SELECT
    TransactionID,
    COUNT(*) AS DuplicateCount
FROM transactions
GROUP BY TransactionID
HAVING COUNT(*) > 1;


-- 3. ARE THERE ANY MISSING VALUES IN THE TRANSACTIONS TABLE?
SELECT
    COUNT(CASE WHEN TransactionID IS NULL THEN 1 END) AS MissingTransactionID,
    COUNT(CASE WHEN Date IS NULL THEN 1 END) AS MissingDate,
    COUNT(CASE WHEN CustomerID IS NULL THEN 1 END) AS MissingCustomerID,
    COUNT(CASE WHEN ProductID IS NULL THEN 1 END) AS MissingProductID,
    COUNT(CASE WHEN StoreID IS NULL THEN 1 END) AS MissingStoreID,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS MissingQuantity,
    COUNT(CASE WHEN Discount IS NULL THEN 1 END) AS MissingDiscount,
    COUNT(CASE WHEN PaymentMethod IS NULL THEN 1 END) AS MissingPaymentMethod
FROM transactions;


-- 4. DOES EVERY TRANSACTION BELONG TO A VALID CUSTOMER?

SELECT COUNT(*) AS InvalidCustomerReferences
FROM transactions t
LEFT JOIN customers c
    ON t.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


-- 5. DOES EVERY TRANSACTION REFER TO A VALID PRODUCT?
SELECT COUNT(*) AS InvalidProductReferences
FROM transactions t
LEFT JOIN products p
    ON t.ProductID = p.ProductID
WHERE p.ProductID IS NULL;


-- 6. DOES EVERY TRANSACTION REFER TO A VALID STORE?

SELECT COUNT(*) AS InvalidStoreReferences
FROM transactions t
LEFT JOIN stores s
    ON t.StoreID = s.StoreID
WHERE s.StoreID IS NULL;



-- 7. WHAT IS THE FINANCIAL PERFORMANCE OF EACH TRANSACTION?

SELECT
    t.TransactionID,
    t.Date,
    t.ProductID,
    t.Quantity,
    t.Discount,
    p.UnitPrice,
    p.CostPrice,

    ROUND(
        t.Quantity * p.UnitPrice * (1 - t.Discount),
        2
    ) AS Revenue,

    ROUND(
        t.Quantity * p.CostPrice,
        2
    ) AS Cost,

    ROUND(
        t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice),
        2
    ) AS Profit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID;


-- 8. HOW IS THE COMPANY PERFORMING OVERALL?

SELECT
    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * p.CostPrice),
        2
    ) AS TotalCost,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice))
        /
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount))
        * 100,
        2
    ) AS ProfitMarginPercent

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID;


-- 9. WHICH PRODUCTS SELL THE MOST UNITS?


SELECT
    p.ProductID,
    p.ProductName,
    SUM(t.Quantity) AS UnitsSold
FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY UnitsSold DESC;


-- 10. WHICH PRODUCTS GENERATE THE MOST REVENUE?

SELECT
    p.ProductID,
    p.ProductName,
    SUM(t.Quantity) AS UnitsSold,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalRevenue DESC;


-- 11. WHICH PRODUCTS GENERATE THE MOST PROFIT?

SELECT
    p.ProductID,
    p.ProductName,

    SUM(t.Quantity) AS UnitsSold,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalProfit DESC;


-- 12. WHICH PRODUCTS HAVE THE HIGHEST AND LOWEST PROFIT MARGINS?

SELECT
    p.ProductID,
    p.ProductName,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice))
        /
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount))
        * 100,
        2
    ) AS ProfitMarginPercent

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY ProfitMarginPercent DESC;


-- 13. WHAT DISCOUNT LEVELS DOES THE COMPANY USE?

SELECT
    Discount,
    COUNT(*) AS NumberOfTransactions
FROM transactions
GROUP BY Discount
ORDER BY Discount;


-- 14. HOW DO DISCOUNTS AFFECT REVENUE AND PROFIT?
-- 

SELECT
    t.Discount,

    COUNT(*) AS NumberOfTransactions,

    SUM(t.Quantity) AS UnitsSold,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice))
        /
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount))
        * 100,
        2
    ) AS ProfitMarginPercent

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY t.Discount
ORDER BY t.Discount;


-- 15. WHICH STORES GENERATE THE MOST REVENUE AND PROFIT?

SELECT
    s.StoreID,
    s.StoreName,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
JOIN stores s
    ON t.StoreID = s.StoreID
GROUP BY
    s.StoreID,
    s.StoreName
ORDER BY TotalProfit DESC;



-- 16. WHICH PRODUCT CATEGORIES GENERATE THE MOST REVENUE AND PROFIT?

SELECT
    p.Category,

    SUM(t.Quantity) AS UnitsSold,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalProfit DESC;


-- 17. HOW DOES FINANCIAL PERFORMANCE CHANGE OVER TIME?

SELECT
    YEAR(t.Date) AS Year,
    MONTH(t.Date) AS Month,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    YEAR(t.Date),
    MONTH(t.Date)
ORDER BY
    YEAR(t.Date),
    MONTH(t.Date);


-- 18. WHO ARE THE COMPANY'S MOST VALUABLE CUSTOMERS?

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,

    COUNT(t.TransactionID) AS NumberOfTransactions,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit

FROM transactions t
JOIN customers c
    ON t.CustomerID = c.CustomerID
JOIN products p
    ON t.ProductID = p.ProductID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalProfit DESC;


-- 19. WHICH PAYMENT METHODS ARE USED MOST OFTEN?
SELECT
    PaymentMethod,
    COUNT(*) AS NumberOfTransactions
FROM transactions
GROUP BY PaymentMethod
ORDER BY NumberOfTransactions DESC;


-- 20. HOW DOES EACH PRODUCT PERFORM AT DIFFERENT DISCOUNT LEVELS?

SELECT
    p.ProductID,
    p.ProductName,
    t.Discount,

    COUNT(*) AS NumberOfTransactions,

    SUM(t.Quantity) AS UnitsSold,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS TotalProfit,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice))
        /
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount))
        * 100,
        2
    ) AS ProfitMarginPercent

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID

GROUP BY
    p.ProductID,
    p.ProductName,
    t.Discount

ORDER BY
    p.ProductID,
    t.Discount;
    
-- 21. DO HIGHER DISCOUNTS INCREASE QUANTITY PER TRANSACTION?

SELECT
    t.Discount,

    COUNT(*) AS NumberOfTransactions,

    SUM(t.Quantity) AS UnitsSold,

    ROUND(AVG(t.Quantity), 2) AS AvgUnitsPerTransaction,

    ROUND(
        AVG(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS AvgRevenuePerTransaction,

    ROUND(
        AVG(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS AvgProfitPerTransaction

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID

GROUP BY t.Discount
ORDER BY t.Discount;

-- 22. HOW DO DISCOUNTS AFFECT EACH PRODUCT CATEGORY?

SELECT
    p.Category,
    t.Discount,

    COUNT(*) AS NumberOfTransactions,

    ROUND(AVG(t.Quantity), 2) AS AvgUnitsPerTransaction,

    ROUND(
        AVG(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS AvgRevenuePerTransaction,

    ROUND(
        AVG(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS AvgProfitPerTransaction,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice))
        /
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount))
        * 100,
        2
    ) AS ProfitMarginPercent

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID

GROUP BY
    p.Category,
    t.Discount

ORDER BY
    p.Category,
    t.Discount;
    
-- 23. HOW MUCH SALES VALUE IS LOST TO DISCOUNTS?

SELECT
    t.Discount,

    COUNT(*) AS NumberOfTransactions,

    ROUND(
        SUM(t.Quantity * p.UnitPrice),
        2
    ) AS RevenueBeforeDiscount,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * (1 - t.Discount)),
        2
    ) AS ActualRevenue,

    ROUND(
        SUM(t.Quantity * p.UnitPrice * t.Discount),
        2
    ) AS DiscountValue,

    ROUND(
        SUM(t.Quantity * ((1 - t.Discount) * p.UnitPrice - p.CostPrice)),
        2
    ) AS ActualProfit

FROM transactions t
JOIN products p
    ON t.ProductID = p.ProductID

GROUP BY t.Discount
ORDER BY t.Discount;