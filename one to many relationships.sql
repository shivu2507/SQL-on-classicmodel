/* Query 1 : Report the account representative for each customer.*/

select c.customerName, concat(e.firstName, e.lastName) as `Account Representative`
from customers c inner join employees e on c.salesRepEmployeeNumber = e.employeeNumber
order by customerName;

/* Query 2 : Report total payments for Atelier graphique.*/

select sum(amount) as `Total Payments for Atelier graphique` from payments
where customerNumber =  (select customerNumber from customers where customerName = 'Atelier graphique');

/* Query 3 : Report the total payments by date*/ 

select paymentDate, sum(amount) as `Total Payment` from payments 
group by paymentDate order by `Total Payment` desc;

/* Query 4 : Report the products that have not been sold.*/ 

select productName from products
where not exists (select productCode from orderdetails
where products.productCode = orderdetails.productCode);

/* Query 5 : List the amount paid by each customer.*/

select c.customerName, sum(p.amount) as `Total Amount paid`
from customers c inner join payments p on c.customerNumber = p.customerNumber
group by c.customerName order by customerName;

/* Query 6 : How many orders have been placed by Herkku Gifts?*/

select c.customerName, count(distinct od.orderNumber) as `Main Order Counts`, count(od.orderNumber) as
`Sub Order Counts`, count(distinct od.productCode) as `Products Count`, sum(od.quantityOrdered) as 
`Total Quantities Ordered` from orderdetails od
inner join orders o on od.orderNumber = o.orderNumber
inner join customers c on o.customerNumber = o.customerNumber
where c.customerName = 'Herkku Gifts';

/* Query 7 : Who are the employees in Boston?*/

select concat(firstName, lastName) as `Employee Name` from employees
where officeCode = (select officeCode  from offices where city = 'Boston');

/* Query 8 : Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.*/

select c.customerName, p.amount as `Payments`
from payments p inner join  customers c on p.customerNumber = c.customerNumber
where p.amount > 100000;

/* Query 9 : List the value of 'On Hold' orders.*/

select sum(p.amount) as `On Hold Orders Value` from payments p
inner join orders o on p.customerNumber = o.customerNumber where status = 'On Hold';

/* Query 10 : Report the number of orders 'On Hold' for each customer.*/

select c.customerName, count(*) as `On Hold Order Quantities` 
from customers c inner join orders o on c.customerNumber = o.customerNumber 
where status = 'On Hold' group by c.customerName;