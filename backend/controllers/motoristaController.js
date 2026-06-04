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
