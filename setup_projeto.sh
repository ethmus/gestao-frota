#!/bin/bash
set -e

BASE="/tmp/gestao-frota"
mkdir -p $BASE/docs/u1 $BASE/docs/u2 $BASE/docs/u3 $BASE/docs/u4 $BASE/docs/u5 $BASE/docs/assets
mkdir -p $BASE/backend/routes $BASE/backend/controllers $BASE/backend/models $BASE/backend/middlewares

# .gitignore
cat > $BASE/.gitignore << 'EOF'
node_modules/
backend/.env
.DS_Store
*.log
EOF

# README
cat > $BASE/README.md << 'EOF'
# Gestão de Frota — Projeto Demonstrativo DW2

Projeto desenvolvido como material de apoio para a disciplina **Desenvolvimento Web 2** do curso de Informática para Internet do IFCE.

## Acesse o site
👉 https://ethmus.github.io/gestao-frota/

## Stack
- Front-end: HTML, CSS, JavaScript puro (GitHub Pages)
- Back-end: Node.js, Express, MySQL (Railway)
EOF

# backend/package.json
cat > $BASE/backend/package.json << 'EOF'
{
  "name": "gestao-frota-api",
  "version": "1.0.0",
  "description": "API REST do Sistema de Gestão de Frota — DW2 IFCE",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.18.2",
    "mysql2": "^3.6.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# backend/.env.example
cat > $BASE/backend/.env.example << 'EOF'
DB_HOST=
DB_PORT=3306
DB_USER=
DB_PASSWORD=
DB_NAME=frota_db
PORT=3000
EOF

# backend/app.js
cat > $BASE/backend/app.js << 'EOF'
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/v1/veiculos',    require('./routes/veiculoRoutes'));
app.use('/api/v1/motoristas',  require('./routes/motoristaRoutes'));
app.use('/api/v1/oficinas',    require('./routes/oficinaRoutes'));
app.use('/api/v1/manutencoes', require('./routes/manutencaoRoutes'));

app.get('/', (req, res) => {
  res.json({ status: 'ok', sistema: 'Gestão de Frota API', versao: '1.0.0' });
});

app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando na porta ${PORT}`));
EOF

# backend/middlewares/db.js
cat > $BASE/backend/middlewares/db.js << 'EOF'
const mysql = require('mysql2/promise');

const db = mysql.createPool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT || 3306,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10
});

module.exports = db;
EOF

# backend/models/veiculoModel.js
cat > $BASE/backend/models/veiculoModel.js << 'EOF'
const db = require('../middlewares/db');

const listar = async () => {
  const [rows] = await db.execute('SELECT * FROM VEICULO ORDER BY placa');
  return rows;
};

const buscarPorPlaca = async (placa) => {
  const [rows] = await db.execute('SELECT * FROM VEICULO WHERE placa = ?', [placa]);
  return rows[0] || null;
};

const criar = async ({ placa, modelo, ano, km_atual, status }) => {
  const [result] = await db.execute(
    'INSERT INTO VEICULO (placa, modelo, ano, km_atual, status) VALUES (?, ?, ?, ?, ?)',
    [placa, modelo, ano, km_atual, status]
  );
  return result.affectedRows;
};

const atualizar = async (placa, { modelo, ano, km_atual, status }) => {
  const [result] = await db.execute(
    'UPDATE VEICULO SET modelo = ?, ano = ?, km_atual = ?, status = ? WHERE placa = ?',
    [modelo, ano, km_atual, status, placa]
  );
  return result.affectedRows;
};

const remover = async (placa) => {
  const [result] = await db.execute('DELETE FROM VEICULO WHERE placa = ?', [placa]);
  return result.affectedRows;
};

module.exports = { listar, buscarPorPlaca, criar, atualizar, remover };
EOF

# backend/controllers/veiculoController.js
cat > $BASE/backend/controllers/veiculoController.js << 'EOF'
const model = require('../models/veiculoModel');

const listar = async (req, res) => {
  try { res.json(await model.listar()); }
  catch (err) { res.status(500).json({ erro: err.message }); }
};

const buscarPorPlaca = async (req, res) => {
  try {
    const v = await model.buscarPorPlaca(req.params.placa);
    if (!v) return res.status(404).json({ erro: 'Veículo não encontrado' });
    res.json(v);
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const criar = async (req, res) => {
  const { placa, modelo, ano, km_atual, status } = req.body;
  if (!placa || !modelo || !ano) return res.status(400).json({ erro: 'placa, modelo e ano são obrigatórios' });
  try {
    await model.criar({ placa, modelo, ano, km_atual: km_atual || 0, status: status || 'ativo' });
    res.status(201).json({ mensagem: 'Veículo cadastrado com sucesso' });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const atualizar = async (req, res) => {
  try {
    const afetados = await model.atualizar(req.params.placa, req.body);
    if (!afetados) return res.status(404).json({ erro: 'Veículo não encontrado' });
    res.json({ mensagem: 'Veículo atualizado com sucesso' });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const remover = async (req, res) => {
  try {
    const afetados = await model.remover(req.params.placa);
    if (!afetados) return res.status(404).json({ erro: 'Veículo não encontrado' });
    res.json({ mensagem: 'Veículo removido com sucesso' });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

module.exports = { listar, buscarPorPlaca, criar, atualizar, remover };
EOF

# backend/routes/veiculoRoutes.js
cat > $BASE/backend/routes/veiculoRoutes.js << 'EOF'
const router = require('express').Router();
const ctrl   = require('../controllers/veiculoController');

router.get('/',          ctrl.listar);
router.get('/:placa',    ctrl.buscarPorPlaca);
router.post('/',         ctrl.criar);
router.put('/:placa',    ctrl.atualizar);
router.delete('/:placa', ctrl.remover);

module.exports = router;
EOF

# backend/models/motoristaModel.js
cat > $BASE/backend/models/motoristaModel.js << 'EOF'
const db = require('../middlewares/db');

const listar = async () => {
  const [rows] = await db.execute('SELECT * FROM MOTORISTA ORDER BY nome');
  return rows;
};

const buscarPorId = async (id) => {
  const [rows] = await db.execute('SELECT * FROM MOTORISTA WHERE id = ?', [id]);
  return rows[0] || null;
};

const criar = async ({ nome, cnh, categoria_cnh, validade_cnh }) => {
  const [result] = await db.execute(
    'INSERT INTO MOTORISTA (nome, cnh, categoria_cnh, validade_cnh) VALUES (?, ?, ?, ?)',
    [nome, cnh, categoria_cnh, validade_cnh]
  );
  return result.insertId;
};

const remover = async (id) => {
  const [result] = await db.execute('DELETE FROM MOTORISTA WHERE id = ?', [id]);
  return result.affectedRows;
};

module.exports = { listar, buscarPorId, criar, remover };
EOF

# backend/controllers/motoristaController.js
cat > $BASE/backend/controllers/motoristaController.js << 'EOF'
const model = require('../models/motoristaModel');

const listar = async (req, res) => {
  try { res.json(await model.listar()); }
  catch (err) { res.status(500).json({ erro: err.message }); }
};

const buscarPorId = async (req, res) => {
  try {
    const m = await model.buscarPorId(req.params.id);
    if (!m) return res.status(404).json({ erro: 'Motorista não encontrado' });
    res.json(m);
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const criar = async (req, res) => {
  const { nome, cnh, categoria_cnh, validade_cnh } = req.body;
  if (!nome || !cnh) return res.status(400).json({ erro: 'nome e cnh são obrigatórios' });
  try {
    const id = await model.criar({ nome, cnh, categoria_cnh, validade_cnh });
    res.status(201).json({ mensagem: 'Motorista cadastrado', id });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const remover = async (req, res) => {
  try {
    const afetados = await model.remover(req.params.id);
    if (!afetados) return res.status(404).json({ erro: 'Motorista não encontrado' });
    res.json({ mensagem: 'Motorista removido' });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

module.exports = { listar, buscarPorId, criar, remover };
EOF

# backend/routes/motoristaRoutes.js
cat > $BASE/backend/routes/motoristaRoutes.js << 'EOF'
const router = require('express').Router();
const ctrl   = require('../controllers/motoristaController');

router.get('/',       ctrl.listar);
router.get('/:id',    ctrl.buscarPorId);
router.post('/',      ctrl.criar);
router.delete('/:id', ctrl.remover);

module.exports = router;
EOF

# backend/models/oficinaModel.js
cat > $BASE/backend/models/oficinaModel.js << 'EOF'
const db = require('../middlewares/db');

const listar = async () => {
  const [rows] = await db.execute('SELECT * FROM OFICINA ORDER BY nome');
  return rows;
};

const buscarPorId = async (id) => {
  const [rows] = await db.execute('SELECT * FROM OFICINA WHERE id = ?', [id]);
  return rows[0] || null;
};

const criar = async ({ nome, cidade, telefone, especialidade }) => {
  const [result] = await db.execute(
    'INSERT INTO OFICINA (nome, cidade, telefone, especialidade) VALUES (?, ?, ?, ?)',
    [nome, cidade, telefone, especialidade]
  );
  return result.insertId;
};

const remover = async (id) => {
  const [result] = await db.execute('DELETE FROM OFICINA WHERE id = ?', [id]);
  return result.affectedRows;
};

module.exports = { listar, buscarPorId, criar, remover };
EOF

# backend/controllers/oficinaController.js
cat > $BASE/backend/controllers/oficinaController.js << 'EOF'
const model = require('../models/oficinaModel');

const listar = async (req, res) => {
  try { res.json(await model.listar()); }
  catch (err) { res.status(500).json({ erro: err.message }); }
};

const buscarPorId = async (req, res) => {
  try {
    const o = await model.buscarPorId(req.params.id);
    if (!o) return res.status(404).json({ erro: 'Oficina não encontrada' });
    res.json(o);
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const criar = async (req, res) => {
  const { nome, cidade, telefone, especialidade } = req.body;
  if (!nome) return res.status(400).json({ erro: 'nome é obrigatório' });
  try {
    const id = await model.criar({ nome, cidade, telefone, especialidade });
    res.status(201).json({ mensagem: 'Oficina cadastrada', id });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

const remover = async (req, res) => {
  try {
    const afetados = await model.remover(req.params.id);
    if (!afetados) return res.status(404).json({ erro: 'Oficina não encontrada' });
    res.json({ mensagem: 'Oficina removida' });
  } catch (err) { res.status(500).json({ erro: err.message }); }
};

module.exports = { listar, buscarPorId, criar, remover };
EOF

# backend/routes/oficinaRoutes.js
cat > $BASE/backend/routes/oficinaRoutes.js << 'EOF'
const router = require('express').Router();
const ctrl   = require('../controllers/oficinaController');

router.get('/',       ctrl.listar);
router.get('/:id',    ctrl.buscarPorId);
router.post('/',      ctrl.criar);
router.delete('/:id', ctrl.remover);

module.exports = router;
EOF

# backend/routes/manutencaoRoutes.js
cat > $BASE/backend/routes/manutencaoRoutes.js << 'EOF'
const router = require('express').Router();
const db = require('../middlewares/db');

router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT m.*, v.modelo, o.nome AS oficina_nome
      FROM MANUTENCAO m
      JOIN VEICULO v ON m.veiculo_placa = v.placa
      JOIN OFICINA o ON m.oficina_id = o.id
      ORDER BY m.data_entrada DESC
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

module.exports = router;
EOF

# backend/frota_db.sql
cat > $BASE/backend/frota_db.sql << 'EOF'
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
EOF

echo "✅ Backend criado com sucesso"
ls -la $BASE/backend/
