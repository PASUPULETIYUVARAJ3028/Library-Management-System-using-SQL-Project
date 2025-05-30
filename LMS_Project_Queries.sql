-- Library System Management SQL Project

-- create library database
CREATE DATABASE library_db;

-- use the 'library_db'
USE library_db;

-- Create table "Branch"
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "Employee"
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

-- Displaying 10 records of table "Branch"
SELECT * FROM branch LIMIT 10;

--  Displaying 10 records of table "Employee"
SELECT * FROM employees LIMIT 10;

--  Displaying 10 records of table "Members"
SELECT * FROM members LIMIT 10;

--  Displaying 10 records of table "Books"
SELECT * FROM books LIMIT 10;

--  Displaying 10 records of table "IssueStatus"
SELECT * FROM issued_status LIMIT 10;

--  Displaying 10 records of table "return_status"
SELECT * FROM return_status LIMIT 10;


-- PROJECT TASK
-- 1. CRUD Operations

-- Task 1. Insert a new book record in 'books' table

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books WHERE isbn = '978-1-60129-456-2';


-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT * FROM members;
SELECT * FROM issued_status;

SELECT
     iss.issued_member_id,
     m.member_name,
     count(iss.issued_book_name) as 'no_of_issues'

     FROM 
        members as m inner JOIN issued_status as iss 
    ON 
        m.member_id = iss.issued_member_id
    GROUP BY
         m.member_name, iss.issued_member_id
    HAVING
        count(iss.issued_book_name) > 1
    ORDER BY 
        count(iss.issued_book_name) desc;


-- ### 2. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_count
SELECT * FROM books limit 10;
SELECT * FROM issued_status LIMIT 10;

CREATE TABLE book_cnts as (
    
SELECT 
        b.book_title,
        count(iss.issued_book_name) as 'no_of_issue'
    FROM
        books as b inner join issued_status as iss
    ON
        b.isbn = iss.issued_book_isbn 
    GROUP BY
        b.book_title
    ORDER BY
         count(iss.issued_book_name) desc

);

SELECT * FROM book_cnts;


-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All category Books and count of each category books:
SELECT DISTINCT category, count(book_title) AS 'total_count' FROM books
GROUP BY category;


-- Task 8: Find Total Rental Income by Category:
SELECT DISTINCT category, sum(rental_price) AS 'total_count' FROM books
GROUP BY category
ORDER BY sum(rental_price) DESC;


-- Task 9. **List Members Who Registered in the Last 180 Days**:
-- It will retrieve the records who registered last.
SELECT member_name,MAX(reg_date) FROM members GROUP BY member_name ORDER BY MAX(reg_date) DESC;

SELECT * FROM members
WHERE reg_date >= '2024-06-01' - INTERVAL '180' day;


-- Task 10: List Employees details (like em_id,em_name, em_position,em_salary) with Their Branch Manager's Name and their branch details**:

SELECT
    e.emp_id, e.emp_name, e.position, e.salary,
    b.*,
    e2.emp_name as manager
FROM
    employees as e inner join branch as b on e.branch_id = b.branch_id
    JOIN employees as e2 ON e2.emp_id = b.manager_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE expensive_books as (
SELECT * FROM books
WHERE
    rental_price > (select avg(rental_price) from books)
ORDER BY 
    rental_price DESC);

SELECT * FROM expensive_books;
-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT
    iss.issued_book_name as 'Not Returned Books'
FROM
    issued_status as iss inner join return_status as re
    on iss.issued_id = re.issued_id
WHERE 
    re.return_book_name is null
;


-- ### Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;



-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).

DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE());

    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END $$

DELIMITER ;

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135');

-- calling function 
CALL add_return_records('RS148', 'IS140');

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURDATE() - INTERVAL 2 MONTH
);

SELECT * FROM active_members;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, their branch
SELECT DISTINCT position, COUNT(*) FROM employees
GROUP BY position;

WITH top_3_employees AS (
SELECT
    e.emp_name,
    count(*) as 'no_of_books_processed',
    b.branch_id,
    b.manager_id,
    b.branch_address,
    b.contact_no
      
FROM
    employees as e join issued_status as iss
    ON
    e.emp_id = iss.issued_emp_id
    join branch as b
    ON
    b.branch_id = e.branch_id

GROUP BY
    e.emp_name,
    b.branch_id,
    b.manager_id,
    b.branch_address,
    b.contact_no
ORDER BY 
    count(*) DESC
),
top_3_unique_no_of_books_processed as (
SELECT DISTINCT no_of_books_processed FROM top_3_employees LIMIT 3
),
result as (
SELECT * FROM top_3_employees
WHERE no_of_books_processed IN (SELECT * FROM top_3_unique_no_of_books_processed)
)

select * from result
; 

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.    

SELECT
      m.member_name,
     iss.issued_book_name as 'book_title',
     count(*) AS 'issues_count'
FROM
    issued_status as iss
    join members as m  ON  iss.issued_member_id = m.member_id 
GROUP BY 
     m.member_name,
     iss.issued_book_name
ORDER BY
    COUNT(*) DESC;

-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
--    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
--    If a book is issued, the status should change to 'no'.
--    If a book is returned, the status should change to 'yes'.\

DELIMITER $$
CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    -- Declare variable
    DECLARE v_status VARCHAR(10);

    -- Check if the book is available
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        -- Insert into issued_status
        INSERT INTO issued_status(
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURRENT_DATE,
            p_issued_book_isbn,
            p_issued_emp_id
        );

        -- Update the book's status
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Simulate notice (MySQL doesn't support RAISE NOTICE)
        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS message;
    ELSE
        SELECT CONCAT('Sorry, the book is unavailable. ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END $$

DELIMITER ;


-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

-- Task 20: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

/*Description: Write a CTAS query to create a new table that lists each member 
 and the books they have issued but not returned within 30 days. 
 The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/
select min(issued_date), max(issued_date) from issued_status;

CREATE TABLE overdue_books_summary AS
SELECT 
    m.member_id,
    COUNT(CASE 
              WHEN DATEDIFF('2024-05-30', iss.issued_date) > 30 
              THEN 1 
         END) AS overdue_books,
    SUM(CASE 
            WHEN DATEDIFF('2024-05-30', iss.issued_date) > 30 
            THEN (DATEDIFF('2024-05-30', iss.issued_date) - 30) * 0.50
            ELSE 0
        END) AS total_fines,
    COUNT(iss.issued_id) AS total_books_issued
FROM 
    members AS m
    JOIN issued_status AS iss ON m.member_id = iss.issued_member_id
GROUP BY 
    m.member_id
ORDER BY 
    total_fines DESC;

SELECT * FROM overdue_books_summary;






