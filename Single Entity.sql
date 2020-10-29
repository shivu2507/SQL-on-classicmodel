use classicmodels;

/* Query 1 : Prepare a list of offices sorted by country, state, city.*/

select officeCode,  country, state, city, territory
from offices 
order by country, state , city;

/* Query 2 : How many employees are there in the company?*/

select count(distinct employeeNumber) as `Total employee count` from employees;

/* Query 3 : What is the total payment recieved?*/

select sum(amount) as `Total payment recieved` from payments;

/* Query 4 : List the product lines that contain 'Cars'.*/

select distinct productLine from products where productLine Like '%cars%';

/* Query 5 : Report total payments for October 28, 2004.*/

select sum(amount) as `Total payments for 28th Oct 2004` from payments 
where paymentDate = '2004-10-28';

/* Query 6 : Report those payments greater than $100,000*/

select customerNumber, amount from payments
where amount > '100000';

/* Query 7 : List the products in each product line.*/

select distinct productLine, productName from products
order by productLine, productName; 

/* Query 8 : How many products in each product line?*/

select productLine, count(*) as `Product Count` from products
group by productLine order by `Product Count` desc;

/* Query 9 : What is the minimum payment received?*/

select min(amount) as `Minimum Payment Received` from payments;

/* Query 10 : List all payments greater than twice the average payment.*/

select * from payments where amount > (select (2 * avg(amount)) from payments)
order by amount desc;

/* Query 11 : What is the average percentage markup of the MSRP on buyPrice?*/

select avg(((MSRP - buyprice)/buyprice)*100) as `Avg % Markup of MSRP on buyprice` from products;

/* Query 12 : How many distinct products does ClassicModels sell?*/

select count(distinct productName) as `Distinct Product Counts` from products;

/* Query 13 : Report the name and city of customers who don't have sales representatives?*/

select customerName, city from customers where salesRepEmployeeNumber is null;

/* Query 14 : What are the names of executives with VP or Manager in their title?*/

select concat(firstName, lastName), jobTitle as `Employee Name` from employees
where jobTitle Like '%VP%' or jobTitle Like '%Manager%';

/* Query 15 : Which orders have a value greater than $5,000?*/

select orderNumber, (quantityOrdered*priceEach) as `Total Order Amount` from orderdetails
where quantityOrdered*priceEach > 5000 group by orderNumber order by `Total Order Amount` desc;