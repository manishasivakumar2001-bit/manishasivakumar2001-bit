CREATE DATABASE ecommerce_project;
use ecommerce_project;

select count(*)
from website_sessions;

select count(*)
from website_pageviews;

select count(*)
from order_items_refunds;

use ecommerce_project;

select count(*)
from order_item_refunds;

testing for null values;

SELECT *
FROM website_sessions
WHERE utm_source IS NULL
   OR utm_campaign IS NULL
   OR http_referer IS NULL;
   
   SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN utm_source IS NULL THEN 1 ELSE 0 END) AS utm_source_nulls,
SUM(CASE WHEN utm_campaign IS NULL THEN 1 ELSE 0 END) AS utm_campaign_nulls,
SUM(CASE WHEN utm_content IS NULL THEN 1 ELSE 0 END) AS utm_content_nulls,
SUM(CASE WHEN http_referer IS NULL THEN 1 ELSE 0 END) AS http_referer_nulls
FROM website_sessions;

testing for duplicates;

SELECT website_session_id, COUNT(*)
FROM website_sessions
GROUP BY website_session_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_item_id, COUNT(*)
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT website_pageview_id, COUNT(*)
FROM website_pageviews
GROUP BY website_pageview_id
HAVING COUNT(*) > 1;

fixing data types;

DESCRIBE website_sessions;

DESCRIBE orders;

DESCRIBE order_items;

DESCRIBE website_pageviews;

DESCRIBE order_item_refunds;

DESCRIBE products;

select created_at
from website_sessions
limit 10;

standardizing text fields;

select distinct device_type
from website_sessions;

validating relationship between tables;

SELECT COUNT(*) AS invalid_orders
FROM orders o
LEFT JOIN website_sessions ws
ON o.website_session_id = ws.website_session_id
WHERE ws.website_session_id IS NULL;

SELECT COUNT(*) AS invalid_order_items
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS invalid_refunds
FROM order_item_refunds r
LEFT JOIN order_items oi
ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;

SELECT COUNT(*)
FROM order_item_refunds;

SELECT COUNT(DISTINCT order_item_id)
FROM order_item_refunds;

SELECT *
FROM order_item_refunds
LIMIT 10;

DESCRIBE order_items;

DESCRIBE order_item_refunds;

order value category;

SELECT
MIN(price_usd) AS min_order_value,
MAX(price_usd) AS max_order_value,
AVG(price_usd) AS avg_order_value
FROM orders;

SELECT
MIN(items_purchased),
MAX(items_purchased),
AVG(items_purchased)
FROM orders;

session month;

SELECT
website_session_id,
MONTHNAME(STR_TO_DATE(created_at,'%Y-%m-%d %H:%i:%s')) AS session_month
FROM website_sessions
LIMIT 10;

refund flag;

SELECT
order_item_id,
CASE
    WHEN refund_amount_usd > 0 THEN 1
    ELSE 0
END AS refund_flag
FROM order_item_refunds
LIMIT 10;

order value;

SELECT
order_id,
'Standard Order' AS order_value_category
FROM orders
LIMIT 10;

conversion flag;

SELECT
ws.website_session_id,
CASE
    WHEN o.order_id IS NOT NULL THEN 1
    ELSE 0
END AS conversion_flag
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
LIMIT 10;

task 3;
website traffic analysis;

SELECT COUNT(*) AS total_sessions
FROM website_sessions;

SELECT
COALESCE(utm_source,'Direct Traffic') AS traffic_source,
COUNT(*) AS sessions
FROM website_sessions
GROUP BY COALESCE(utm_source,'Direct Traffic')
ORDER BY sessions DESC;

SELECT
device_type,
COUNT(*) AS sessions
FROM website_sessions
GROUP BY device_type
ORDER BY sessions DESC;

SELECT
COALESCE(http_referer,'Direct Traffic') AS referral_source,
COUNT(*) AS sessions
FROM website_sessions
GROUP BY COALESCE(http_referer,'Direct Traffic')
ORDER BY sessions DESC;

sales and order analysis;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
ROUND(SUM(price_usd),2) AS total_revenue
FROM orders;

SELECT
ROUND(AVG(price_usd),2) AS avg_order_value
FROM orders;

SELECT
p.product_name,
ROUND(SUM(oi.price_usd),2) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

select *
from products;

SELECT
product_id,
COUNT(*) AS total_sales
FROM order_items
GROUP BY product_id;

SELECT COUNT(*) AS total_order_items
FROM order_items;

conversion analysis;

SELECT
    COALESCE(ws.utm_source,'Direct Traffic') AS traffic_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source,'Direct Traffic')
ORDER BY conversion_rate DESC;

SELECT
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY conversion_rate DESC;

SELECT
    DATE_FORMAT(
        STR_TO_DATE(ws.created_at,'%Y-%m-%d %H:%i:%s'),
        '%Y-%m'
    ) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY month
ORDER BY month;

SELECT
    COALESCE(utm_campaign,'No Campaign') AS campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(utm_campaign,'No Campaign')
ORDER BY conversion_rate DESC;

product performance analysis;

SELECT
    p.product_name,
    COUNT(oi.order_item_id) AS total_sales
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

SELECT
    p.product_name,
    COUNT(DISTINCT r.order_item_refund_id) AS refunds,
    COUNT(DISTINCT oi.order_item_id) AS total_sales,
    ROUND(
        COUNT(DISTINCT r.order_item_refund_id) * 100.0 /
        COUNT(DISTINCT oi.order_item_id),
        2
    ) AS refund_rate
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN order_item_refunds r
    ON oi.order_item_id = r.order_item_id
GROUP BY p.product_name
ORDER BY refund_rate DESC;

SELECT
    ROUND(SUM(refund_amount_usd),2) AS revenue_lost
FROM order_item_refunds;

SELECT
    p.product_name,
    COUNT(DISTINCT oi.order_item_id) AS sales
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY sales DESC;

segment 5;
customer and website behaviour;

SELECT
    pageview_url,
    COUNT(*) AS visits
FROM website_pageviews
GROUP BY pageview_url
ORDER BY visits DESC;

SELECT
    wp.pageview_url AS landing_page,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    ROUND(
        (COUNT(DISTINCT ws.website_session_id) * 100.0) /
        (SELECT COUNT(*) FROM website_sessions),
        2
    ) AS bounce_rate
FROM website_sessions ws
JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
GROUP BY wp.pageview_url
ORDER BY bounce_rate DESC;

SELECT
    DATE_FORMAT(created_at,'%Y-%m') AS month,
    COUNT(*) AS sessions
FROM website_sessions
GROUP BY month
ORDER BY month;

SELECT
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)*100.0/
        COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY conversion_rate DESC;

segment 6; 

SELECT
    order_id,
    price_usd,
    CASE
        WHEN price_usd >= 50 THEN 'High Value'
        WHEN price_usd >= 30 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category
FROM orders;

SELECT
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY conversion_rate DESC;

SELECT
    COALESCE(ws.utm_source,'Direct Traffic') AS traffic_source,
    ROUND(SUM(o.price_usd),2) AS revenue
FROM website_sessions ws
JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source,'Direct Traffic')
ORDER BY revenue DESC;

SELECT
    p.product_name,
    COUNT(r.order_item_refund_id) AS refunds
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds r
    ON oi.order_item_id = r.order_item_id
GROUP BY p.product_name
ORDER BY refunds DESC;

SELECT
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS visits,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        COUNT(DISTINCT wp.website_session_id),
        2
    ) AS conversion_rate
FROM website_pageviews wp
LEFT JOIN orders o
    ON wp.website_session_id = o.website_session_id
GROUP BY wp.pageview_url
ORDER BY visits DESC;

task 4;

SELECT
    ws.website_session_id,
    ws.created_at,
    ws.user_id,
    ws.utm_source,
    ws.device_type,
    o.order_id,
    o.price_usd
FROM website_sessions ws
JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source IN ('gsearch', 'bsearch')
    AND ws.device_type IN ('desktop', 'mobile')
    AND o.price_usd >= 49.99
ORDER BY ws.created_at DESC;

SELECT
    ws.website_session_id,
    ws.created_at,
    ws.user_id,
    ws.utm_source,
    ws.device_type,
    o.order_id,
    o.price_usd
FROM website_sessions ws
JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE YEAR(ws.created_at) IN (2014, 2015)
    AND ws.utm_source IN ('gsearch', 'bsearch')
    AND ws.device_type IN ('desktop', 'mobile')
    AND o.price_usd >= 49.99
ORDER BY ws.created_at DESC;


SELECT
    YEAR(created_at) AS year,
    COUNT(*) AS session_count
FROM website_sessions
GROUP BY YEAR(created_at)
ORDER BY year;