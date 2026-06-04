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
