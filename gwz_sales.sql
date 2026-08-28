-- Günlük ciro (promosyon sonrası net ciro)
-- Kaynak: data-analytics-469406.course14.gwz_sales

SELECT
    date_date,
    ROUND(SUM(turnover), 2) AS daily_turnover,
    SUM(purchase_cost) AS purchase_cost
FROM `data-analytics-469406.course14.gwz_sales`
GROUP BY date_date
ORDER BY date_date