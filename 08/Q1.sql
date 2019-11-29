set max_parallel_workers_per_gather=0;
set Force_parallel_mode = off;

--T1. 
explain analyze 
select alocado.* from alocado inner join emp on (alocado.codemp = emp.codemp) where vlsalario >= 1300;
-- Projeto original --
--175ms
--190ms
--144ms
-- Projeto modificado --
-- 156ms
-- 157ms
-- 156ms

--T2.
explain analyze 
select alocado.* from alocado where exists (select 1 from emp 
where emp.codemp = alocado.codemp and vlsalario >= 1300);
-- Projeto original --
--182ms
--174ms
--197ms
-- Projeto modificado --
-- 149ms
-- 175ms
-- 147ms

--T3.
explain analyze 
select * from depto inner join proj on (depto.coddepto = proj.coddepto) 
where depto.coddepto between 10 and 100;
-- Projeto original --
-- 17ms
-- 22ms
-- 12ms
-- Projeto modificado --
-- 15ms
-- 15ms
-- 15ms

--T4. 
--vou selecionar alguns atributos de emp e alocado para completar a query
select * from public.emp where codemp = 1
select * from alocado
explain analyze 
select emp.nmemp, alocado.qthoras from emp natural join alocado where codproj not in 
(select codproj from proj where nmlocal not in ('Buenos Aires', 'Montevideo', 'Sao Paulo', 'Campinas'));
-- Projeto original --
--152ms
--165ms
--141ms
-- Projeto modificado --
-- 137ms
-- 124ms
-- 147ms

--T5. 
--vou completar a query com codemp = 1
--alterei a condicao de join pois estava errada
explain analyze 
select * from emp inner join depto on (depto.coddepto = emp.coddepto) where codemp = 1; 
-- Projeto original --
-- 1ms
-- 1ms
-- 1ms
-- Projeto modificado --
-- 1ms
-- 1ms
-- 1ms

--T6. 
explain analyze 
select nmdepto, count(nmemp) from depto inner join emp on depto.coddepto = emp.coddepto 
group by nmdepto having count(nmemp) > 5
-- Projeto original --
--550ms
--596ms
--612ms
-- Projeto modificado --
-- 685ms
-- 670ms
-- 656ms

--T7. 
--inseri a condicao de join
-- codemp puxado da tabela emp
explain analyze 
select emp.codemp, nmdepte from emp inner join depte on (emp.codemp = depte.codemp) 
where tpparentesco in ('Filho(a)', 'Esposa')
-- Projeto original --
-- 24ms
-- 19ms
-- 16ms
-- Projeto modificado --
-- 18ms
-- 19ms
-- 28ms

--T8. 
select * from depte
--tabela depte nao possui coddepte, substituido por nrosequencia
--adicionado nmdepro ao group by
explain analyze 
select nmdepto, count(depte.nrosequencia) from depto inner join emp on depto.coddepto = emp.coddepto 
inner join depte on depte.codemp = emp.codemp group by depte.codemp, nmdepto
-- Projeto original --
-- 104ms
-- 78ms
-- 82ms
-- Projeto modificado --
-- 58ms
-- 63ms
-- 61ms