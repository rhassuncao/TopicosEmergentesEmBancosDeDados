set max_parallel_workers_per_gather = 0;
-- quais os índices destas tabelas?
SELECT
    tablename, indexname, indexdef
FROM
    pg_indexes
WHERE
    tablename in ('depto', 'proj', 'emp', 'alocado');
-- tirando as PK's o unico index idx_depto
-- CREATE INDEX idx_depto ON public.depto USING btree (coddepto)

--T1. (205)
explain analyse select * from emp inner join depto on (depto.coddepto = emp.coddepto) where codemp = 1; 
-- 0 ms
-- 0 ms
-- 0 ms
--utilizou  os indices pk_emp e idx_depto

--T2. (309)
--select * from alocado inner join proj on (alocado.codproj = proj.codproj) where qthoras between .... and ....;
--primeiro preciso saber o min e o max de qthoras
select min(qthoras) as min, max(qthoras) as max from alocado
-- a partir de T2 vou criar 3 queries com valores distintos de qt horas dentor do intervalo entre min e max
--T2A
explain analyse select * from alocado inner join proj on (alocado.codproj = proj.codproj) where qthoras between 1 and 36;
-- 46
-- 28
-- 25
-- não utilizou nenhum indice

--T2B
explain analyse select * from alocado inner join proj on (alocado.codproj = proj.codproj) where qthoras between 1 and 72;
-- 46
-- 76
-- 37
-- não utilizou nenhum indice

--T2C
explain analyse select * from alocado inner join proj on (alocado.codproj = proj.codproj) where qthoras between 1 and 108;
-- 84
-- 56
-- 57
-- não utilizou nenhum indice

create index idx_alocado_qthoras on alocado using BRIN (qthoras)
vacuum alocado
drop index idx_alocado_qthoras

--T3. (189)
-- Preciso saber qual o salario maximo para montar a query
select max(vlsalario) from emp --"8900.97"
select min(vlsalario) from emp --""1.04717""
-- vou montar 3 queries para verificar
explain analyse select alocado.* from alocado where codemp in (select codemp from emp where vlsalario > 2000);
-- utiliza pk_emp
--96
--103
--91
explain analyse select alocado.* from alocado where codemp in (select codemp from emp where vlsalario > 4000);
-- utiliza pk_emp
-- 90
-- 89
-- 92

explain analyse select alocado.* from alocado where codemp in (select codemp from emp where vlsalario > 6000);
-- utiliza pk_emp
-- 85
-- 102
-- 82

create index idx_emp_vlsalario on emp using BRIN (vlsalario)
vacuum emp
drop index idx_emp_vlsalario

--T4. (125)
-- preciso saber quais os valores possiveis de nmlocalizacao
select distinct(nmlocalizacao) from depto
-- São Paulo
-- Uruguaiana
-- Santos
-- Porto Alegre
-- Campinas
explain analyse select * from proj natural join depto where nmlocalizacao in ('São Paulo', 'Santos', 'Porto Alegre' , 'Campinas' ); 
-- nao utilizou nenhum indice
-- 18
-- 15
-- 16

create index idx_depto_nmlocalizacao on depto using BRIN (nmlocalizacao)
vacuum depto
drop index idx_depto_nmlocalizacao

--T5. (141)
--baseado nos valores min e max de salario de questões anteriores vou criar 3 queries
--T5A
explain analyse with DP as (select codemp from emp where vlsalario between 0 and 3000) 
select alocado.* from alocado inner join DP on (alocado.codemp = DP.codemp);
-- não usa nenhum indice
-- 282
-- 259
-- 269

--T5B
explain analyse with DP as (select codemp from emp where vlsalario between 0 and 6000) 
select alocado.* from alocado inner join DP on (alocado.codemp = DP.codemp);
-- não usa nenhum indice
-- 339
-- 352
-- 382
-- como nenhuma das transações de T5 utilizou indices preeistente e os tempos foram lineares
-- vou utilizar T5B para testar os indices

--T5C
explain analyse with DP as (select codemp from emp where vlsalario between 0 and 9000) 
select alocado.* from alocado inner join DP on (alocado.codemp = DP.codemp);
-- não usa nenhum indice
-- 416
-- 410
-- 429

create index idx_emp_vlsalario on emp using BRIN (vlsalario)
vacuum emp
drop index idx_emp_vlsalario