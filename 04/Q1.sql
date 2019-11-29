--	PASSO (1) 
--	(1.1) Cria Relação Rel 

	CREATE TABLE Rel (
	att1	 INTEGER NOT NULL,     -- 4 bytes preenchidos  8 bytes fixo 
	att2	 INTEGER NOT NULL,     -- 4 bytes preenchidos
	att3	 INTEGER null,         -- 4 bytes 20%
	att4 	 VARCHAR(300) NOT NULL -- 0 - 300 bytes variaveis
	) with (fillfactor = 95); 
	
--	PASSO (2) 
--	(2.1) Acrescenta dados atuais de Rel 

	INSERT INTO Rel
		SELECT 	generate_series,
			floor(random() * 50000 + 1)::int,
			Null,
			substr(concat(md5(random()::text), md5(random()::text)), 0, (random() * 221 + 1)::int)
		from 	generate_series(1,60000);

--	(2.2) Atualiza dados atuais de Rel, att3

	update rel set att3 = floor(random() * 5000000 + 1)::int where att1 in
						  ( select floor(random() * 50000 + 1)::int from generate_series (1,40000) )
						  
--60000
--27531 att3 is not null 45%

-- media de preenchimento do att4
select avg(length(att4)) from rel
--0 - 67

select current_setting('block_size')
--tamanho da pagina: 8192

--calculo
-- 8 bytes fixos
-- 304 bytes variaveis com media de preeenchimento de 304/69 -> 23%
8 + (304 * 23%) = 77.9
8192/77.9 + 3 = 101.26 tuplas


