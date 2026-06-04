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
