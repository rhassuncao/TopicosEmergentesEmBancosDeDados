

/* 1 passo */
CREATE TABLE Emp (
  CodEmp INTEGER NOT NULL,
  CodEmpGerente INTEGER,
  CodDepto INTEGER not null,
  NmEmp VARCHAR(30) NOT NULL,
  SnEmp VARCHAR(40) NOT NULL,
  DtNasc DATE NOT NULL,
  Ender VARCHAR(255) NOT NULL,
  CodSexo CHAR(1) NOT NULL,
  VlSalario REAL NOT NULL,
  constraint PK_emp PRIMARY KEY(CodEmp)
);


/* 2 passo */
CREATE TABLE Depto (
  CodDepto INTEGER NOT NULL,
  CodEmpResponsavel INTEGER,
  NmDepto VARCHAR(45) NOT NULL,
  NmLocalizacao VARCHAR(45) NOT NULL,
  constraint PK_Depto PRIMARY KEY(CodDepto),
  constraint FK_DEPTO FOREIGN KEY(CodEmpResponsavel)
    REFERENCES Emp(CodEmp)
) with (fillfactor = 90);


alter table Emp add
  constraint FK_EMP FOREIGN KEY(CodDepto)
    REFERENCES Depto(CodDepto);

/* 3 passo */
CREATE TABLE Depte (
  NroSequencia 	INTEGER NOT 	NULL,
  CodEmp 	INTEGER NOT 	NULL,
  NmDepte 	VARCHAR(100) 	NOT NULL,
  TpParentesco 	CHAR(25) 	not NULL,
  DtNasc 	date not NULL,
  CodSexo 	CHAR(1) not NULL CHECK (codsexo in ('m', 'f')),
  NroCPF  	VARCHAR(30) 	null,
  NroRG	  	VARCHAR(30) 	NULL,	  
  NroPIS 	CHAR(30)	NULL,  
  constraint 	PK_Depte PRIMARY KEY(CodEmp, NroSequencia),
  constraint 	FK_depte FOREIGN KEY(CodEmp) REFERENCES Emp(CodEmp)
);

/* 4 passo */
CREATE TABLE Proj (
  CodProj INTEGER NOT NULL,
  CodDepto INTEGER NOT NULL,
  NmProj VARCHAR(60) NOT NULL,
  NmLocal VARCHAR(45) NOT NULL,
  constraint PK_Proj PRIMARY KEY(CodProj),
  constraint FK_PROJ FOREIGN KEY(CodDepto) REFERENCES Depto(CodDepto)
);


/* 5 passo */
CREATE TABLE Alocado (
  CodProj INTEGER NOT NULL,
  CodEmp INTEGER NOT NULL,
  QtHoras INTEGER NOT NULL,
  constraint PK_Alocado PRIMARY KEY(CodProj, CodEmp),
  constraint FK_Alocado_Proj FOREIGN KEY(CodProj) REFERENCES Proj(CodProj),
  constraint FK_alocado_Emp FOREIGN KEY(CodEmp) REFERENCES Emp(CodEmp)
);


/* 6 passo */
CREATE TABLE Consult (
  CodConsult INTEGER NOT NULL,
  CodDepto INTEGER NOT NULL,
  NmConsult VARCHAR(30) NOT NULL,
  SnConsult VARCHAR(40) NOT NULL,
  VlSalHora real,
  constraint PK_Conult PRIMARY KEY(CodConsult),
  constraint FK_Consult FOREIGN KEY(CodDepto) REFERENCES Depto(CodDepto)
);

/* Deptos */
INSERT INTO depto 
	SELECT 	generate_series, null, 
			substr(concat(md5(random()::text), md5(random()::text)), 0, 45),
		    CASE (RANDOM() * 4)::INT
      			WHEN 0 THEN 'São Paulo'
      			WHEN 1 THEN 'Uruguaiana'
      			WHEN 2 THEN 'Porto Alegre'
      			WHEN 3 THEN 'Campinas'
      			WHEN 4 THEN 'Santos'					  
    		END			  
    from 	generate_series(1,500);

create index idx_depto on depto using btree (coddepto);

/* Projeto */
INSERT INTO proj
	SELECT 	generate_series, floor(random() * 500 + 1)::int, 
			substr(concat(md5(random()::text), md5(random()::text)), 0, 55),
		    CASE (RANDOM() * 6)::INT
      			WHEN 0 THEN 'São Paulo'
      			WHEN 1 THEN 'Londres'
      			WHEN 2 THEN 'Porto Alegre'
      			WHEN 3 THEN 'Campinas'
      			WHEN 4 THEN 'Auckland'					  
      			WHEN 5 THEN 'Buenos Aires'					  
      			WHEN 6 THEN 'Montevideo'					  
			  END			  
    from 	generate_series(1,35000);

/* Consultores */ 
INSERT INTO consult
	SELECT 	generate_series, floor(random() * 500 + 1)::int, 
			substr(concat(md5(random()::text), md5(random()::text)), 0, 25),
			substr(concat(md5(random()::text), md5(random()::text)), 0, 35),
			(random() * 8900 + 1)::real
    from 	generate_series(1,400);
					  

/* Empregados */
INSERT INTO emp
	SELECT 	generate_series, null,
			floor(random() * 500 + 1)::int, 
			substr(concat(md5(random()::text), md5(random()::text)), 0, 28),
			substr(concat(md5(random()::text), md5(random()::text)), 0, 38),
			(timestamp '2000-01-01 20:00:00' + random() * (timestamp '1975-01-01 20:00:00' -
                   timestamp '1999-12-31 10:00:00'))::TIMESTAMP::DATE,
			substr(concat(md5(random()::text), md5(random()::text)), 0, 135),
		    CASE (RANDOM() * 1)::INT
      			WHEN 0 THEN 'M'
      			WHEN 1 THEN 'F'
    		END,			  
		    (random() * 8900 + 1)::real
    from 	generate_series(1,400000);


/* alocado */
INSERT INTO alocado
	SELECT 	distinct	floor(random() * 35000 + 1)::int,
			floor(random() * 40000 + 1)::int,
			0
from 	generate_series(1,80000);

update alocado set qthoras = floor(random() * 180 + 1)::int;


/* depto 2 */

update depto set codempresponsavel = (select codemp from emp where  emp.coddepto = depto.coddepto order by random() limit 1)
where  codempresponsavel is null;


/* Dependentes - PARTE I */
INSERT INTO depte
	SELECT 	generate_series, 
			floor(random() * 2000 + 1)::int, 
			substr(concat(md5(random()::text), md5(random()::text)), 0, 45),
		    CASE (RANDOM() * 3)::INT
      			WHEN 0 THEN 'Filho(a)'
      			WHEN 1 THEN 'Esposa(o)'
      			WHEN 2 THEN 'Pai'
      			WHEN 3 THEN 'Mãe'
  		 	END,			  
	 	  	(timestamp '2000-01-01 20:00:00' + random() * (timestamp '1990-01-01 20:00:00' -
                   timestamp '1999-12-31 10:00:00'))::TIMESTAMP::DATE,
		    CASE (RANDOM() * 1)::INT
      			WHEN 0 THEN 'm'
      			WHEN 1 THEN 'f'
       		    END,
		    substr(concat(md5(random()::text), md5(random()::text)), 0, 28),
		    substr(concat(md5(random()::text), md5(random()::text)), 0, 25),
  	    	    substr(concat(md5(random()::text), md5(random()::text)), 0, 12)
    from 	generate_series(1,28000);

/* Dependentes - PARTE II */
update depte set nroCPF = NULL where nrosequencia in
(select floor(random() * 28000 + 1)::int from generate_series(1,12000));

update depte set nroRG = NULL where nrosequencia in
(select floor(random() * 28000 + 1)::int from generate_series(1,14000));

update depte set nroPis = NULL where nrosequencia in
(select floor(random() * 28000 + 1)::int from generate_series(1,20000));

