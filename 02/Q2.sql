-- quais os �ndices destas tabelas?
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
--Dois motivos para nao criar um indice nessa rela��o
--1 a consulta retorna em tempo satisfat�rio
--2 segundo relat�rio a consulta � modificada com frequencia o que pode levar a
--delay em insert e update muito mais impactante do que o benef�cio no read

--T2. 
explain analyse select * from depto inner join emp on (depto.coddepto = emp.coddepto);
--351
--352
--422
--seq scan
--nao utilizou o index idx_depto

--Como das 3 transa��es essa � a de maior latencia vou tentar otimizar
-- vamos tentar criar um index btree em emp(coddepto)
create index idx_emp_coddepto on emp using btree (coddepto)
--360
--357
--338
-- n�o utilizou o index criado
drop index idx_emp_coddepto
-- vamos tentar criar um index brin em emp(coddepto)
create index idx_emp_coddepto on emp using brin (coddepto)
--352
--347
--351
-- n�o utilizou o index criado
drop index idx_emp_coddepto
-- decidiu-se nao criar nenhum indice nessa rela�ao

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
-- Devido a tempo satisfat�rio de busca e alto indice de atualiza��es
-- escolhemos nao criar nenhum �ndice para aperfei�oar as buscas
-- nesta rela��o

--Existem �ndices que podem ser utilizados e que nao est�o presentes no 
--schema atual? Caso afirmativo, qual � o ganho de desempenho e o 
--impacto (espa�o, etc.) desses �ndices?
-- devido aos resultados obtidos decidiu-se nao criar nenhum indice
-- para nenhuma das rela��es envolvidas nas transa��es avaliadas

--Existem �ndices que nao est�o contribuindo para as transa��es acima?
--R: sim o �ndice idx_depto n�o contribui com as transa��es T1 e T2 e tem
--baixo impacto em T3, por�m ele pode contribuir com outras transa��es 
--ainda n�o mencionadas e foi mantido.