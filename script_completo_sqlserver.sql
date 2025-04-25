-- Script SQL completo para o Sistema de Vendas (SQL Server)
-- Missão Prática - Nível 2 - Mundo 3
-- Versão final com todas as correções

-- Primeiro, verificar se o banco de dados existe e criá-lo se necessário
USE master;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'sistema_vendas')
BEGIN
    CREATE DATABASE sistema_vendas;
END
GO

USE sistema_vendas;
GO

-- Remover tabelas existentes se necessário (em ordem inversa de dependência)
IF OBJECT_ID('movimentos', 'U') IS NOT NULL
    DROP TABLE movimentos;

IF OBJECT_ID('pessoas_fisicas', 'U') IS NOT NULL
    DROP TABLE pessoas_fisicas;

IF OBJECT_ID('pessoas_juridicas', 'U') IS NOT NULL
    DROP TABLE pessoas_juridicas;

IF OBJECT_ID('produtos', 'U') IS NOT NULL
    DROP TABLE produtos;

IF OBJECT_ID('pessoas', 'U') IS NOT NULL
    DROP TABLE pessoas;

IF OBJECT_ID('usuarios', 'U') IS NOT NULL
    DROP TABLE usuarios;

-- Criação da tabela de usuários (operadores)
CREATE TABLE usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    login VARCHAR(20) NOT NULL UNIQUE,
    senha VARCHAR(20) NOT NULL
);

-- Criação da tabela de pessoas
CREATE TABLE pessoas (
    id_pessoa INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200),
    telefone VARCHAR(20),
    email VARCHAR(100),
    tipo CHAR(1) NOT NULL CHECK (tipo IN ('F', 'J'))
);

-- Criação da tabela de pessoas físicas (herança)
CREATE TABLE pessoas_fisicas (
    id_pessoa INT PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
);

-- Criação da tabela de pessoas jurídicas (herança)
CREATE TABLE pessoas_juridicas (
    id_pessoa INT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa)
);

-- Criação da tabela de produtos
CREATE TABLE produtos (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    preco_venda DECIMAL(10,2) NOT NULL
);

-- Criação da tabela de movimentos (compra e venda)
CREATE TABLE movimentos (
    id_movimento INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_pessoa INT NOT NULL,
    id_produto INT NOT NULL,
    tipo CHAR(1) NOT NULL CHECK (tipo IN ('E', 'S')),
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    data DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_pessoa) REFERENCES pessoas(id_pessoa),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Inserção de usuários (operadores)
INSERT INTO usuarios (nome, login, senha) VALUES 
('Operador 1', 'op1', 'op1'),
('Operador 2', 'op2', 'op2');

-- Inserção de pessoas
-- Pessoas físicas
INSERT INTO pessoas (nome, endereco, telefone, email, tipo) VALUES
('João Silva', 'Rua A, 123', '(11) 98765-4321', 'joao@email.com', 'F'),
('Maria Oliveira', 'Av. B, 456', '(11) 91234-5678', 'maria@email.com', 'F'),
('Carlos Santos', 'Rua C, 789', '(11) 99876-5432', 'carlos@email.com', 'F');

-- Pessoas jurídicas
INSERT INTO pessoas (nome, endereco, telefone, email, tipo) VALUES
('Empresa ABC Ltda', 'Av. Empresarial, 1000', '(11) 3333-4444', 'contato@abc.com', 'J'),
('Distribuidora XYZ', 'Rua Comercial, 500', '(11) 2222-3333', 'vendas@xyz.com', 'J');

-- Inserção de pessoas físicas
-- Precisamos obter os IDs gerados pelo IDENTITY
DECLARE @id_joao INT, @id_maria INT, @id_carlos INT;
SELECT @id_joao = id_pessoa FROM pessoas WHERE nome = 'João Silva';
SELECT @id_maria = id_pessoa FROM pessoas WHERE nome = 'Maria Oliveira';
SELECT @id_carlos = id_pessoa FROM pessoas WHERE nome = 'Carlos Santos';

INSERT INTO pessoas_fisicas (id_pessoa, cpf) VALUES
(@id_joao, '123.456.789-00'),
(@id_maria, '987.654.321-00'),
(@id_carlos, '111.222.333-44');

-- Inserção de pessoas jurídicas
DECLARE @id_empresa INT, @id_distribuidora INT;
SELECT @id_empresa = id_pessoa FROM pessoas WHERE nome = 'Empresa ABC Ltda';
SELECT @id_distribuidora = id_pessoa FROM pessoas WHERE nome = 'Distribuidora XYZ';

INSERT INTO pessoas_juridicas (id_pessoa, cnpj) VALUES
(@id_empresa, '12.345.678/0001-90'),
(@id_distribuidora, '98.765.432/0001-10');

-- Inserção de produtos
INSERT INTO produtos (nome, quantidade, preco_venda) VALUES
('Notebook', 0, 3500.00),
('Smartphone', 0, 1800.00),
('Monitor', 0, 950.00),
('Teclado', 0, 120.00),
('Mouse', 0, 80.00);

-- Inserção de movimentos de entrada (compra)
-- Compras são feitas apenas por pessoas jurídicas
-- Precisamos obter os IDs gerados pelo IDENTITY
DECLARE @id_notebook INT, @id_smartphone INT, @id_monitor INT, @id_teclado INT, @id_mouse INT;
DECLARE @id_op1 INT, @id_op2 INT;

SELECT @id_notebook = id_produto FROM produtos WHERE nome = 'Notebook';
SELECT @id_smartphone = id_produto FROM produtos WHERE nome = 'Smartphone';
SELECT @id_monitor = id_produto FROM produtos WHERE nome = 'Monitor';
SELECT @id_teclado = id_produto FROM produtos WHERE nome = 'Teclado';
SELECT @id_mouse = id_produto FROM produtos WHERE nome = 'Mouse';

SELECT @id_op1 = id_usuario FROM usuarios WHERE login = 'op1';
SELECT @id_op2 = id_usuario FROM usuarios WHERE login = 'op2';

-- Usando formato de data ISO 8601 com CONVERT para garantir compatibilidade
INSERT INTO movimentos (id_usuario, id_pessoa, id_produto, tipo, quantidade, preco_unitario, data) VALUES
(@id_op1, @id_empresa, @id_notebook, 'E', 10, 3000.00, CONVERT(DATETIME, '2025-04-01T10:00:00', 126)),
(@id_op1, @id_distribuidora, @id_smartphone, 'E', 15, 1500.00, CONVERT(DATETIME, '2025-04-02T11:30:00', 126)),
(@id_op2, @id_empresa, @id_monitor, 'E', 8, 800.00, CONVERT(DATETIME, '2025-04-03T14:15:00', 126)),
(@id_op2, @id_distribuidora, @id_teclado, 'E', 20, 100.00, CONVERT(DATETIME, '2025-04-04T09:45:00', 126)),
(@id_op1, @id_empresa, @id_mouse, 'E', 25, 60.00, CONVERT(DATETIME, '2025-04-05T16:20:00', 126));

-- Inserção de movimentos de saída (venda)
-- Vendas são feitas apenas para pessoas físicas
INSERT INTO movimentos (id_usuario, id_pessoa, id_produto, tipo, quantidade, preco_unitario, data) VALUES
(@id_op1, @id_joao, @id_notebook, 'S', 2, 3500.00, CONVERT(DATETIME, '2025-04-10T13:30:00', 126)),
(@id_op2, @id_maria, @id_smartphone, 'S', 1, 1800.00, CONVERT(DATETIME, '2025-04-11T15:45:00', 126)),
(@id_op1, @id_carlos, @id_monitor, 'S', 3, 950.00, CONVERT(DATETIME, '2025-04-12T10:15:00', 126)),
(@id_op2, @id_joao, @id_teclado, 'S', 5, 120.00, CONVERT(DATETIME, '2025-04-13T14:00:00', 126)),
(@id_op1, @id_maria, @id_mouse, 'S', 4, 80.00, CONVERT(DATETIME, '2025-04-14T11:30:00', 126));

-- Atualização das quantidades em estoque dos produtos
UPDATE produtos SET quantidade = 8 WHERE id_produto = @id_notebook;  -- 10 entradas - 2 saídas
UPDATE produtos SET quantidade = 14 WHERE id_produto = @id_smartphone; -- 15 entradas - 1 saída
UPDATE produtos SET quantidade = 5 WHERE id_produto = @id_monitor;  -- 8 entradas - 3 saídas
UPDATE produtos SET quantidade = 15 WHERE id_produto = @id_teclado; -- 20 entradas - 5 saídas
UPDATE produtos SET quantidade = 21 WHERE id_produto = @id_mouse; -- 25 entradas - 4 saídas

-- Consultas solicitadas na missão prática

-- 1. Dados completos de pessoas físicas
SELECT p.id_pessoa, p.nome, p.endereco, p.telefone, p.email, pf.cpf
FROM pessoas p
INNER JOIN pessoas_fisicas pf ON p.id_pessoa = pf.id_pessoa;

-- 2. Dados completos de pessoas jurídicas
SELECT p.id_pessoa, p.nome, p.endereco, p.telefone, p.email, pj.cnpj
FROM pessoas p
INNER JOIN pessoas_juridicas pj ON p.id_pessoa = pj.id_pessoa;

-- 3. Movimentações de entrada, com produto, fornecedor, quantidade, preço unitário e valor total
SELECT m.id_movimento, p.nome AS fornecedor, pj.cnpj, pr.nome AS produto, 
       m.quantidade, m.preco_unitario, (m.quantidade * m.preco_unitario) AS valor_total, m.data
FROM movimentos m
INNER JOIN pessoas p ON m.id_pessoa = p.id_pessoa
INNER JOIN pessoas_juridicas pj ON p.id_pessoa = pj.id_pessoa
INNER JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'E'
ORDER BY m.data;

-- 4. Movimentações de saída, com produto, comprador, quantidade, preço unitário e valor total
SELECT m.id_movimento, p.nome AS comprador, pf.cpf, pr.nome AS produto, 
       m.quantidade, m.preco_unitario, (m.quantidade * m.preco_unitario) AS valor_total, m.data
FROM movimentos m
INNER JOIN pessoas p ON m.id_pessoa = p.id_pessoa
INNER JOIN pessoas_fisicas pf ON p.id_pessoa = pf.id_pessoa
INNER JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'S'
ORDER BY m.data;

-- 5. Valor total das entradas agrupadas por produto
SELECT pr.id_produto, pr.nome AS produto, 
       SUM(m.quantidade) AS quantidade_total,
       SUM(m.quantidade * m.preco_unitario) AS valor_total
FROM movimentos m
INNER JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'E'
GROUP BY pr.id_produto, pr.nome
ORDER BY valor_total DESC;

-- 6. Valor total das saídas agrupadas por produto
SELECT pr.id_produto, pr.nome AS produto, 
       SUM(m.quantidade) AS quantidade_total,
       SUM(m.quantidade * m.preco_unitario) AS valor_total
FROM movimentos m
INNER JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'S'
GROUP BY pr.id_produto, pr.nome
ORDER BY valor_total DESC;

-- 7. Operadores que não efetuaram movimentações de entrada (compra)
SELECT u.id_usuario, u.nome
FROM usuarios u
WHERE u.id_usuario NOT IN (
    SELECT DISTINCT id_usuario FROM movimentos WHERE tipo = 'E'
);

-- 8. Valor total de entrada, agrupado por operador
SELECT u.id_usuario, u.nome, 
       SUM(m.quantidade * m.preco_unitario) AS valor_total
FROM movimentos m
INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
WHERE m.tipo = 'E'
GROUP BY u.id_usuario, u.nome
ORDER BY valor_total DESC;

-- 9. Valor total de saída, agrupado por operador
SELECT u.id_usuario, u.nome, 
       SUM(m.quantidade * m.preco_unitario) AS valor_total
FROM movimentos m
INNER JOIN usuarios u ON m.id_usuario = u.id_usuario
WHERE m.tipo = 'S'
GROUP BY u.id_usuario, u.nome
ORDER BY valor_total DESC;

-- 10. Valor médio de venda por produto, utilizando média ponderada
SELECT pr.id_produto, pr.nome AS produto,
       SUM(m.quantidade * m.preco_unitario) / SUM(m.quantidade) AS preco_medio_venda
FROM movimentos m
INNER JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'S'
GROUP BY pr.id_produto, pr.nome
ORDER BY preco_medio_venda DESC;
