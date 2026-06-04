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
