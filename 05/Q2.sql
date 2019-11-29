/*T1*/
EXPLAIN ANALYSE
SELECT emp.codemp, nmdepte 
FROM emp 
INNER JOIN depte 
ON emp.codemp = depte.codemp  
WHERE tpparentesco in ('Filho(a)', 'Esposa') -- Execution time 8 ms
--1000 tuplas

/*T2*/ 
--SELECT * FROM depte
INSERT INTO Depte (nrosequencia,
		   codemp,
		   nmdepte,
		   tpparentesco,
		   dtnasc,
		   codsexo,
		   nrocpf,
		   nrorg,
		   nropis)
	     VALUES (1,
		     17886,
		     '73a68b1402d74a071f3d143245c7633c1732d3b9f6a0',
		     'Mãe',
		     '1997-03-03',
		     'f',
		     '41cf6235f361ebsdsdea9178d3e',
		     'd15bd3a9700d7e505761a9ba',
		     'e16dsedsdb7774e6');
/*T3*/
UPDATE Depte SET
       nmdepte ='73encurtado74a071f3d143245c7633c1732d3b9f6a0', 
       codemp= 1368,
       tpparentesco='Filha' 
WHERE NroSequencia=1 
      AND CodEmp=1369;
--1 tupla  
select * from depte where nrosequencia = 1;
--apenas 1 registro

/*T4*/
DELETE FROM Depte
       WHERE NroSequencia=3 
	     AND CodEmp=1785;
select * FROM Depte
       WHERE NroSequencia=3 
	     AND CodEmp=977;
--apenas 1 tupla
/*T5*/
UPDATE Depte 
      SET NroCPF ='41cebsdsAlTeRaDodea9178d3e', NroRG='AlTeRaDd15b505761a9ba',tpparentesco='Filho' 
      WHERE NroSequencia=1 
	    AND CodEmp=1369;
-- 1 tupla
select  * from Depte 
      WHERE NroSequencia=1 
	    AND CodEmp=1369;
--apenas 1 registro
	  
/*T6*/--SELECT * FROM depte
SELECT 
	emp.codemp
	,depte.tpparentesco
	,count(*) 
FROM emp INNER JOIN 
	depte on emp.codemp = depte.codemp where depte.codsexo = 'f'
GROUP BY 1,2;
--6389 tuplas

select * from depte;
select count(1) from depte;
--28000 tuplas

--tamanho da página
select current_setting('block_size');
--8192