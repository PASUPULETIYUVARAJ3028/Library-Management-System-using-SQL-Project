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
select min(issued_date), max(issued_date) from issued_status;
select '2024-03-10' - '2024-05-30';
select timestampdiff(day,'2024-03-10','2024-05-30');

--  Displaying 10 records of table "return_status"
SELECT DISTINCT * FROM return_status LIMIT 10;