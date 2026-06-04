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
