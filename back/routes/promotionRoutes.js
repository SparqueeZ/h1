const express = require("express");
const promotionController = require("../controllers/promotionController");

const router = express.Router();

router.get("/promotions", promotionController.getAllPromotions);
router.get("/promotion/:id", promotionController.getPromotionById);
router.post("/promotion", promotionController.createPromotion);
router.put("/promotion/:id", promotionController.updatePromotion);
router.delete("/promotion/:id", promotionController.deletePromotion);

router.post(
  "/promotion/addToLesson",
  promotionController.affectLessonToPromotion
);

module.exports = router;
