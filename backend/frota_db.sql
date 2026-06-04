CREATE DATABASE IF NOT EXISTS frota_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE frota_db;

CREATE TABLE IF NOT EXISTS VEICULO (
  placa       VARCHAR(8)   PRIMARY KEY,
  modelo      VARCHAR(100) NOT NULL,
  ano         INT          NOT NULL,
  km_atual    INT          DEFAULT 0,
  status      ENUM('ativo','manutencao','inativo') DEFAULT 'ativo',
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS MOTORISTA (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(100) NOT NULL,
  cnh           VARCHAR(20)  NOT NULL UNIQUE,
  categoria_cnh VARCHAR(5),
  validade_cnh  DATE,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS OFICINA (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(100) NOT NULL,
  cidade        VARCHAR(80),
  telefone      VARCHAR(20),
  especialidade VARCHAR(100),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS MANUTENCAO (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  veiculo_placa  VARCHAR(8)   NOT NULL,
  oficina_id     INT          NOT NULL,
  data_entrada   DATE         NOT NULL,
  data_saida     DATE,
  descricao      TEXT,
  custo          DECIMAL(10,2),
  FOREIGN KEY (veiculo_placa) REFERENCES VEICULO(placa),
  FOREIGN KEY (oficina_id)    REFERENCES OFICINA(id)
);

INSERT IGNORE INTO VEICULO (placa, modelo, ano, km_atual, status) VALUES
  ('ABC-1234', 'Fiat Ducato',         2021, 48200,  'ativo'),
  ('DEF-5678', 'Mercedes Sprinter',   2019, 112400, 'manutencao'),
  ('GHI-9012', 'Volkswagen Delivery', 2022, 21800,  'ativo'),
  ('JKL-3456', 'Ford Cargo',          2017, 198000, 'inativo'),
  ('MNO-7890', 'Iveco Daily',         2020, 67300,  'ativo');

INSERT IGNORE INTO MOTORISTA (nome, cnh, categoria_cnh, validade_cnh) VALUES
  ('Carlos Silva',   '12345678901', 'D', '2026-08-15'),
  ('Ana Souza',      '98765432100', 'C', '2025-12-01'),
  ('Pedro Oliveira', '55544433322', 'E', '2027-03-20');

INSERT IGNORE INTO OFICINA (nome, cidade, telefone, especialidade) VALUES
  ('Oficina Central',    'Fortaleza', '(85) 3333-1111', 'Mecânica Geral'),
  ('Auto Center Norte',  'Fortaleza', '(85) 3333-2222', 'Elétrica'),
  ('Borracharia Rápida', 'Caucaia',   '(85) 3333-3333', 'Pneus e Suspensão');
