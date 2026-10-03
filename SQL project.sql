--Due: 05/22
--Presentation: 05/23
-- Group 5 members 
 -- Asechalew Amera
 -- Fikire Tsion
 -- Helen Getahun
 -- Rediet Merid
 -- Seyfan Shukri
 -- Yohannes Haile
 
--Capstone Project — DVD Rental Database
--Section 1: DDL and DML (Scenario-Based)
--Scenario 1: A new customer walks into the store to rent a movie. 
-- You need to capture all the necessary information.

--1. Write the DDL to create a new temporary table called new_customer with appropriate 
-- fields (first_name, last_name, email, address_id, active, etc.).

 CREATE TEMPORARY TABLE new_customer
  ( store_id INT,
  first_name VARCHAR (45),
  last_name VARCHAR (45),
  email VARCHAR (50),
  address_id INT,
  activebool Boolean,
  active INT);

  SELECT *
  FROM new_customer
  
-- 2. Insert a record for the new customer into the new_customer table.

 INSERT INTO new_customer(store_id,first_name,last_name,email,address_id,activebool, active)
 VALUES (001,'Smith','Jhon','smithjhon@gmail.com',340,'true',1);
 
-- 3. Insert the customer into the main customer table based on the record in new_customer.

INSERT INTO customer (store_id,first_name,last_name,email,address_id,activebool,active)
SELECT store_id,first_name,last_name,email,address_id,activebool,active
FROM new_customer

 SELECT *
 FROM customer 
 WHERE address_id = 340

-- 4. Simulate a new rental:
-- Insert a new record into the rental table for this customer, including rental date, inventory_id (assume it's available), 
-- and staff_id.
SELECT *
FROM rental
WHERE customer_id=604

INSERT INTO rental (rental_date,inventory_id,customer_id,return_date,staff_id)
VALUES (CURRENT_TIMESTAMP,345,604,null,1)

-- 5. Insert a corresponding payment record into the payment table for this rental, recording the amount and payment date.
SELECT *
FROM payment

INSERT INTO payment (customer_id,staff_id,rental_id,amount,payment_date)
VALUES (604,1,16050,7.99,CURRENT_TIMESTAMP)

-- Scenario 2: A new film is released and needs to be added to the system.
-- 6. Create a temporary table new_film with fields such as title, description, release_year, language_id, rental_duration,
--rental_rate, length, replacement_cost, and rating.

SELECT *
FROM film

CREATE TEMPORARY TABLE new_film
(title VARCHAR (255),
 description text,
 release_year year,
 language_id INT,
 rental_duration INT,
 rental_rate decimal,
 replacement_cost decimal, 
 rating mpaa_rating)
 
-- 7. Insert a record for the new film into new_film table.

 INSERT INTO new_film (title,description,release_year,language_id ,rental_duration ,rental_rate ,replacement_cost,rating)
 VALUES ('DUNE PART 3', 
 'Emperor Paul Atreides faces the fallout from his ascent to power as political plots and a galaxy-wide holy war endanger the future only he can see',
 2026,1,5,15.99,10,'PG-13');

 SELECT *
 FROM new_film
 
-- 8. Insert the new film into the main film table using the data from new_film.

INSERT INTO film (title,description,release_year,language_id ,rental_duration ,rental_rate ,replacement_cost,rating)
 VALUES ('DUNE PART 3', 
 'Emperor Paul Atreides faces the fallout from his ascent to power as political plots and a galaxy-wide holy war endanger the future only he can see',
 2026,1,5,15.99,10,'PG-13');

 SELECT *
 FROM film
 WHERE release_year= 2026

-- 9. Add inventory: insert 3 available copies of this new film into the inventory table, assigning them to different store
--locations.


INSERT INTO inventory (film_id,store_id)
VALUES 
       (1001,1),
       (1001,1),
	   (1001,2);	   

SELECT *
FROM inventory
WHERE film_id=1001


--Section 2: DQL — Data Query Language (SELECT, WHERE, Aggregates, GROUP BY, HAVING, ORDER BY, JOINS, Subqueries)
--General Analysis

--8. List the top 10 longest movies along with their length and title.

SELECT title,length
FROM film
ORDER BY length DESC
LIMIT 10;

--9. Find all customers who have rented more than 10 movies.

SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) AS full_name,COUNT(r.rental_id) AS total_rental
From customer c
JOIN rental r ON c.customer_id = r.customer_id
Group by c.customer_id, c.first_name,c.last_name
HAVING count(r.rental_id)> 10
ORDER BY total_rental 

--10. Get the average rental rate for each movie rating (G, PG, R, etc.).

SELECT rating,AVG(rental_rate) AS total_avgrental
FROM film 
GROUP BY rating

--11. Find the top 5 cities with the most customers.

Select ci.city_id, ci.city, COUNT(c.customer_id)AS most_customer
From city ci
JOIN address a on ci.city_id=a.city_id
JOIN customer c on a.address_id=c.address_id
GROUP BY ci.city_id
ORDER BY most_customer DESC
LIMIT 5

--12. Show the total revenue (payment amount) collected by each staff member.

SELECT s.first_name, s.last_name, s.staff_id, SUM (p.amount) AS total_revenue
FROM payment p
JOIN staff s ON p.staff_id=s.staff_id
GROUP BY s.staff_id

--13. Retrieve the 10 most rented films along with how many times each was rented.

SELECT f.film_id,f.title, COUNT(r.rental_id) AS rented
From film f
JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY rented DESC
LIMIT 10 

--14. Find the customer who has spent the most in total payments.

SELECT c.first_name, c.last_name,c.customer_id, SUM (p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id=p.customer_id
GROUP BY c.customer_id
ORDER BY total_payment DESC

--15. List all movies that have never been rented.

SELECT f.title,f.film_id, r.rental_id
FROM film f
LEFT JOIN inventory i ON f.film_id=i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL

-- OR

SELECT f.title, f.film_id
FROM film f
LEFT JOIN inventory i ON f.film_id=i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
Group by f.title, f.film_id

--DQL Case Study Questions
--Case Study 1: Customer Behavior Analysis
--A marketing team wants to identify loyal customers to send special discount offers.
--Write a query to find customers who rented more than 20 movies and spent more than $100 in total.
--Return their full name, email, total rentals, and total amount paid.
--Sort the results by the total amount spent, highest first.

SELECT CONCAT(c.first_name,' ',c.last_name) AS full_name, c.customer_id, c.email, COUNT(r.rental_id) AS rental_count,SUM(p.amount) AS total_payment
FROM customer c 
JOIN rental r ON c.customer_id=r.customer_id
JOIN payment p ON r.rental_id=p.rental_id
Group by c.customer_id
Having  COUNT(r.rental_id) > 20 AND 
        SUM(p.amount) > 100
Order by total_payment DESC;

--Case Study 2: Film Performance Review
--The store manager wants to know which movies are underperforming and might be removed from inventory.
--Find all films that have been rented fewer than 5 times.
SELECT f.title,f.film_id,COUNT(r.rental_id)AS rental_count
FROM film f
LEFT JOIN inventory i ON f.film_id=i.film_id
LEFT JOIN rental r ON i.inventory_id=r.inventory_id
GROUP BY f.film_id
HAVING COUNT(r.rental_id) < 5
ORDER BY rental_count ASC

--Return the film title, rental count, and average rental rate for each.
SELECT f.title,f.film_id,COUNT(r.rental_id)AS rental_count, AVG(f.rental_rate) AS AVG_rentalRate
FROM film f
LEFT JOIN inventory i ON f.film_id=i.film_id
LEFT JOIN rental r ON i.inventory_id=r.inventory_id
GROUP BY f.film_id
HAVING COUNT(r.rental_id) < 5
ORDER BY rental_count ASC
--Sort the result by rental count, lowest first, and limit to 20 films.
SELECT f.title,f.film_id,COUNT(r.rental_id)AS rental_count, AVG(f.rental_rate) AS AVG_rentalRate
FROM film f
LEFT JOIN inventory i ON f.film_id=i.film_id
LEFT JOIN rental r ON i.inventory_id=r.inventory_id
GROUP BY f.film_id
HAVING COUNT(r.rental_id) < 5
ORDER by rental_count ASC
LIMIT 20

