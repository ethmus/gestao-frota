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
