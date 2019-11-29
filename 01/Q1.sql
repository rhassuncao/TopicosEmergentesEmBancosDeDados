-- QUESTÃO 1

--Passo 1. Crie a relação Rel;

drop table Rel10000;
drop table Rel100000;
drop table Rel1000000;
drop table Rel5000000;

create table Rel10000   (att1 bigint, att2 numeric);
create table Rel100000  (att1 bigint, att2 numeric);
create table Rel1000000 (att1 bigint, att2 numeric);
create table Rel5000000 (att1 bigint, att2 numeric);

truncate table Rel10000;
truncate table Rel100000;
truncate table Rel1000000;
truncate table Rel5000000;

--Passo 2. Acrescente os dados randomicamente com o SQL abaixo.
--Note que o ’10000’ remete ao n´umero de valores distintos

insert into Rel10000
select (10000*random())::bigint, random()
from generate_series(1,10000000) s(i);

insert into Rel100000
select (100000*random())::bigint, random()
from generate_series(1,10000000) s(i);

insert into Rel1000000
select (1000000*random())::bigint, random()
from generate_series(1,10000000) s(i);

insert into Rel5000000
select (5000000*random())::bigint, random()
from generate_series(1,10000000) s(i);

--Passo 3. Atualize as estatíssticas com...

vacuum analyze Rel10000;
vacuum analyze Rel100000;
vacuum analyze Rel1000000;
vacuum analyze Rel5000000;

--Passo 4. Ajuste os parâmetros da sua sessão com...

set work_mem = '640MB';
set max_parallel_workers_per_gather = 0;

--Passo 5. Force o HashAggregate

set enable_hashagg = on;
set enable_sort = off;

--Passo 6. Submeta o SQL (3x ou mais) e colete o tempo de execução
--em cada submissão

--tempos medidos em ms
--devido a diferença em escala o planning time foi ignorado
--também foi ignorado as casas decimais do execution time

explain analyse SELECT att1, SUM(att2) FROM Rel10000 GROUP BY att1;
-- tempo1: 5174
-- tempo2: 4111
-- tempo3: 4237
-- média:  4507
explain analyse SELECT att1, SUM(att2) FROM Rel100000 GROUP BY att1;
-- tempo1: 7015
-- tempo2: 6184
-- tempo3: 6185
-- média:  6461
explain analyse SELECT att1, SUM(att2) FROM Rel1000000 GROUP BY att1;
-- tempo1: 8249
-- tempo2: 7615
-- tempo3: 7592
-- média:  7819
explain analyse SELECT att1, SUM(att2) FROM Rel5000000 GROUP BY att1;
-- tempo1: 11298
-- tempo2: 10080
-- tempo3: 10063
-- média:  10480

--Passo 7. Force o GroupAggregate

set enable_hashagg = off;
set enable_sort = on;

--Passo 8. Submeta o SQL (3x ou mais) e colete o tempo de execução
--em cada submissão

--tempos medidos em ms
--devido a diferença em escala o planning time foi ignorado
--também foi ignorado as casas decimais do execution time

explain analyse SELECT att1, SUM(att2) FROM Rel10000 GROUP BY att1;
-- tempo1: 7406
-- tempo2: 7462
-- tempo3: 7425
-- média:  7431
explain analyse SELECT att1, SUM(att2) FROM Rel100000 GROUP BY att1;
-- tempo1: 7837
-- tempo2: 7767
-- tempo3: 7904
-- média:  7837
explain analyse SELECT att1, SUM(att2) FROM Rel1000000 GROUP BY att1;
-- tempo1: 8662
-- tempo2: 8647
-- tempo3: 8534
-- média:  8614
explain analyse SELECT att1, SUM(att2) FROM Rel5000000 GROUP BY att1;
-- tempo1: 10165
-- tempo2: 10157
-- tempo3: 10141
-- média:  10154