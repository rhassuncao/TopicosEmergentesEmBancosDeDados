-- quais os índices destas tabelas?
SELECT
    tablename, indexname, indexdef
FROM
    pg_indexes
WHERE
    tablename in ('depto', 'proj', 'emp');
-- tirando as PK's o unico index idx_depto
-- CREATE INDEX idx_depto ON public.depto USING btree (coddepto)

--T1. 
explain analyse select * from depto inner join proj on (depto.coddepto = proj.coddepto);
--48
--31
--25
--seq scan
--nao utilizou o index idx_depto
--Dois motivos para nao criar um indice nessa relação
--1 a consulta retorna em tempo satisfatório
--2 segundo relatório a consulta é modificada com frequencia o que pode levar a
--delay em insert e update muito mais impactante do que o benefício no read

--T2. 
explain analyse select * from depto inner join emp on (depto.coddepto = emp.coddepto);
--351
--352
--422
--seq scan
--nao utilizou o index idx_depto

--Como das 3 transações essa é a de maior latencia vou tentar otimizar
-- vamos tentar criar um index btree em emp(coddepto)
create index idx_emp_coddepto on emp using btree (coddepto)
--360
--357
--338
-- não utilizou o index criado
drop index idx_emp_coddepto
-- vamos tentar criar um index brin em emp(coddepto)
create index idx_emp_coddepto on emp using brin (coddepto)
--352
--347
--351
-- não utilizou o index criado
drop index idx_emp_coddepto
-- decidiu-se nao criar nenhum indice nessa relaçao

--T3.
--Quantos depto.coddepto existem?
select max(coddepto) from depto
--500

explain analyse 
	select * from depto inner join proj on (depto.coddepto = proj.coddepto) 
	where depto.coddepto between 1 and 100;
-- between 1 and 100 15 ms Bitmap index scan on idx_depto
-- between 1 and 200 15 ms seq scan
-- between 1 and 300 20 ms seq scan
-- between 1 and 400 20 ms seq scan
-- between 1 and 500 22 ms seq scan
-- Devido a tempo satisfatório de busca e alto indice de atualizações
-- escolhemos nao criar nenhum índice para aperfeiçoar as buscas
-- nesta relação

--Existem índices que podem ser utilizados e que nao estão presentes no 
--schema atual? Caso afirmativo, qual é o ganho de desempenho e o 
--impacto (espaço, etc.) desses índices?
-- devido aos resultados obtidos decidiu-se nao criar nenhum indice
-- para nenhuma das relações envolvidas nas transações avaliadas

--Existem índices que nao estão contribuindo para as transações acima?
--R: sim o índice idx_depto não contribui com as transações T1 e T2 e tem
--baixo impacto em T3, porém ele pode contribuir com outras transações 
--ainda não mencionadas e foi mantido.