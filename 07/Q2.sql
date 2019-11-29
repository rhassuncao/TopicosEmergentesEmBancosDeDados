--peguei a query abaixo para teste
-- para este caso foi considerado o pior caso, onde todos os
-- atributos de emp s�o utilizados
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

--teste de redundancia de nmdepto
CREATE TABLE public.emp2
(
    codemp integer NOT NULL,
    codempgerente integer,
    coddepto integer NOT NULL,
    nmemp character varying(30) COLLATE pg_catalog."default" NOT NULL,
    snemp character varying(40) COLLATE pg_catalog."default" NOT NULL,
    dtnasc date NOT NULL,
    ender character varying(255) COLLATE pg_catalog."default" NOT NULL,
    codsexo character(1) COLLATE pg_catalog."default" NOT NULL,
    vlsalario real NOT NULL,
	nmdepto character varying(45) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_emp2 PRIMARY KEY (codemp),
    CONSTRAINT fk_emp2 FOREIGN KEY (coddepto)
        REFERENCES public.depto (coddepto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE,
    FILLFACTOR = 58,
    autovacuum_enabled = FALSE
)
TABLESPACE pg_default;

insert into emp2 select emp.*, depto.nmdepto from emp natural join depto

explain analyze
select 
	  emp2.*
	, sum(1)
from emp2
left join depte using(codemp)
group by 
	  codemp
-- 645ms
-- 698ms
-- 615ms

explain analyze select * from emp2
--m�dia 82ms

--teste de redundancia de nmdepto + sum
CREATE TABLE public.emp3
(
    codemp integer NOT NULL,
    codempgerente integer,
    coddepto integer NOT NULL,
    nmemp character varying(30) COLLATE pg_catalog."default" NOT NULL,
    snemp character varying(40) COLLATE pg_catalog."default" NOT NULL,
    dtnasc date NOT NULL,
    ender character varying(255) COLLATE pg_catalog."default" NOT NULL,
    codsexo character(1) COLLATE pg_catalog."default" NOT NULL,
    vlsalario real NOT NULL,
	nmdepto character varying(45) COLLATE pg_catalog."default" NOT NULL,
	deptes integer,
    CONSTRAINT pk_emp3 PRIMARY KEY (codemp),
    CONSTRAINT fk_emp3 FOREIGN KEY (coddepto)
        REFERENCES public.depto (coddepto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE,
    FILLFACTOR = 58,
    autovacuum_enabled = FALSE
)
TABLESPACE pg_default;

insert into emp3
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

explain analyze
select * from emp3
-- 86ms
-- 94ms
-- 83ms

-- teste de atualiza��o da quantidade de dependentes de 1 empregado
explain analyse update emp3 set deptes = 1 where codemp = 4
select * from emp3 where codemp = 4
-- menos de 1ms

select count(1) from emp
--400.000 registros
-- teste de atualiza��o do nome do departamento de 10000 empregados
explain analyse update emp3 set nmdepto = 'novoDepto' where codemp <= 10000
-- 132 ms

-- quantidade de atualiza��es no mes
-- ## depto = 1
-- ## atualizacao depte = 3 * 30 = 90 (por�m n�o afeta a consulta visto atualizar informacoes de um dependente n�o altera o sum)
select Count(1) * 0.0035 from depte
-- 98
-- ## crescimento de aprox 0,35% ao mes = 98
-- total = 132 + 98
-- tempo total perdido em atualizacoes no mes = 230ms

--dessa forma a desnormaliza��o com redundancia do nmdepto e com o numero 
-- de dependentes � uma �tima alternativa desde que se crie uma trigger de 
-- que a cada inser��o de um novo dependente ou a cada altera��o no nome do departamento
-- a tabela emp seja alterada
