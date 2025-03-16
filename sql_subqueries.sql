# Challenge
# Write SQL queries to perform the following tasks using the Sakila database:

# 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT * FROM film
WHERE title LIKE "Hunchback Impossible"; -- film id 439 -Y film_id in subquerie

SELECT 
    COUNT(*) AS number_of_copies
FROM inventory
WHERE film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
	);

# 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT 
    title,
    length,
    (SELECT AVG(length) FROM film) AS avg_length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

# 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT * FROM film
WHERE title LIKE "Alone Trip"; -- film id 17

SELECT
	a.actor_id,
    a.first_name,
	a.last_name
FROM actor AS a
WHERE actor_id IN(
SELECT fa.actor_id
FROM film_actor AS fa
WHERE fa.film_id = (
		SELECT film_id 
        FROM film AS f
		WHERE title  = "Alone Trip")
);

# Bonus:
# 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

# checking the tables
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM category; 	-- name Family, category_id = 8

SELECT 
		film_id,
        title,
        description        
FROM film
WHERE film_id IN (
		SELECT film_id
        FROM film_category
        WHERE category_id = 8
		)
ORDER BY title;

# 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT * FROM country; 		-- country , country_id (for Canada 20)
SELECT * FROM customer; 	-- first_name, last_name, email // address_id
SELECT * FROM address;		-- address_id, city_id
SELECT * FROM city;			-- city_id, country_id

## ohne subquerie
SELECT 
		c.first_name,
        c.last_name, 
        c.email
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city AS t ON a.city_id = t.city_id
JOIN country AS y ON t.country_id = y.country_id
WHERE y.country_id = 20;

## mit subquerie     
    SELECT 
    c.first_name,
    c.last_name,
    c.email
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
WHERE a.city_id IN (
    SELECT city_id
    FROM city
    WHERE country_id = 20
);


## mit Canada als Output im table
SELECT 
		c.first_name,
        c.last_name, 
        c.email,
		y.country AS country_name
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city AS t ON a.city_id = t.city_id
JOIN country AS y ON t.country_id = y.country_id
WHERE y.country_id = (
    SELECT country_id
    FROM country
    WHERE country = 'Canada'
);


# 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
# First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

-- step 1 to full solution -> actor id 107 // 42 films
SELECT 
		actor_id,
		COUNT(film_id) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

-- step 2 to full solution -> list film title 
SELECT f.title 
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = 107;

-- full solution step 1 + step 2
SELECT 
    f.title
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

# 7. Find the films rented by the most profitable customer in the Sakila database. 
# You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

-- step 1 to full solution // ( will be the subquerie in the solution) -> most profitable customer // customer_id 526 
SELECT 
		customer_id,
		SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 1;

-- solution - with rental & inventory - to find the films according to customer_id 526 -> output - Film title/list
SELECT 
		f.title,
        customer_id
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
WHERE r.customer_id = (
	SELECT customer_id
	FROM payment
	GROUP BY customer_id
	ORDER BY SUM(amount) DESC
    LIMIT 1
	);
    
# 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

-- step 1, all clients spent with the avg per client spent
SELECT 
    customer_id AS client_id,
    ROUND(SUM(amount), 2) AS total_amount_spent,
    (SELECT ROUND(AVG(total_amount), 2)
     FROM (
         SELECT 
             customer_id,
             SUM(amount) AS total_amount
         FROM payment
         GROUP BY customer_id
     ) AS sub_avg) AS avg_amount_spent
FROM payment
GROUP BY customer_id
ORDER BY total_amount_spent DESC;

-- step 2 adding total amount is greater avg amount
SELECT
	customer_id AS client_id,
	SUM(amount) AS total_amount_spent,
	(
    SELECT ROUND(AVG(total_amount), 2)
	FROM (
		SELECT 
            customer_id,
			SUM(amount) AS total_amount
         FROM payment
         GROUP BY customer_id
     ) AS sub_avg) AS avg_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
		SELECT ROUND(AVG(total_amount), 2)
        FROM (
			SELECT
			customer_id,
			SUM(amount) AS total_amount
			FROM payment
			GROUP BY customer_id
        ) AS sub_avg
)
ORDER BY total_amount_spent DESC;
    
    
