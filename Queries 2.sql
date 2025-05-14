select s.SaleDate, s.Amount, s.SPID, p.Salesperson, p.SPID
from sales as s
join people p on p.SPID=s.SPID;

select s.SaleDate, s.Amount, pr.Product
from sales s
left join products pr on pr.PID=s.PID;

select s.SaleDate, s.Amount, s.SPID, p.Salesperson, p.Team, pr.Product
from sales as s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
where s.Amount<500
and p.Team='delish';

select s.SaleDate, s.Amount, s.SPID, p.Salesperson, p.Team, pr.Product, g.GeoID
from sales as s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
join geo g on g.GeoID=s.GeoID
where s.Amount<500
and p.Team=''
and g.Geo in ('New Zealand' , 'India');