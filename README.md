Project made using pgAdmin 4 and PostgreSQL to create detailed and summary tables using a DVD rental database

This project uses SQL scripts to manage and refresh various database tables used in a film rental system. 
The primary purpose is to maintain up-to-date summary tables based on raw data from the detailed table.

Creates and updates multiple summary tables (`summary1`, `summary2`).
Uses triggers and stored procedures to refresh data automatically when the detailed table is updated.
Includes functionality to reset and refresh all relevant tables for testing purposes.

`detailed`: Contains film rental data with film details and categories.
`summary1`: Provides a summary of the most rented films.
`summary2`: Summarizes the most rented film genres.

Initial Table Creation**: The code creates necessary tables like `detailed`, `summary1`, and `summary2` by joining data from multiple film-related tables (`film`, `film_category`, `category`, `inventory`).
Trigger for Automatic Updates**: A trigger is set up to refresh the summary tables whenever data is inserted into the `detailed` table.
Stored Procedure for Full Refresh**: A stored procedure is included to reset and refresh all tables (`detailed`, `summary1`, `summary2`) with updated data.

To test the functionality

Run the SQL scripts that create the tables and populate them with initial data.
Call the `refresh_detailed_and_summary_tables` procedure to reset and refresh all tables.
Use the `ROLLBACK;` command to undo changes for testing purposes.
