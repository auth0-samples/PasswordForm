var express = require('express');
var router = express.Router();

router.post('/', function(req, res, next) {
  res.status(400).send('Current password does not match');
});

// router.post('/', function(req, res, next) {
//   res.json({ error: 'Wrong password' });
// });

// router.post('/', function(req, res, next) {
//   res.json({ success: true });
// });

module.exports = router;
