create table Rel (
	att1 int,
	att2 numeric,
	att3 numeric
);

create sequence seq_att1_rel
	increment 1
	minvalue 1
	maxvalue 600000
	start 1;


insert into Rel (att1, att2, att3)
	select nextval('seq_att1_rel'), random(), random()
	from generate_series(1,600000) s(i);

create index idx_att1_rel on rel(att1) 

set max_parallel_workers_per_gather = 0;

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 1;
-- Index Scan
-- 0ms

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 60000
-- Index Scan
-- 10

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 120000;
-- Index Scan
-- 19

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 180000;
-- Index Scan
-- 26

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 240000;
-- Index Scan
-- 36

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 300000;
-- Index Scan
-- 43

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 360000;
-- Seq Scan
-- 78

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 420000;
-- seq Scan
-- 72

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 480000;
-- seq scan
-- 74

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 520000;
-- seq scan
-- 75

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 560000;
-- seq scan
-- 75

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 600000;
-- Seq Scan
-- 78

set enable_hashjoin      = off;
set enable_mergejoin     = off;
set enable_indexscan     = off;
set enable_indexonlyscan = off;
set enable_bitmapscan    = off;

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 1;
-- Seq
-- 61

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 60000
-- Seq
-- 62

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 120000;
-- Seq
-- 63

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 180000;
-- Index Scan
-- 65

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 240000;
-- Seq
-- 65

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 300000;
-- Seq
-- 69

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 360000;
-- Seq Scan
-- 70

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 420000;
-- seq Scan
-- 72

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 480000;
-- seq scan
-- 73

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 520000;
-- seq scan
-- 73

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 560000;
-- seq scan
-- 76

EXPLAIN ANALYSE SELECT * FROM Rel where att1 between 1 and 600000;
-- Seq Scan
-- 78