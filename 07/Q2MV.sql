--peguei a query abaixo para teste
-- para este caso foi considerado o pior caso, onde todos os
-- atributos de emp são utilizados
explain analyze
select 
	  emp.*
	, depto.nmdepto
	, sum(1)
from emp
natural join depto
left join depte using(codemp)
group by 
	  codemp
	, depto.nmdepto
--1078ms
--1033ms
--1022ms
--media = 1044

create materialized view VW_Rel7 as
select 
	  emp.*
	, depto.nmdepto
	, sum(1)
from emp
natural join depto
left join depte using(codemp)
group by 
	  codemp
	, depto.nmdepto
--created in 2953ms

explain analyze select * from VW_Rel7
--120ms
--106ms
--106ms
--media = 111ms

-- como a informação é crítica entende-se que deve ser atualizada 
-- toda vez qualquer dado envolvido for atualizado

--atualizações mensais necessárias
-- ## Depto 
--modificações mensais = 1
--crescimento          = 0

select count(1) from emp
-- ## Emp
--modificações mensais = 0
--crescimento          = 2% * 400000 = 8000

select count(1) from depte
-- ## Depte
--modificações mensais = 90
--crescimento          = 1% * 28001 = 280

--tempo total gasto com atualizações de view materializada por mês
-- Quantidade de atualizações = 1 + 8000 + 90 + 280 = 8742
-- 8742 * 2953 = 25.815.126 (aprox. 430,25 min por mês)

--calculando um número de consultas a partir do qual seria viável
--a criação de um view materializada, em termos de tempo
-- chegamos a equação
-- 111 * x  + 25.815.126 = 1044 * x
-- com x = 27.669
-- ou numero de execução da consulta acima do valor de x começaria a valer
-- a pena a utilização de uma view materializada

-- outro fator é o tempo de atualização, de quase 3 segundos, nesse tempo a informação
-- estaria defasada