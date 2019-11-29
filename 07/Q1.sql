drop table if exists RelA;
drop table if exists RelB;
drop table if exists RelC;
drop table if exists RelD;

create table RelA (
	Att1 integer primary key,
	Att2 text
);

create sequence seq_att1_relA
	increment 1
	minvalue 1
	maxvalue 550
	start 1;
	
insert into RelA (att1, att2)
	select nextval('seq_att1_relA'),
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 221 + 1)::int)
	from generate_series(1,550) s(i);
	
select * from relA

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'rela'
-- 7 pages

create table RelB (
	Att3 integer primary key,
	Att4 text,
	Att5 text
);

create sequence seq_att1_relB
	increment 1
	minvalue 1
	maxvalue 400
	start 1;
	
insert into RelB (att3, att4, att5)
	select nextval('seq_att1_relB'),
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 1 + 1)::int),
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 50 + 1)::int)
	from generate_series(1,400) s(i);

--drop sequence seq_att1_relB
--truncate table relB
	
select * from relB

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'relb'
--4pages
	
create table RelC (
	Att6 integer primary key,
	Att3 integer,
	Att7 text,
	CONSTRAINT RelC_Att3_RelB_Att3 FOREIGN KEY (Att3)
	REFERENCES RelB (Att3)
);

create sequence seq_att6_relC
	increment 1
	minvalue 1
	maxvalue 900
	start 1;

insert into RelC (att6, att3, att7)
	select nextval('seq_att6_relC'),
	floor(random() * 400 + 1)::int,--inteiro aleatorio entre 1 e 400,
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 50 + 1)::int)
	from generate_series(1,900) s(i);

/*
truncate table RelC;
drop sequence seq_att6_relC
*/
	
select * from relC

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'relc'
--8pages

create table RelD (
	Att0 integer,
	Att1 integer,
	Att6 integer,
	Att7 date,
	Att8 decimal,
	Att9 decimal,
	CONSTRAINT PK_RelD primary key (Att0),
	CONSTRAINT RelA_Att6_RelD_Att6 FOREIGN KEY (Att6)
	REFERENCES RelC (Att6),
	CONSTRAINT RelA_Att1_RelD_Att1 FOREIGN KEY (Att1)
	REFERENCES RelA (Att1)
);

--truncate table RelD
--drop table RelD
--drop sequence seq_att0_relD

create sequence seq_att0_relD
	increment 1
	minvalue 1
	maxvalue 3000000
	start 1;

insert into RelD (att0, att1, att6, att7, att8, att9)
	select 
	nextval('seq_att0_relD'),
	floor(random() * 550 + 1)::int,
	floor(random() * 900 + 1)::int,
	timestamp '2000-01-01 20:00:00' +
       random() * (timestamp '2000-01-20 20:00:00' -
                   timestamp '1950-01-01 10:00:00'),
	floor(random() * 550 + 1)::int,
	floor(random() * 900 + 1)::int
	from generate_series(1,3000000) s(i);
	
select * from relD

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'reld'
--22059pages

-- T1.
--verificacao dos possiveis candidatos para o where
select count(1), att4 from relB group by att4;
--escolhi usar a letar b

explain analyze select 
att2, att5, relc.att7, att8, att9 
from rela 
natural join relD
join relc using(att6) 
natural join relb 
where att4 = 'b' order by 1, 2, 3;
--973 ms
--1111ms
--1023ms

create materialized view VW_T1ALL as 
select 
att2, att5, relc.att7, att8, att9 
from rela 
natural join relD
join relc using(att6) 
natural join relb 
where att4 = 'b' order by 1, 2, 3;
-- criacao em 1222 segundos
-- drop materialized view VW_T1ALL

explain analyze select att2, att5, att7, att8, att9 from VW_T1ALL
--14ms
--16ms
--13ms

vacuum vw_t1cb;

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t1all'
--100077 tuplas
--15MB
--1942pages

create materialized view VW_T1AB as 
select 
att2, att5, att4
from rela 
natural join relb 
where att4 = 'b' order by 1, 2;
-- criacao em 687 ms
-- drop materialized view VW_T1AB

select * from vw_t1AB

explain analyze select 
att2, att5, relc.att7, att8, att9 
from VW_T1AB
natural join relD
join relc using(att6) 
where att4 = 'b' order by 1, 2, 3;
-- após 1 min a query foi cancelada

vacuum vw_t1cb;

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
FROM   pg_class
WHERE  relname = 'vw_t1ab'
--7150 tuplas
--832kb

create materialized view VW_T1CB as 
select 
att5, att4, att6, att7
from relc 
natural join relb 
where att4 = 'b';
-- criacao em 56 ms
-- drop materialized view VW_T1CB

select * from VW_T1CB 

explain analyze select 
att2, att5, VW_T1CB.att7, att8, att9 
from rela
natural join relD
join VW_T1CB using(att6) 
order by 1, 2, 3;
-- 1024
-- 1255
-- 1025

vacuum vw_t1cb;

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
FROM   pg_class
WHERE  relname = 'vw_t1cb'
--40 tuplas
--48 kb

-- T2.
select 
att2, att4, relc.att7, sum(att8), sum(att9) 
from rela 
natural join relD 
join relc using(att6) 
natural join relb 
group by att2, att4, relc.att7;

explain analyze
select 
att2, att4, relc.att7, sum(att8), sum(att9) 
from rela 
natural join relD 
join relc using(att6) 
natural join relb 
group by att2, att4, relc.att7;
--24.550ms

create materialized view VW_T2All as
select 
att2, att4, relc.att7, sum(att8) as sum8, sum(att9) as sum9
from rela 
natural join relD 
join relc using(att6) 
natural join relb 
group by att2, att4, relc.att7;
--created in 25.419 ms

--drop materialized view VW_T2All

explain analyze select att2, att4, att7, sum8, sum9 from VW_T2All
-- 79 ms
-- 133 ms
-- 92 ms

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t2all'
--489630 tuplas
--59 MB
--7551 pages

--crescimento Mês 3
create table RelC3 (
	Att6 integer primary key,
	Att3 integer,
	Att7 text,
	CONSTRAINT RelC_Att3_RelB_Att3 FOREIGN KEY (Att3)
	REFERENCES RelB (Att3)
);

insert into RelC3 select * from relc

create sequence seq_att6_relC3
	increment 1
	minvalue 901
	maxvalue 927
	start 901;

insert into RelC3 (att6, att3, att7)
	select nextval('seq_att6_relC3'),
	floor(random() * 400 + 1)::int,--inteiro aleatorio entre 1 e 400,
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 50 + 1)::int)
	from generate_series(901,927) s(i);
	
SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'relc3'
--8pages

/*
truncate table RelC3;
drop sequence seq_att6_relC3
*/
	
create table RelD3 (
	Att0 integer,
	Att1 integer,
	Att6 integer,
	Att7 date,
	Att8 decimal,
	Att9 decimal,
	CONSTRAINT PK_RelD3 primary key (Att0),
	CONSTRAINT RelA_Att6_RelD3_Att6 FOREIGN KEY (Att6)
	REFERENCES RelC3 (Att6),
	CONSTRAINT RelA_Att1_RelD3_Att1 FOREIGN KEY (Att1)
	REFERENCES RelA (Att1)
);

--truncate table RelD3
--drop table RelD3
--drop sequence seq_att0_relD3

create sequence seq_att0_relD3
	increment 1
	minvalue 3000001
	maxvalue 3993000
	start 3000001;
	
insert into reld3 select * from reld

insert into RelD3 (att0, att1, att6, att7, att8, att9)
	select 
	nextval('seq_att0_relD3'),
	floor(random() * 550 + 1)::int,
	floor(random() * 927 + 1)::int,
	timestamp '2000-01-01 20:00:00' +
       random() * (timestamp '2000-01-20 20:00:00' -
                   timestamp '1950-01-01 10:00:00'),
	floor(random() * 550 + 1)::int,
	floor(random() * 927 + 1)::int
	from generate_series(3000001,3993000) s(i);
	
select * from relD3

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'reld3'
--29361pages

create materialized view VW_T1ALL3 as 
select 
att2, att5, relc3.att7, att8, att9 
from rela 
natural join relD3
join relc3 using(att6) 
natural join relb 
where att4 = 'b' order by 1, 2, 3;
-- criacao em 1222 segundos
-- drop materialized view VW_T1ALL3

explain analyze select att2, att5, att7, att8, att9 from VW_T1ALL3
--17ms
--17ms
--18ms

vacuum vw_t1all3;

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t1all3'
--132138 tuplas
--20MB
--2564 pages

create materialized view VW_T2All3 as
select 
att2, att4, relc3.att7, sum(att8) as sum8, sum(att9) as sum9
from rela 
natural join relD3
join relc3 using(att6) 
natural join relb 
group by att2, att4, relc3.att7;
--created in 31.419 ms

--drop materialized view VW_T2All3

explain analyze select att2, att4, att7, sum8, sum9 from VW_T2All3
-- 86 ms
-- 111 ms
-- 86 ms

vacuum vw_t2all3

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t2all3'
--503338 tuplas
--61 MB
--pages 7760

--crescimento Mês 6
create table RelC6 (
	Att6 integer primary key,
	Att3 integer,
	Att7 text,
	CONSTRAINT RelC6_Att3_RelB_Att3 FOREIGN KEY (Att3)
	REFERENCES RelB (Att3)
);

insert into relc6 select * from relc3

create sequence seq_att6_relC6
	increment 1
	minvalue 928
	maxvalue 955
	start 928;

insert into RelC6 (att6, att3, att7)
	select nextval('seq_att6_relC6'),
	floor(random() * 400 + 1)::int,--inteiro aleatorio entre 1 e 400,
	substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 50 + 1)::int)
	from generate_series(928,955) s(i);

/*
drop table RelC6;
drop sequence seq_att6_relC6
*/
	
select * from relC6

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'relc6'
--4pages

create table RelD6 (
	Att0 integer,
	Att1 integer,
	Att6 integer,
	Att7 date,
	Att8 decimal,
	Att9 decimal,
	CONSTRAINT PK_RelD6 primary key (Att0),
	CONSTRAINT RelA_Att6_RelD6_Att6 FOREIGN KEY (Att6)
	REFERENCES RelC6 (Att6),
	CONSTRAINT RelA_Att1_RelD6_Att1 FOREIGN KEY (Att1)
	REFERENCES RelA (Att1)
);

insert into reld6 select * from reld3

--truncate table RelD
--drop table RelD6
--drop sequence seq_att0_relD6

create sequence seq_att0_relD6
	increment 1
	minvalue 3993001
	maxvalue 5314683
	start 3993001;

insert into RelD6 (att0, att1, att6, att7, att8, att9)
	select 
	nextval('seq_att0_relD6'),
	floor(random() * 550 + 1)::int,
	floor(random() * 955 + 1)::int,
	timestamp '2000-01-01 20:00:00' +
       random() * (timestamp '2000-01-20 20:00:00' -
                   timestamp '1950-01-01 10:00:00'),
	floor(random() * 550 + 1)::int,
	floor(random() * 955 + 1)::int
	from generate_series(3993001,5314683) s(i);
	
select count(1) from relD6

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'reld6'
--39079pages

create materialized view VW_T1ALL6 as 
select 
att2, att5, relc6.att7, att8, att9 
from rela 
natural join relD6
join relc6 using(att6) 
natural join relb 
where att4 = 'b' order by 1, 2, 3;
-- criacao em 2470 segundos
-- drop materialized view VW_T1ALL6

explain analyze select att2, att5, att7, att8, att9 from VW_T1ALL6
--32ms

vacuum vw_t1all6;

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t1all6'
--1175276 tuplas
--27MB
--3397 pages

create materialized view VW_T2All6 as
select 
att2, att4, relc6.att7, sum(att8) as sum8, sum(att9) as sum9
from rela 
natural join relD6
join relc6 using(att6) 
natural join relb 
group by att2, att4, relc6.att7;
--created in 31.419 ms

--drop materialized view VW_T2All3

explain analyze select att2, att4, att7, sum8, sum9 from VW_T2All6
-- 86 ms
-- 96 ms
-- 89 ms

vacuum vw_t2all6

SELECT relname   AS objectname
     , reltuples AS entries
     , pg_size_pretty(pg_table_size(oid)) AS size
	 , relpages
FROM   pg_class
WHERE  relname = 'vw_t2all6'
--519611 tuplas
--63 MB
--8015 pages