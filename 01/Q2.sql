set work_mem = '64kB';

-- Devido a diferença na escala o planning time foi ignorado em todas as execuções
-- As casas decimais do execution time também foram ignoradas

--T1
explain analyse select alocado.* from alocado inner join emp on (alocado.codemp = emp.codemp) where vlsalario >= 1300;
-- tempo1: 87
-- tempo2: 86
-- tempo3: 88
-- média:

--T2
explain analyse select alocado.* from alocado where codemp not in (select codemp from emp where vlsalario < 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T3
explain analyse select alocado.* from alocado where codemp in (select codemp from emp where vlsalario >= 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T4
explain analyse select alocado.* from alocado where not exists (select 1 from emp where emp.codemp = alocado.codemp and vlsalario < 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T5
explain analyse select alocado.* from alocado where exists (select 1 from emp where emp.codemp = alocado.codemp and vlsalario >= 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:

--T6
explain analyse with DP as (select codemp from emp where vlsalario >= 1300) select alocado.* from alocado inner join DP on (alocado.codemp = DP.codemp);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:

--T7
explain analyse select alocado.codemp from (select codemp from emp where vlsalario >= 1300) D inner join alocado on (d.codemp = alocado.codemp)
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

set work_mem = '1MB';
--T1
explain analyse select alocado.* from alocado inner join emp on (alocado.codemp = emp.codemp) where vlsalario >= 1300;
-- tempo1:
-- tempo2:
-- tempo3:
-- média:

--T2
explain analyse select alocado.* from alocado where codemp not in (select codemp from emp where vlsalario < 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T3
explain analyse select alocado.* from alocado where codemp in (select codemp from emp where vlsalario >= 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T4
explain analyse select alocado.* from alocado where not exists (select 1 from emp where emp.codemp = alocado.codemp and vlsalario < 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  

--T5
explain analyse select alocado.* from alocado where exists (select 1 from emp where emp.codemp = alocado.codemp and vlsalario >= 1300);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:

--T6
explain analyse with DP as (select codemp from emp where vlsalario >= 1300) select alocado.* from alocado inner join DP on (alocado.codemp = DP.codemp);
-- tempo1:
-- tempo2:
-- tempo3:
-- média:

--T7
explain analyse select alocado.codemp from (select codemp from emp where vlsalario >= 1300) D inner join alocado on (d.codemp = alocado.codemp)
-- tempo1:
-- tempo2:
-- tempo3:
-- média:  