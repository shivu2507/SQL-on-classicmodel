use classicmodels;

/* Query 1 : Who is at the top of the organization (i.e.,  reports to no one).*/ 

select concat(firstName, lastName) as `At Top of organization` from employees where reportsTo is null;

/* Query 2 : Who reports to William Patterson?*/

select concat(firstName, lastName), reportsTo as `Employee Name` from employees 
where reportsTo = (select employeeNumber from employees 
				   where firstName = 'William' and lastName = 'Patterson');
                   
/* Query 3 : List all the products purchased by Herkku Gifts.*/ 

select distinct p.productName from products p inner join orderdetails od
on p.productCode = od.productCode inner join orders o 
on od.orderNumber = o.orderNumber inner join customers c 
on o.customerNumber = o.customerNumber where customerName = 'Herkku Gifts';

/* Query 4 : Compute the commission for each sales representative, assuming the commission is 5% of 
the value of an order. Sort by employee last name and first name.*/

select c.salesRepEmployeeNumber as `Employee Number`, concat(e.firstName, e.lastName) as `Employee Name`,
sum(round((0.05*(od.quantityOrdered * priceEach)),2)) as `Commission` 
from customers c inner join orders o on c.customerNumber = o.customerNumber 
inner join orderdetails od  on o.orderNumber = od.orderNumber 
inner join employees e on c.salesRepEmployeeNumber = e.employeeNumber
group by `Employee Name` order by `Commission` desc;

/* Query 5 : What is the difference in days between the most recent and oldest order date in the Orders file?*/

select datediff(max(orderDate), min(orderDate)) as `Order Time period` from orders;

/* Query 6 : Compute the average time between order date and ship date for each customer ordered by 
the largest difference.*/

select c.customerName, round(avg(datediff(o.shippedDate, o.orderDate)),1) as `Avg Days taken to ship`
from customers c inner join orders o on c.customerNumber = o.customerNumber
group by customerName order by `Avg Days taken to ship` desc;

/* Query 7 : What is the value of orders shipped in August 2004?*/

select sum(od.quantityOrdered*od.priceEach) as `Total Order Value for August 2004`
from orderdetails od inner join orders o on od.orderNumber = o.orderNumber
where year(o.orderDate) = 2004 and month(o.orderDate) = 8;

/* Query 8 : Compute the total value ordered, total amount paid, and their difference 
for each customer for orders placed in 2004 and payments received in 2004*/

create view payments_2004 as 
select sum(p.amount) as `Amount paid`, c.customerName as `Name`, p.paymentDate from payments p inner join customers c on 
c.customerNumber = p.customerNumber where year(p.paymentDate) = 2004
group by customerName order by customerName;

create view orders_2004 as 
select sum(od.quantityOrdered*od.priceEach) as `Amount Ordered`, c.customerName as `Name`, o.orderDate from orders o inner join customers c on 
c.customerNumber = o.customerNumber inner join orderdetails od on o.orderNumber = od.orderNumber where year(o.orderDate) = 2004
group by customerName order by customerName;

select p.`Name` , p.`Amount Paid` as `Amount Paid`, o.`Amount ordered` as `Amount Ordered`, 
(p.`Amount Paid` - o.`Amount Ordered`) as `Balance` from payments_2004 p inner join orders_2004 o on
p.`Name` = o.`Name`; 

/* Query 9 : List the employees who report to those employees who report to Diane Murphy. */

select concat(firstname, lastName) as `Employee Name` from employees 
where reportsTo = any(select employeeNumber from employees 
where reportsTo = any(select employeeNumber from employees where firstName = 'Diane' and lastName = 'Murphy'));

/* Query 10 : What is the percentage value of each product in inventory sorted by the highest percentage first */

select p1.productName, round(100*(p1.quantityInstock/p2.`Total Stock`),2) as `Percentage of stock`
from products p1 cross join (select sum(quantityInStock) as `Total Stock` from products) p2 order by `Percentage of stock` desc;

/* Query 11 : Write a procedure to increase the price of a specified product category by a given percentage. */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `price_increase`(in product varchar(50), in percentage decimal (10,2), out IncreasedPrice decimal (10,2))
BEGIN
select (MSRP+(MSRP*percentage)/100) into IncreasedPrice
from products where product = productName;
END$$
DELIMITER ;

call price_increase('1969 Harley Davidson Ultimate Chopper',8,@IncreasedPrice);

select @IncreasedPrice;

/* Query 12 : What is the ratio the value of payments made to orders received for each month of 2004. */

select month(p.paymentDate) as `mnth`, p.`Amount Paid`, o.`Amount Ordered`, (p.`Amount Paid`/o.`Amount Ordered`) as `Ratio of Payment`
from payments_2004 p inner join orders_2004 o on month(p.paymentDate) = month(o.orderDate)
group by month(p.paymentDate) order by month(p.paymentDate);

/* Query 13 : What is the difference in the amount received for each month of 2004 compared to 2003?*/ 

create view orders_2003 as 
select sum(od.quantityOrdered*od.priceEach) as `Amount Ordered`, c.customerName as `Name`, o.orderDate from orders o inner join customers c on 
c.customerNumber = o.customerNumber inner join orderdetails od on o.orderNumber = od.orderNumber where year(o.orderDate) = 2003
group by customerName order by customerName;

select month(o4.orderDate)as `mnth`, (o4.`Amount Ordered` - o3.`Amount Ordered`) as `Amount Diff (2004-2003)`
from orders_2004 o4 right outer join orders_2003 o3 on month(o4.orderDate) = month(o3.orderDate)
group by month(o4.orderDate) order by month(o4.orderDate);

/* Query 14 :  Write a procedure to report the amount ordered in a specific month and year for customers containing a specified 
character string in their name.*/ 

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Amount Ordered`(in `year` int, in `month` int, in _textInput character (50), out `Amount Ordered` decimal (10,2))
BEGIN
select sum(od.quantityOrdered*od.priceEach) into `Amount Ordered`
from orderdetails od inner join orders o on od.orderNumber = o.orderNumber
inner join customers c on c.customerNumber = o.customerNumber
where year(o.orderDate) = `year` and month(o.orderDate) = `month` and c.customerName like concat('%',_textInput,'%');
END$$
DELIMITER ;

call `Amount Ordered`(2005,5,'euro', @`Amount Ordered`);

select @`Amount Ordered`;

/* Query 15 : Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.*/

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `credit_increase`(in country varchar (50), in percentage decimal (10,2), out customerlist varchar (2000))
BEGIN
	declare finished int default 0;
	declare customers varchar (1000);
    declare customer cursor for select customerName from customers where country = country;
	declare continue handler for not found set finished = 1;
	open customer;
	getcustomer : loop 
			 fetch customer into  customers;
				if finished = 1 then leave getcustomer;
				end if;
                set customerlist  = concat(customerlist,concat(' ',customers));
	end loop getcustomer;
	close customer;
END$$
DELIMITER ;

set customerlist = '';

call credit_increase('France', 5.5, @customerlist);

select @customerlist;

/* Query 16 : ompute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue.
Sort by customer name.*/

with totalRevenue as 
(select sum(quantityOrdered*priceEach) as `TotalRevenue` from orderdetails)
 
select c.customerName, sum(od.quantityOrdered*od.priceEach) as `Order Revenue`,
(100*sum(od.quantityOrdered*od.priceEach)/tr.`TotalRevenue`) as `% of total revenue`
from customers c inner join orders o on c.customerNumber = o.customerNumber 
inner join orderdetails od on o.orderNumber = od.orderNumber cross join (select `TotalRevenue`  as `TotalRevenue` from totalRevenue) tr 
group by c.customerName order by c.customerName;

/* Query 17 : Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit.
Sort by profit descending.*/ 
 
with totalprofit as (
select sum(od.quantityOrdered*(od.priceEach - p.buyprice)) as `total profit` from 
products p inner join orderdetails od on p.productCode = od.productCode)
select c.customerName, sum(od.quantityOrdered*(od.priceEach - p.buyprice)) as `profit`, 
round(100*sum(od.quantityOrdered*(od.priceEach - p.buyprice))/tp.`total profit`,2) as `% of total profit` 
from customers c inner join orders o on c.customerNumber = o.customerNumber 
inner  join orderdetails od on o.orderNumber = od.orderNumber
inner join products p on od.productCode = p.productCode cross join totalprofit tp group by customerName order by `profit` desc;

/* Query 18 : Compute the revenue generated by each sales representative based on the orders from the customers they serve.*/

select concat(e.firstname, e.lastname) as `Employee Name`, sum(od.quantityOrdered*od.priceEach) as `Revenue Generated`
from employees e inner join customers c on e.employeeNumber = c.salesRepEmployeeNumber
inner join orders o on c.customerNumber = o.customerNumber
inner join orderdetails od on o.orderNumber = od.orderNumber
group by `Employee Name` order by `Revenue Generated` desc;

/* Query 19 : Compute the profit generated by each sales representative based on the orders from the customers they serve.
Sort by profit generated descending.*/

select concat(e.firstname, e.lastname) as `Employee Name`, sum(od.quantityOrdered*(od.priceEach - p.buyprice)) as `Profit Generated`
from employees e inner join customers c on e.employeeNumber = c.salesRepEmployeeNumber
inner join orders o on c.customerNumber = o.customerNumber
inner join orderdetails od on o.orderNumber = od.orderNumber
inner join products p on od.productCode = p.productCode
group by `Employee Name` order by `Profit Generated` desc;

/* Query 20 : Compute the revenue generated by each product, sorted by product name.*/

select p.productName, sum(od.quantityOrdered*od.priceEach) as `Revenue Generated`
from products p inner join orderdetails od on p.productCode = od.productCode
group by p.productName order by `Revenue Generated` desc;

/* Query 21 : Compute the profit generated by each product line, sorted by profit descending.*/

select p.productLine, sum(od.quantityOrdered*(od.priceEach - p.buyprice)) as `Profit Generated`
from products p inner join orderdetails od on p.productCode = od.productCode
group by p.productLine order by `Profit Generated` desc;

/* Query 22 : Compute the ratio for each product of sales for 2003 versus 2004.*/

with sales_2003 as 
(select p.productName, sum(od.quantityOrdered) as `2003 Sales` from products p inner join orderdetails od on p.productCode = od.productCode
inner join orders o on od.orderNumber = o.orderNumber 
where year(o.orderDate) = 2003
group by p.productName order by p.productName) 
select p.productName, sum(od.quantityOrdered) as `2004 Sales`, s.`2003 Sales`, sum(od.quantityOrdered)/s.`2003 Sales` as `Sales Ratio (2004/2003)` 
from products p inner join orderdetails od on p.productCode = od.productCode
inner join orders o on od.orderNumber = o.orderNumber
inner join sales_2003 s on s.productName = p.productName
where year(o.orderDate) = 2004
group by p.productName order by p.productName;

/* Query 23 : Compute the ratio of payments for each customer for 2003 versus 2004.*/

with 2003_payments as 
(select c.customerName, sum(p.amount) as`2003 payments` from customers c inner join payments p on c.customerNumber = p.customerNumber 
where year(p.paymentDate) = 2003 group by c.customerName order by c.customerName)
select c.customerName, sum(p.amount) as `2004 payments`, p3.`2003 payments`, sum(p.amount)/p3.`2003 payments` as `Ratio of payments (2004/2003)`
from customers c inner join payments p on c.customerNumber = p.customerNumber
inner join 2003_payments p3 on c.customerName = p3.customerName where year(p.paymentDate) = 2004
group by c.customerName order by c.customerName;
