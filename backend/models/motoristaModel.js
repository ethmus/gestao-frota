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
