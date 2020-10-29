use classicmodels;

/* Query 1 : Find products containing the name 'Ford'.*/ 

select productName from products where lower(productName) like '%ford%';

/* Query 2 : List products ending in 'ship'.*/ 

select productName from products where lower(productName) like '%ship';

/* Query 3 : Report the number of customers in Denmark, Norway, and Sweden.*/

select country, count(customerName) from customers where country in ('Denmark','Norway','Sweden')
group by country;

/* Query 4 : What are the products with a product code in the range S700_1000 to S700_1499?*/

select productName, productCode from products where productCode between 'S700_1000' and 'S700_1499';

/* Query 5 : Which customers have a digit in their name?*/

select customerName from customers where customerName rlike '[0-9]';

/* Query 6 : List the names of employees called Dianne or Diane.*/

select concat(firstName,lastName) as `Employee Name` from employees
where lower(concat(firstName,lastName)) like '%dianne%' or
lower(concat(firstName,lastName)) like '%diane%';

/* Query 7 : List the products containing ship or boat in their product name.*/

select productName from products where lower(productName) like '%ship%' or 
lower(productName) like '%boat%';

/* Query 8 : List the products with a product code beginning with S700.*/

select productName, productCode from products where productCode like 'S700%';

/* Query 9 : List the names of employees called Larry or Barry.*/

select concat(firstName, lastName) as `Employee Name` from employees
where lower(concat(firstName, lastName)) like '%larry%' or 
lower(concat(firstName, lastName)) like '%barry%';

/* Query 10 : List the names of employees with non-alphabetic characters in their names.*/

select concat(firstName, lastName) as `Employee Name` from employees 
where concat(firstName, lastName) rlike '[0-9][%@]';

/* Query 11 : List the vendors whose name ends in Diecast*/ 

select productVendor from products where lower(productVendor) like '%diecast';