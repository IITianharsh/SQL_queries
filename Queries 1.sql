select SaleDate, Amount, Customers from sales; 
select SaleDate, Amount, Boxes, Amount/Boxes from sales;
select SaleDate, Amount, Boxes, Amount/Boxes as 'Amount per Box' from sales;
Select * from sales
where Amount>10000;

Select * from sales
where Amount>10000
order by  Amount desc;

Select * from sales
where GeoID= 'g1'
order by PID, Amount desc;

Select * from sales
where Amount > 10000 and SaleDate>= '2022-01-01';

select SaleDate, Amount from sales
where Amount > 10000 and year(SaleDate)=2022
order by Amount desc;

select * from sales
where boxes between 0 and 10 ;

select SaleDate, Amount, Boxes, weekday(SaleDate) as 'Day Of Week'
from sales
where weekday(SaleDate) = 4; 

select* from people;

select* from people
where Team=  'Jucies' or 'Delish' ;

select * from people
where Team in ('Delish', 'Jucies') ;

Select * from people
where Salesperson like 'b%' ;

Select * from people
where Salesperson like '%b%' ;

select SaleDate, Amount,
	case when amount < 1000 then 'Under 1k'
		 when amount < 5000 then 'Under 5k'
         when amount < 10000 then 'Under 10k'
       else '10k or more'
	end as 'Amount category'
from sales;       
         
