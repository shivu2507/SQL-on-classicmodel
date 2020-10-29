use classicmodels;

/* Query 1 : List products sold by order date.*/

select o.orderDate, p.productName
from products p inner join orderdetails od on p.productCode = od.productCode
inner join orders o on od.orderNumber = o.orderNumber 
order by orderDate;

/* Query 2 : List the order dates in descending order for orders for the 1940 Ford Pickup Truck.*/ 

select o.orderDate from orders o inner join orderdetails od on od.orderNumber = o.orderNumber 
inner join products p on od.productCode = p.productCode 
where p.productName = '1940 Ford Pickup Truck' order by o.orderDate desc;

/* Query 3 : List the names of customers and their corresponding order number where a particular 
order from that customer has a value greater than $25,000?*/

select c.customerName, o.orderNumber, sum(od.quantityOrdered*od.priceEach) as `OrderValue` 
from customers c inner join orders o on c.customerNumber = o.customerNumber 
inner join orderdetails od on o.orderNumber = od.orderNumber 
group by o.orderNumber having OrderValue > 25000 order by OrderValue desc;

/* Query 4 : Are there any products that appear on all orders?*/ 

select p.productName from products p inner join orderdetails od on p.productCode = od.productCode
group by p.productName having count(od.productCode) = (select (count(distinct orderNumber)) from orderdetails);

/* Query 5 : List the names of products sold at less than 80% of the MSRP.*/

select p.productName, p.MSRP, od.priceEach from products p inner join orderdetails od on
p.productCode = od.productCode where priceEach < (0.80 * MSRP);

/* Query 6 : Reports those products that have been sold with a markup of 100% or more 
(i.e.,  the priceEach is at least twice the buyPrice)*/

select p.productName, p.buyprice, od.priceEach from products p inner join orderdetails od on
p.productCode = od.productCode where priceEach >= (2*buyprice);

/* Query 7 : List the products ordered on a Monday.*/

select p.productName, o.orderDate from products p inner join orderdetails od on
p.productCode = od.productCode inner join orders o on
od.orderNumber = o.orderNumber where lower(dayname(o.orderDate)) = 'monday';

/* Query 8 : What is the quantity on hand for products listed on 'On Hold' orders?*/

select p.productName, p.quantityInStock, od.quantityOrdered from products p
inner join orderdetails od on p.productCode = od.productCode inner join orders o on
od.orderNumber = o.orderNumber where `status` = 'On Hold' group by productName order by quantityInStock;
