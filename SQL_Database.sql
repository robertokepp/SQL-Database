create database airportDB

create table flights(
flno int not null identity(1,1),
_from varchar(30),
_to varchar(30),
distance int,
departs time,
arrives time,
price money,

constraint pk_flights primary key(flno),
constraint ck_price check(price>0)
)

create table aircraft(
aid int not null identity(1,1),
aname varchar(30),
crusingrange int,

constraint pk_aircraft primary key(aid),
)

create table employees(
eid int not null identity(1,1),
ename varchar(30),
salary money,

constraint pk_employees primary key(eid),
constraint ck_salary check(salary>0)
)

create table certified(
eid int,
aid int

constraint fk_certified_employees foreign key(eid) references employees(eid),
constraint fk_certified_aircraft foreign key(aid) references aircraft(aid)
)

--every pilot is certifies for some aircraft
--and only pilots are certified to fly

Insert Into flights (_from,_to,distance,departs,arrives,price)
values('santo domingo','caracas',100000,'12:00:00','20:00:00',50000),
('los angeles','honolulu',7000000,'1:00:00','15:00:00',70000),
('los angeles','chicago',9000000,'17:00:00','00:00:00',20000),
('los angeles','honolulu',4000000,'11:00:00','22:00:00',60000),
('los angeles','chicago',6000000,'19:00:00','20:00:00',90000)

Insert Into aircraft (aname,crusingrange)
values('orion',1000),
('dedalus',4000),
('prometheus',900),
('apollo',8000),
('Odyssey',2000)

Insert Into employees (ename,salary)
values('jose',70000),
('luis',80000),
('juan',70000),
('carlos',100000),
('pepe',40000)

Insert Into certified (eid,aid)
values(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(3,1),
(3,2),
(3,4)

-- drop database airportDB

-- drop table flights
-- drop table aircraft
-- drop table employees
-- drop table certified

-- select * from flights
-- select * from aircraft
-- select * from employees
-- select * from certified

--a) Find the names of the aircraft such that all pilots certified to operate them have salaries more than $80,000

select air.aname from aircraft as air where air.aid in (select cer.aid from certified as cer where cer.eid in (select emp.eid from employees as emp where salary > 80000))

-- Answer:
-- apollo


--b) for each pilot who is certified for more than three aircraft, find the eid and the maximum crusingrange of the aircraft for which he is certified

select emp.eid, air.crusingrange from aircraft air, employees emp where air.crusingrange in (select max (crusingrange) from aircraft) and emp.eid in (select cer.eid from certified as cer group by cer.eid having count(cer.eid) > 3)

-- Answer:
-- 3, 8000 

 
--c) find the names of the pilots whose salary is less than the price of the cheapest rout from los angeles to honolulu

select emp.ename from employees as emp where emp.salary < (select min (price) from flights where _from = 'los angeles' and _to = 'honolulu')

-- Answer:
-- pepe


--d) for all aircraft with the crusing range over 1000 miles, find the name of the aircraft and the average salary of all pilots certified for his aircraft

select air.aname, AVG (emp.salary) from aircraft air, employees emp where air.crusingrange > 1000 and air.aid in (select cer.aid from certified as cer where cer.eid in (select emp.eid from employees as emp)) group by air.aname

-- Answer:
-- apollo, 72000
-- dedalus, 72000
-- Odyssey, 72000


--e) find the aids of all aircraft that can be used on routes from los angeles to chicago

select air.aid from aircraft as air where air.aid in (select flg.flno from flights as flg where flg._from = 'los angeles' and flg._to = 'chicago')

-- Answer:
-- 3
-- 5


--f) rewrite query (a) using CTE

with CTE_aircraft(aid, aname, crusingrange) AS
( 
  select aid, aname, crusingrange
  from aircraft
  where aid in (select cer.aid 
				from certified as cer 
				where cer.eid in 
				
				(select emp.eid 
				from employees as emp 
				where salary > 80000))
)
select aname from CTE_aircraft

-- Answer:
-- apollo