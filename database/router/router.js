const express = require('express');
const router = express.Router();
const controller = require('../controller/controller');

router.post('/register', controller.register);
router.post('/login', controller.login);
router.post('/create-devotion', controller.createDevotion);
router.post('/upload-thumbnail', controller.uploadThumbnail);
router.get('/get-all-devotions', controller.getAllDevotions);
router.get('/get-single-devotion', controller.getSingleDevotion);
router.get('/get-devotion-by-date', controller.getDevotionByDate);
router.patch('/update-single-devotion', controller.updateSingleDevotion); 
router.delete('/delete-single-devotion/:id', controller.deleteSingleDevotion); 

module.exports = router;