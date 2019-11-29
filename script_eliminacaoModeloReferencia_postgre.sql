alter table Emp drop constraint FK_EMP;
alter table depto drop constraint FK_depto;
alter table depte drop constraint  FK_depte;
alter table proj drop constraint  FK_proj;
alter table alocado drop constraint  FK_alocado_proj;
alter table alocado drop constraint  fk_alocado_emp;
alter table consult drop constraint  FK_consult;

drop index if exists idx_depto;

/* elimina as tabelas */
drop table if exists emp;
drop table if exists depto;
drop table if exists depte;
drop table if exists proj;
drop table if exists alocado;
drop table if exists consult;
