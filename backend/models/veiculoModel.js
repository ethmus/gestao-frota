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
