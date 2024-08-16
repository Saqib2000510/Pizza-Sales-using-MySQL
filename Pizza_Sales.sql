
--
### Basic Queries

**1. Retrieve the total number of orders placed.**

```sql
SELECT COUNT(*) AS total_orders
FROM orders;
```

**2. Calculate the total revenue generated from pizza sales.**

```sql
SELECT SUM(o.quantity * p.price) AS total_revenue
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id;
```

**3. Identify the highest-priced pizza.**

```sql
SELECT name, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;
```

**4. Identify the most common pizza size ordered.**

```sql
SELECT p.size, COUNT(*) AS order_count
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;
```

**5. List the top 5 most ordered pizza types along with their quantities.**

```sql
SELECT p.name, SUM(o.quantity) AS total_quantity
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
GROUP BY p.name
ORDER BY total_quantity DESC
LIMIT 5;
```

---

### Intermediate Queries

**1. Join the necessary tables to find the total quantity of each pizza category ordered.**

```sql
SELECT c.name AS category, SUM(o.quantity) AS total_quantity
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
JOIN pizza_categories c ON p.category_id = c.id
GROUP BY c.name;
```

**2. Determine the distribution of orders by hour of the day.**

```sql
SELECT HOUR(order_time) AS hour, COUNT(*) AS order_count
FROM orders
GROUP BY hour
ORDER BY hour;
```

**3. Join relevant tables to find the category-wise distribution of pizzas.**

```sql
SELECT c.name AS category, p.name AS pizza, SUM(o.quantity) AS total_quantity
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
JOIN pizza_categories c ON p.category_id = c.id
GROUP BY c.name, p.name
ORDER BY c.name, total_quantity DESC;
```

**4. Group the orders by date and calculate the average number of pizzas ordered per day.**

```sql
SELECT order_date, AVG(daily_pizzas) AS avg_pizzas_per_day
FROM (
    SELECT DATE(order_time) AS order_date, SUM(quantity) AS daily_pizzas
    FROM order_items o
    JOIN orders ord ON o.order_id = ord.id
    GROUP BY DATE(order_time)
) AS daily_totals
GROUP BY order_date;
```

**5. Determine the top 3 most ordered pizza types based on revenue.**

```sql
SELECT p.name, SUM(o.quantity * p.price) AS revenue
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 3;
```

---

### Advanced Queries

**1. Calculate the percentage contribution of each pizza type to total revenue.**

```sql
SELECT p.name, 
       (SUM(o.quantity * p.price) / total_revenue.total * 100) AS percentage_contribution
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
JOIN (SELECT SUM(quantity * price) AS total
      FROM order_items
      JOIN pizzas ON order_items.pizza_id = pizzas.id) AS total_revenue
ON 1=1
GROUP BY p.name, total_revenue.total
ORDER BY percentage_contribution DESC;
```

**2. Analyze the cumulative revenue generated over time.**

```sql
SELECT DATE(o.order_time) AS order_date, 
       (SELECT SUM(quantity * price) 
        FROM order_items o2
        JOIN pizzas p2 ON o2.pizza_id = p2.id
        WHERE DATE(o2.order_time) <= DATE(o.order_time)) AS cumulative_revenue
FROM order_items o
JOIN pizzas p ON o.pizza_id = p.id
GROUP BY DATE(o.order_time)
ORDER BY DATE(o.order_time);
```

**3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.**

```sql
SELECT category, pizza, revenue
FROM (
    SELECT c.name AS category, 
           p.name AS pizza, 
           SUM(o.quantity * p.price) AS revenue,
           RANK() OVER (PARTITION BY c.name ORDER BY SUM(o.quantity * p.price) DESC) AS rank
    FROM order_items o
    JOIN pizzas p ON o.pizza_id = p.id
    JOIN pizza_categories c ON p.category_id = c.id
    GROUP BY c.name, p.name
) AS ranked_revenues
WHERE rank <= 3;
```

---

