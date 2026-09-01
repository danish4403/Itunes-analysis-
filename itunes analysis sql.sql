-- ============================================
-- SQL Project: iTunes Music Store Analysis
-- All Questions Combined into One Script
-- ============================================

-- Q1. Who is the senior-most employee based on job title?
SELECT 
    first_name, 
    last_name, 
    title
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2. Which countries have the most invoices?
SELECT 
    billing_country,
    COUNT(invoice_id) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

-- Q3. What are the top 3 values of total invoice amounts?
SELECT 
    invoice_id,
    total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4. Which city has the best customers?
-- Return the city with the highest total invoice amount.
SELECT 
    billing_city,
    SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

-- Q5. Who is the best customer?
-- Return the customer who spent the most money.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- Q6. Write a query to return the email, first name, last name & Genre of all Rock music listeners.
SELECT DISTINCT 
    c.email,
    c.first_name,
    c.last_name,
    g.name AS genre
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- Q7. Let's invite the artists who have written the most Rock music.
SELECT 
    a.artist_id,
    a.name AS artist_name,
    COUNT(t.track_id) AS total_songs
FROM artist a
JOIN album al 
    ON a.artist_id = al.artist_id
JOIN track t 
    ON al.album_id = t.album_id
JOIN genre g 
    ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_songs DESC;

-- Q8. Return all track names that have a song length longer than the average.
SELECT 
    name,
    milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC;

-- Q9. Find how much amount spent by each customer on artists.
SELECT 
    c.first_name,
    c.last_name,
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN album al 
    ON t.album_id = al.album_id
JOIN artist a 
    ON al.artist_id = a.artist_id
GROUP BY c.customer_id, a.artist_id, c.first_name, c.last_name, a.name
ORDER BY total_spent DESC;

-- Q10. Find the most popular music Genre for each country.
SELECT 
    country,
    genre_name,
    total_purchases
FROM (
    SELECT 
        c.country,
        g.name AS genre_name,
        COUNT(il.invoice_line_id) AS total_purchases,
        RANK() OVER (PARTITION BY c.country ORDER BY COUNT(il.invoice_line_id) DESC) AS rnk
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
    JOIN track t 
        ON il.track_id = t.track_id
    JOIN genre g 
        ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
) ranked
WHERE rnk = 1
ORDER BY country;

-- Q11. Find the top customer who spent the most on music in each country.
SELECT 
    country,
    first_name,
    last_name,
    total_spent
FROM (
    SELECT 
        c.country,
        c.first_name,
        c.last_name,
        SUM(i.total) AS total_spent,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS rnk
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
) ranked
WHERE rnk = 1
ORDER BY country;

-- Q12. Who are the most popular artists?
SELECT 
    a.artist_id,
    a.name AS artist_name,
    COUNT(il.invoice_line_id) AS total_purchases
FROM artist a
JOIN album al 
    ON a.artist_id = al.artist_id
JOIN track t 
    ON al.album_id = t.album_id
JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY a.artist_id, a.name
ORDER BY total_purchases DESC;

-- Q13. Which is the most popular song?
SELECT 
    t.name AS track_name,
    COUNT(il.invoice_line_id) AS total_purchases
FROM track t
JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY total_purchases DESC
LIMIT 1;

-- Q14. What are the average prices of different types of music?
SELECT 
    g.name AS genre_name,
    ROUND(AVG(il.unit_price), 2) AS avg_price
FROM genre g
JOIN track t 
    ON g.genre_id = t.genre_id
JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY avg_price DESC;

-- Q15. What are the most popular countries for music purchases?
SELECT 
    c.country,
    COUNT(i.invoice_id) AS total_purchases,
    ROUND(SUM(i.total), 2) AS total_spent,
    RANK() OVER (ORDER BY COUNT(i.invoice_id) DESC) AS purchase_rank,
    RANK() OVER (ORDER BY SUM(i.total) DESC) AS spending_rank
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_purchases DESC, total_spent DESC;
