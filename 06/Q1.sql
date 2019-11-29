--Criacao das tabelas

create table Produto (
	CodProduto integer PRIMARY KEY,
	DescProduto text NOT NULL,
	TipoProduto text NOT NULL
);

create table Cliente (
	CodCliente integer,
	NomeCliente text NOT NULL,
	EnderecoCliente text NOT NULL,
	UFCliente text NOT NULL,
	SituacaoCliente text NOT NULL,
	DataInicioRelacionamento timestamp NOT NULL,
	TelCelularCliente text,
	TelFixoCliente text,
	TelRecadoCliente text
) partition by list (SituacaoCliente);

CREATE TABLE Cliente_Ativo PARTITION OF Cliente FOR VALUES in ('1');
CREATE TABLE Cliente_Inativo PARTITION OF Cliente FOR VALUES in ('0');
CREATE TABLE Cliente_Outros PARTITION OF Cliente default;

create table NotaFiscal (
	NroNFiscal integer PRIMARY KEY,
	DataEmissao timestamp NOT NULL,
	CodCliente integer NOT NULL,
	SituacaoNotaFiscal text NOT NULL,
	CONSTRAINT NotaFical_CodCliente_Cliente FOREIGN KEY (CodCliente)
	REFERENCES Cliente (CodCliente)
);

create table NotaFiscalItem (
	NroNFiscal integer PRIMARY KEY,
	NroItem integer PRIMARY KEY,
	QtdeItem decimal (10,3) NOT NULL,
	CodProduto iteger NOT NULL,
	VlImpostos decimal(10,2) NOT NULL,
	CONSTRAINT NotaFicalItem_NroNFiscal_NotaFiscal FOREIGN KEY (NroNFiscal)
	REFERENCES NotaFiscal (NroFiscal),
	CONSTRAINT NotaFical_CodProduto_Produto FOREIGN KEY (CodProduto)
	REFERENCES Produto (CodProduto)
);