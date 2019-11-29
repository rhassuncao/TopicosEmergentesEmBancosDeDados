--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

-- Started on 2019-11-27 11:59:14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 217 (class 1255 OID 16397)
-- Name: modeloTabelas(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public."modeloTabelas"()
    LANGUAGE sql
    AS $$/* 1 passo */
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
);$$;


ALTER PROCEDURE public."modeloTabelas"() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 200 (class 1259 OID 16440)
-- Name: alocado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alocado (
    codproj integer NOT NULL,
    codemp integer NOT NULL,
    qthoras integer NOT NULL
);


ALTER TABLE public.alocado OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16455)
-- Name: consult; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consult (
    codconsult integer NOT NULL,
    coddepto integer NOT NULL,
    nmconsult character varying(30) NOT NULL,
    snconsult character varying(40) NOT NULL,
    vlsalhora real
);


ALTER TABLE public.consult OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 16419)
-- Name: depte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depte (
    nrosequencia integer NOT NULL,
    codemp integer NOT NULL,
    nmdepte character varying(100) NOT NULL,
    tpparentesco character(25) NOT NULL,
    dtnasc date NOT NULL,
    codsexo character(1) NOT NULL,
    nrocpf character varying(30),
    nrorg character varying(30),
    nropis character(30),
    CONSTRAINT depte_codsexo_check CHECK ((codsexo = ANY (ARRAY['m'::bpchar, 'f'::bpchar])))
);


ALTER TABLE public.depte OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16404)
-- Name: depto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depto (
    coddepto integer NOT NULL,
    codempresponsavel integer,
    nmdepto character varying(45) NOT NULL,
    nmlocalizacao character varying(45) NOT NULL
)
WITH (fillfactor='90');


ALTER TABLE public.depto OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 16399)
-- Name: emp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emp (
    codemp integer NOT NULL,
    codempgerente integer,
    coddepto integer NOT NULL,
    nmemp character varying(30) NOT NULL,
    snemp character varying(40) NOT NULL,
    dtnasc date NOT NULL,
    ender character varying(255) NOT NULL,
    codsexo character(1) NOT NULL,
    vlsalario real NOT NULL
)
WITH (fillfactor='58');


ALTER TABLE public.emp OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 25095)
-- Name: emp2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emp2 (
    codemp integer NOT NULL,
    codempgerente integer,
    coddepto integer NOT NULL,
    nmemp character varying(30) NOT NULL,
    snemp character varying(40) NOT NULL,
    dtnasc date NOT NULL,
    ender character varying(255) NOT NULL,
    codsexo character(1) NOT NULL,
    vlsalario real NOT NULL,
    nmdepto character varying(45) NOT NULL
)
WITH (fillfactor='58', autovacuum_enabled='false');


ALTER TABLE public.emp2 OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 25108)
-- Name: emp3; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emp3 (
    codemp integer NOT NULL,
    codempgerente integer,
    coddepto integer NOT NULL,
    nmemp character varying(30) NOT NULL,
    snemp character varying(40) NOT NULL,
    dtnasc date NOT NULL,
    ender character varying(255) NOT NULL,
    codsexo character(1) NOT NULL,
    vlsalario real NOT NULL,
    nmdepto character varying(45) NOT NULL,
    deptes integer
)
WITH (fillfactor='58', autovacuum_enabled='false');


ALTER TABLE public.emp3 OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 16430)
-- Name: proj; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proj (
    codproj integer NOT NULL,
    coddepto integer NOT NULL,
    nmproj character varying(60) NOT NULL,
    nmlocal character varying(45) NOT NULL
);


ALTER TABLE public.proj OWNER TO postgres;

--
-- TOC entry 2718 (class 2606 OID 16403)
-- Name: emp pk_emp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp
    ADD CONSTRAINT pk_emp PRIMARY KEY (codemp);


--
-- TOC entry 202 (class 1259 OID 25072)
-- Name: vw_rel7; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.vw_rel7 AS
 SELECT emp.codemp,
    emp.codempgerente,
    emp.coddepto,
    emp.nmemp,
    emp.snemp,
    emp.dtnasc,
    emp.ender,
    emp.codsexo,
    emp.vlsalario,
    depto.nmdepto,
    sum(1) AS sum
   FROM ((public.emp
     JOIN public.depto USING (coddepto))
     LEFT JOIN public.depte USING (codemp))
  GROUP BY emp.codemp, depto.nmdepto
  WITH NO DATA;


ALTER TABLE public.vw_rel7 OWNER TO postgres;

--
-- TOC entry 2728 (class 2606 OID 16444)
-- Name: alocado pk_alocado; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alocado
    ADD CONSTRAINT pk_alocado PRIMARY KEY (codproj, codemp);


--
-- TOC entry 2730 (class 2606 OID 16459)
-- Name: consult pk_conult; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consult
    ADD CONSTRAINT pk_conult PRIMARY KEY (codconsult);


--
-- TOC entry 2724 (class 2606 OID 16424)
-- Name: depte pk_depte; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depte
    ADD CONSTRAINT pk_depte PRIMARY KEY (codemp, nrosequencia);


--
-- TOC entry 2721 (class 2606 OID 16408)
-- Name: depto pk_depto; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depto
    ADD CONSTRAINT pk_depto PRIMARY KEY (coddepto);


--
-- TOC entry 2732 (class 2606 OID 25099)
-- Name: emp2 pk_emp2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp2
    ADD CONSTRAINT pk_emp2 PRIMARY KEY (codemp);


--
-- TOC entry 2734 (class 2606 OID 25112)
-- Name: emp3 pk_emp3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp3
    ADD CONSTRAINT pk_emp3 PRIMARY KEY (codemp);


--
-- TOC entry 2726 (class 2606 OID 16434)
-- Name: proj pk_proj; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proj
    ADD CONSTRAINT pk_proj PRIMARY KEY (codproj);


--
-- TOC entry 2722 (class 1259 OID 25081)
-- Name: idx_dependente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dependente ON public.depte USING btree (codemp);


--
-- TOC entry 2719 (class 1259 OID 16465)
-- Name: idx_depto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_depto ON public.depto USING btree (coddepto);


--
-- TOC entry 2740 (class 2606 OID 16450)
-- Name: alocado fk_alocado_emp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alocado
    ADD CONSTRAINT fk_alocado_emp FOREIGN KEY (codemp) REFERENCES public.emp(codemp);


--
-- TOC entry 2739 (class 2606 OID 16445)
-- Name: alocado fk_alocado_proj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alocado
    ADD CONSTRAINT fk_alocado_proj FOREIGN KEY (codproj) REFERENCES public.proj(codproj);


--
-- TOC entry 2741 (class 2606 OID 16460)
-- Name: consult fk_consult; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consult
    ADD CONSTRAINT fk_consult FOREIGN KEY (coddepto) REFERENCES public.depto(coddepto);


--
-- TOC entry 2737 (class 2606 OID 16425)
-- Name: depte fk_depte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depte
    ADD CONSTRAINT fk_depte FOREIGN KEY (codemp) REFERENCES public.emp(codemp);


--
-- TOC entry 2736 (class 2606 OID 16409)
-- Name: depto fk_depto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depto
    ADD CONSTRAINT fk_depto FOREIGN KEY (codempresponsavel) REFERENCES public.emp(codemp);


--
-- TOC entry 2735 (class 2606 OID 16414)
-- Name: emp fk_emp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp
    ADD CONSTRAINT fk_emp FOREIGN KEY (coddepto) REFERENCES public.depto(coddepto);


--
-- TOC entry 2742 (class 2606 OID 25100)
-- Name: emp2 fk_emp2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp2
    ADD CONSTRAINT fk_emp2 FOREIGN KEY (coddepto) REFERENCES public.depto(coddepto);


--
-- TOC entry 2743 (class 2606 OID 25113)
-- Name: emp3 fk_emp3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emp3
    ADD CONSTRAINT fk_emp3 FOREIGN KEY (coddepto) REFERENCES public.depto(coddepto);


--
-- TOC entry 2738 (class 2606 OID 16435)
-- Name: proj fk_proj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proj
    ADD CONSTRAINT fk_proj FOREIGN KEY (coddepto) REFERENCES public.depto(coddepto);


-- Completed on 2019-11-27 11:59:14

--
-- PostgreSQL database dump complete
--

