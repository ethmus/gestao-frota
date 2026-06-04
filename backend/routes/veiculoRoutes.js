const router = require('express').Router();
const ctrl   = require('../controllers/veiculoController');

router.get('/',          ctrl.listar);
router.get('/:placa',    ctrl.buscarPorPlaca);
router.post('/',         ctrl.criar);
router.put('/:placa',    ctrl.atualizar);
router.delete('/:placa', ctrl.remover);

module.exports = router;
