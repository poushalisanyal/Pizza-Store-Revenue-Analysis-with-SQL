create database pizza;
use pizza;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date_order DATE,
    time_order TIME
);
SELECT 
    *
FROM
    pizzas;
    
    
SELECT 
    *
FROM
    pizza_types;
    
    
SELECT 
    *
FROM
    orders;
    
    
SELECT 
    *
FROM
    order_details;
    
    
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    order_details;
    
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(pizzas.price * order_details.quantity)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
    
-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza l-size ordered.
SELECT 
    pizza_id, COUNT(quantity)
FROM
    order_details
WHERE
    pizza_id LIKE '%l'
GROUP BY pizza_id
ORDER BY pizza_id ASC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    COUNT(quantity), pizza_id
FROM
    order_details
GROUP BY pizza_id
ORDER BY pizza_id ASC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS total
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total DESC;
	
    
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.time_order) AS hours,
    SUM(order_details.quantity) AS quantity
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY hours
ORDER BY quantity DESC;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.date_order, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date_order) AS order_q;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    order_details.quantity * pizzas.price AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    SUM(pizzas.price * order_details.quantity) * 100 / (SELECT 
            SUM(order_details.quantity * pizzas.price)
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

 
-- Analyze the cumulative revenue generated over time.
SELECT  orders.date_order,
	 SUM(pizzas.price*order_details.quantity) AS daily_revenue,
	SUM(SUM(pizzas.price*order_details.quantity)) 
		OVER(ORDER BY orders.date_order) AS cum_revenue
    FROM order_details 
		JOIN 
	orders ON orders.order_id=order_details.order_id
		JOIN pizzas On order_details.pizza_id=pizzas.pizza_id
			GROUP BY orders.date_order
					ORDER BY orders.date_order;
                    
                    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH pizza_revenue AS (
    SELECT
        pizza_types.category, pizza_types.name, 
			SUM(order_details.quantity * pizzas.price) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY pizza_types.category
            ORDER BY sum(order_details.quantity * pizzas.price) DESC) AS rnk
    FROM pizza_types 
		JOIN 
	pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN 
	order_details ON pizzas.pizza_id = order_details.pizza_id
		GROUP BY pizza_types.category, pizza_types.name)
SELECT category.name, revenue FROM pizza_revenue WHERE rnk <= 3 ORDER BY category, revenue DESC;