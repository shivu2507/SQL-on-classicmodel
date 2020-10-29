use classicmodels;

/* Query 1 : Who reports to Mary Patterson?*/ 

select concat(firstname, lastname) as `Employee Name` 
from employees where reportsTo = (select employeeNumber from employees where firstname = 'Mary' and lastname = 'patterson');

/* Query 2 : Which payments in any month and year are more than twice the average for that month and year */

select year(paymentDate) as `yr`, month(paymentDate) as `mnth`, customerNumber, amount
from payments group by year(paymentDate), month(paymentDate), customerNumber
having amount > all(select (2*avg(amount)) from payments group by month(paymentDate), year(paymentDate))
order by year(paymentDate), month(paymentDate);

/* Query 3 : Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs.
Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.*/

with total_linestock as 
(select productLine, sum(quantityInstock) as `total line stock` from products group by productLine order by productLine)
select p1.productLine, p1.productName, round((100*p1.quantityInStock/p2.`total line stock`),2) as `% of total line stock`
from products p1 join total_linestock p2 using (productLine) 
group by p1.productLine, p1.productName order by productLine, `% of total line stock` desc;

/* Query 4 : For orders containing more than two products, report those products that constitute more than 50% of the value of the order.*/

with orderwise_details as (
select od.orderNumber, count(orderNumber), sum(od.quantityOrdered*od.priceEach) as `order value` from orderdetails od 
group by orderNumber having count(orderNumber) > 1)
select od.orderNumber, p.productName, (100*od.quantityOrdered*od.priceEach/oe.`order value`) as `% of order value` 
from orderdetails od inner join products p using(productCode)
cross join orderwise_details oe using(orderNumber) 
group by orderNumber having count(orderNumber) > 1 and `% of order value` > 50 and `% of order value`;
