CREATE TABLE Rel (
	att1 INT,
	att2 NUMERIC,
	att3 NUMERIC
);

CREATE SEQUENCE seq_att1_rel
	INCREMENT 1
	MINVALUE 1
	MAXVALUE 600000
	START 1;
	
CREATE SEQUENCE seq_att2_rel
	INCREMENT 1
	MINVALUE 1
	MAXVALUE 600000
	START 1;
	
INSERT INTO Rel (att1, att2, att3)
	SELECT nextval('seq_att1_rel'), nextval('seq_att2_rel'), random()
	FROM generate_series(1,600000) s(i);
-- Verificação da criação dos dados:	
SELECT * FROM rel
--Desligar processamento paralelo:
SET max_parallel_workers_per_gather = 0;

--Configurar as queries em padrão
--P1. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 100003 and att2 =100003;
--P2. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 in (5, 1000, 2058, 3285) and att2 between 1 and 5000;
--P3. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 253879;
--P4. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 63 or att1 = 405282;
--P5. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 2019;
--P6. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 314165 or att2 = 2;

--1. Unico ındice composto I do tipo B+T ree para os atributos att1 e att2, nessa ordem;
CREATE INDEX idx_rel_att1_att2 ON rel USING btree (att1,att2);

--P1. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 100003 and att2 =100003;
--P2. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 in (5, 1000, 2058, 3285) and att2 between 1 and 5000;
--P3. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 253879;
--P4. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 63 or att1 = 405282;
--P5. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 2019;
--P6. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 314165 or att2 = 2;

--Drop os índices:
DROP INDEX idx_rel_att1_att2
--2. Dois ındices simples I1 e I2, ambos B+T ree, para o atributo att1 e att2;
CREATE INDEX idx_rel_att1_btree ON rel USING btree (att1);
CREATE INDEX idx_rel_att2_btree ON rel USING btree (att2);

--P1. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 100003 and att2 =100003;
--P2. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 in (5, 1000, 2058, 3285) and att2 between 1 and 5000;
--P3. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 253879;
--P4. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 63 or att1 = 405282;
--P5. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 2019;
--P6. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 314165 or att2 = 2;

DROP INDEX idx_rel_att1_btree
DROP INDEX idx_rel_att2_btree

--Um ındice composto I do tipo B+T ree para att1 e att2, e ındice simples BRIN para o atributo att2.
CREATE INDEX idx_rel_att1_att2 ON rel USING btree (att1,att2);
CREATE INDEX idx_rel_att2_brin ON rel USING BRIN (att2);

--P1. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 100003 and att2 =100003;
--P2. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 in (5, 1000, 2058, 3285) and att2 between 1 and 5000;
--P3. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 253879;
--P4. 
EXPLAIN ANALYSE SELECT * FROM Rel where att1 = 63 or att1 = 405282;
--P5. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 2019;
--P6. 
EXPLAIN ANALYSE SELECT * FROM Rel where att2 = 314165 or att2 = 2;