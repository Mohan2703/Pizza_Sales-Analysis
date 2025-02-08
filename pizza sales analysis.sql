USE pizzahut;

CREATE TABLE orders (
    order_id INT PRIMARY KEY NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

				-- ANALYSIS -- 

-- 1. Total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM orders; 

-- 2. Total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- 3. Top 5 Highest Priced Pizza.
SELECT 
    pizza_id, price, pizza_types.name
FROM pizzas
		JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 5;
 
-- 4. Most Common Pizza Size Ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. Top 5 Most Ordered Pizza Types Along With Their Quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS order_type_count
FROM pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_type_count DESC LIMIT 5;

						-- INTERMEDIATE --
-- 6. Total Quantity Of Each Pizza Category Ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS type_quantity_order
FROM pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY type_quantity_order DESC;

-- 7. Distribution Of Orders By Hour Of The Day.
SELECT 
    HOUR(order_time) AS time, COUNT(order_id) AS order_count
FROM orders 
GROUP BY time;

-- 8.  Category Wise Distribution Of Pizzas.
SELECT 
    category, COUNT(name)
FROM pizza_types
GROUP BY category; 

-- 9. Grouping Of Orders By Date And Calculating Average Number Of Pizzas Ordered Per Day.
SELECT 
    ROUND(AVG(quant), 0) AS avg_orders_perday
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quant
    FROM orders
	JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity; 

-- 10. Top 5 Most Ordered Pizza Based On Revenue.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS revenue,
    pizza_types.name
FROM order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC LIMIT 5;

						-- ADVANCED --
-- 11. Percentage Contribution Of Each Pizza Type To Total Revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
				ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue
			FROM order_details
			JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2) AS percentage
FROM pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY percentage DESC;
    
-- 12. Analysis Of Cumulative Revenue Generated Over Time.
SELECT 
	order_date, revenue,
	ROUND(SUM(revenue) OVER(ORDER BY order_date),2) AS cumulative_revenue
FROM
	(SELECT 
		orders.order_date,
		ROUND(SUM(order_details.quantity*pizzas.price),2) AS revenue
	FROM order_details 
	JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
	JOIN orders ON orders.order_id = order_details.order_id
	GROUP BY orders.order_date) AS sales;

-- 13. Top 3 Most Ordered pizza Types Based On Revenue For Each pizza Category.
SELECT 
    category, name, revenue
FROM 
	(SELECT 
		category, name, revenue,
		RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
	FROM
		(SELECT 
			pizza_types.category, pizza_types.name,
			SUM(order_details.quantity*pizzas.price) AS revenue
		FROM pizza_types 
		JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
		GROUP BY pizza_types.category, pizza_types.name) 
	AS revenue_data) 
AS ranked_pizzas
WHERE rn <= 3;
