ALTER TABLE emp SET ( fillfactor = 58);
VACUUM FULL emp;

explain analyze select nmdepto, count(nmemp)
from depto inner join emp on depto.coddepto = emp.coddepto
group by nmdepto
having count(nmemp) > 5

--742
--720
--781 

create index idx_emp_coddepto on emp using btree (coddepto)

-- o indice não foi utilizado

drop index idx_emp_coddepto