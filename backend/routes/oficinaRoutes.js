const router = require('express').Router();
const ctrl   = require('../controllers/oficinaController');

router.get('/',       ctrl.listar);
router.get('/:id',    ctrl.buscarPorId);
router.post('/',      ctrl.criar);
router.delete('/:id', ctrl.remover);

module.exports = router;
