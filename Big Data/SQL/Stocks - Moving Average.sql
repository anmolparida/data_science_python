-- Beginning of Assignment, Submitted By - ANMOL PARIDA

-- Creating Database and using it
create database assignment;
use assignment;

/*
Data Preparation - Importing Data and Formatting it

 --  Importde the CSV files with the help of Table Data import Wizard
 -- Formattig the date for all the 6 tables
 
*/

-- Bajaj Auto --

select * from bajajauto;

alter table bajajauto add column date_formatted DATE;
update bajajauto set date_formatted = str_to_date(bajajauto.date, "%d-%M-%Y");
alter table bajajauto drop date;

commit;

select * from bajajauto;


-- Hero Motocorp --

select * from HeroMotocorp;

alter table HeroMotocorp add column date_formatted DATE;
update HeroMotocorp set date_formatted = str_to_date(HeroMotocorp.date, "%d-%M-%Y");
alter table HeroMotocorp drop date;

commit;

select * from HeroMotocorp;

-- TVS Motors --

select * from tvsmotors;

alter table tvsmotors add column date_formatted DATE;
update tvsmotors set date_formatted = str_to_date(tvsmotors.date, "%d-%M-%Y");
alter table tvsmotors drop `date`; -- Use backtick to select columns with spaces

commit;

select * from tvsmotors;


-- Eicher Motors

select * from eichermotors;

alter table eichermotors add column date_formatted DATE;
update eichermotors set date_formatted = str_to_date(eichermotors.date, "%d-%M-%Y");
alter table eichermotors drop date;

commit;

select * from eichermotors;


-- TCS --

SELECT * FROM tcs;
alter table tcs add column date_formatted DATE;
commit;

SELECT date, date_formatted FROM tcs;
update tcs set date_formatted = str_to_date(tcs.date, "%d-%M-%Y");
commit;
SELECT infosys.date, date_formatted FROM tcs order by date_formatted asc;


-- Infosys --

alter table infosys add column date_formatted DATE;
commit;
update infosys set date_formatted = str_to_date(infosys.date, "%d-%M-%Y");
commit;
SELECT date, date_formatted FROM infosys;

-- End of Data Preparation and Formatting --


/*
Question 1. Create a new tables containing the date, close price, 20 Day MA and 50 Day MA. (This has to be done for all 6 stocks)
*/

-- Creating Bajaj1 from BajajAuto

create table bajaj1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from bajajauto;

commit;

select * from bajaj1;

-- Creatting TCS1 from TCS

create table tcs1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from tcs;
commit;

-- Creatting Hero1 from HeroMotocorp

create table hero1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from heromotocorp;
commit;

select * from hero1;

-- Creating Eicher1 from EicherMotors

create table eicher1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from EicherMotors;
commit;

select * from eicher1;

-- Creating Infosys1 from Infosys

create table infosys1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from infosys;
commit;

select * from infosys1;


-- Creating TVS1 from TVSMotors

create table tvs1 as 
select date_formatted as `Date`,
				`Close Price`,
            avg(`Close Price`) over(order by date_formatted asc rows 19 preceding) as '20 Day MA',
            avg(`Close Price`) over(order by date_formatted asc rows 49 preceding) as '50 Day MA'
from TVSMotors;
commit;

select * from tvs1;

-- End of Question 1 --


/*
Question 2. Create a master table containing the date and close price of all the six stocks. (Column header for the price is the name of the stock)

<< Naming the master table as STOCKS >>
*/

create table stocks as
select `Date`, 
			bajaj1.`Close Price` as Bajaj, 
            tcs1.`Close Price` as TCS,
            tvs1.`Close Price` as TVS,
            infosys1.`Close Price` as Infosys,
            eicher1.`Close Price` as Eicher,
            hero1.`Close Price` as Hero
from bajaj1
inner join  eicher1 using (`Date`)
inner join  tvs1 using (`Date`)
inner join  hero1 using (`Date`)
inner join  infosys1 using (`Date`)
inner join  tcs1 using (`Date`);

commit;

select * from stocks;

-- End of Question  2 --

/*
Question 3. Use the table created in Part(1) to generate buy and sell signal. Store this in another table named 'bajaj2'. Perform this operation for all stocks.
*/

/*

When the shorter-term moving average crosses above the longer-term moving average, it is a signal to BUY, as it indicates that the trend is shifting up. This is known as a Golden Cross.
On the opposite when the shorter term moving average crosses below the longer term moving average, it is a signal to SELL, as it indicates the trend is shifting down. It is sometimes referred to as the Death Cross.

Important: Please note that it is important that the Moving Averages Cross each other in order to generate a signal. Merely being above or below is not sufficient to generate a signal.

*/
-- Bajaj --

select * from bajaj1;
alter table bajaj1 add column Moving_Avergae_Difference Double;
update bajaj1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table bajaj2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from bajaj1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from bajaj2 group by `Signal`;

-- TCS --

select * from tcs1;
alter table tcs1 add column Moving_Avergae_Difference Double;
update tcs1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table tcs2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from tcs1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from tcs2 group by `Signal`;

-- TVS --

select * from tvs1;
alter table tvs1 add column Moving_Avergae_Difference Double;
update tvs1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table tvs2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from tvs1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from tvs2 group by `Signal`;

-- Infosys --

select * from infosys1;
alter table infosys1 add column Moving_Avergae_Difference Double;
update infosys1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table infosys2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from infosys1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from infosys2 group by `Signal`;


-- Eicher --

select * from eicher1;
alter table eicher1 add column Moving_Avergae_Difference Double;
update eicher1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table eicher2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from eicher1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from eicher2 group by `Signal`;

-- Hero --

select * from hero1;
alter table hero1 add column Moving_Avergae_Difference Double;
update hero1 set Moving_Avergae_Difference=`20 Day MA`-`50 Day MA`;

create table hero2 as (
with temp AS (select *, row_number() over (order by `Date`) as DateRank from hero1) 
select t1.`Date`,t1.`Close Price`,
CASE
	when sign(t1.Moving_Avergae_Difference)<=0 and sign(t2.Moving_Avergae_Difference)>0 then 'BUY'
	when sign(t1.Moving_Avergae_Difference)>=0 and sign(t2.Moving_Avergae_Difference)<0 then 'SELL'
	else 'HOLD'
END as 'Signal'
from temp t1 inner join temp t2 where t1.DateRank=t2.DateRank-1);

commit;
select `Signal`, count(*) from hero2 group by `Signal`;

-- End of Question 3 --

/*
Question 4. Create a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.
*/

-- Passing only Date for table bajaj2

DELIMITER $$
CREATE FUNCTION  FlagSignal (QueryDate DATE)  
RETURNS VARCHAR(5) 
DETERMINISTIC
BEGIN 
	DECLARE QuerySignal VARCHAR(5);

	SELECT `Signal` INTO QuerySignal
	FROM bajaj2
	WHERE bajaj2.Date = QueryDate; 

	RETURN (QuerySignal) ; 

	END $$
    DELIMITER ;

commit;

-- Verifyting the Result --  

-- QueryDate Example: 2015-01-14 (YYYY-MLM-DD)

SELECT FlagSignal('2015-03-20')  as "Signal";  -- Expected : HOLD
SELECT FlagSignal('2016-11-23')  as "Signal";  -- Expected : HOLD
SELECT FlagSignal('2017-08-04')  as "Signal";  -- Expected : BUY
SELECT FlagSignal('2018-05-28')  as "Signal";  -- Expected : SELL

-- End of Question 4 --


-- End of Assignment, Submitted By - ANMOL PARIDA