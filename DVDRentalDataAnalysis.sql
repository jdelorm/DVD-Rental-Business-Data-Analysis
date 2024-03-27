--Displays the selected table to the console for testing purposes

--SELECT * FROM summary1;
--SELECT * FROM summary2;
--SELECT * FROM detailed;
--SELECT * FROM category;
--SELECT * FROM inventory;
--SELECT * FROM film;
--SELECT * FROM film_category;
	
--Command used to undo all transactions since transaction began for testing purposes

--ROLLBACK;

--Drops the detailed table if it already exists
DROP TABLE IF EXISTS detailed;

--Creates the detailed table
CREATE TABLE detailed AS
SELECT
    f.film_id,
    f.title,
    fc.category_id,
    c.name AS category_name,
    i.last_update
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
JOIN
    inventory i ON f.film_id = i.film_id;

--Drops the summary1 table if it already exists
DROP TABLE IF EXISTS summary1;

--Creates the summary1 table
CREATE TABLE summary1 AS
SELECT
    COUNT(*) AS times_rented,
    title,
    TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
FROM
    detailed
GROUP BY
    title
ORDER BY
    times_rented DESC
LIMIT 250;

--Drops the summary2 table if it already exists
DROP TABLE IF EXISTS summary2;

--Creates the summary2 table
CREATE TABLE summary2 AS
SELECT
    COUNT(*) AS times_genre_rented,
    category_name,
    TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
FROM
    detailed
GROUP BY
    category_name
ORDER BY
    times_genre_rented DESC
LIMIT 10;

--Create or replace function to refresh the summary tables
CREATE OR REPLACE FUNCTION summary_tables_refresh()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$ 
BEGIN
    --Deletes existing data from the summary tables
    DELETE FROM summary1;
    DELETE FROM summary2;

    --Refreshes summary1 table with new data from the detailed table
    INSERT INTO summary1
    SELECT
        COUNT(*) AS times_rented,
        title,
        TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
    FROM
        detailed
    GROUP BY
        title
    ORDER BY
        times_rented DESC
    LIMIT 250;

    --Refreshes summary2 table with new data from the detailed table
    INSERT INTO summary2
    SELECT
        COUNT(*) AS times_genre_rented,
        category_name,
        TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
    FROM
        detailed
    GROUP BY
        category_name
    ORDER BY
        times_genre_rented DESC
    LIMIT 10;

    RETURN NEW;
END; $$;

--Creates a trigger to execute the summary_tables_refresh function after an 
--insert on detailed table occurs
CREATE TRIGGER summary_tables_refresh_trigger
AFTER INSERT ON detailed
FOR EACH STATEMENT
EXECUTE FUNCTION summary_tables_refresh();

--Create the procedure to refresh the data in the detailed and summary tables
CREATE OR REPLACE PROCEDURE refresh_detailed_and_summary_tables ()
LANGUAGE plpgsql
AS $$
BEGIN
    --Deletes data from the detailed table
    DELETE FROM detailed;

    --Refreshes data in the detailed table with new raw data from the database
    INSERT INTO detailed
    SELECT
        f.film_id,
        f.title,
        fc.category_id,
        c.name AS category_name,
        i.last_update
    FROM
        film f
    JOIN
        film_category fc ON f.film_id = fc.film_id
    JOIN
        category c ON fc.category_id = c.category_id
    JOIN
        inventory i ON f.film_id = i.film_id;

    --Deletes existing data from the summary tables
    DELETE FROM summary1;
    DELETE FROM summary2;

    --Refreshes summary1 table with new data from the detailed table
    INSERT INTO summary1
    SELECT
        COUNT(*) AS times_rented,
        title,
        TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
    FROM
        detailed
    GROUP BY
        title
    ORDER BY
        times_rented DESC
    LIMIT 250;

    --Refreshes summary2 table with new data from the detailed table
    INSERT INTO summary2
    SELECT
        COUNT(*) AS times_genre_rented,
        category_name,
        TO_CHAR(MAX(last_update), 'MM/DD/YYYY') AS last_update
    FROM
        detailed
    GROUP BY
        category_name
    ORDER BY
        times_genre_rented DESC
    LIMIT 10;
END;
$$;


--Used to test the functionality of the stored procedure to delete everything from
--detailed and summary tables and refreshes the data from the raw data pulled
--from the DVD database

--CALL refresh_detailed_and_summary_tables();

--Inserts a new row into the detailed table to verify that the detailed table 
--updates properly and triggers the summary tables to update whenever anything 
--is inserted into the detailed table by adding a duplicate row to the
--detailed table by inputting a film_id and category_id

/*INSERT INTO detailed (film_id, title, category_id, category_name, last_update)
SELECT
    d.film_id,
    f.title,
    d.category_id,
    c.name AS category_name,
    CURRENT_TIMESTAMP AS last_update
FROM
    --Replace (a, b) with the desired film_id and category_id
    (VALUES (1, 15)) AS d(film_id, category_id) 
--Duplicates a row of info into the detailed table to check
--for functionality
JOIN
    film f ON d.film_id = f.film_id
JOIN
    category c ON d.category_id = c.category_id;*/

--Displays the last inserted row into the detailed table
--for testing purposes

--SELECT * FROM detailed ORDER BY last_update DESC;