const Promotion = require("../models/Promotion");
const Lesson = require("../models/Lesson");

exports.getAllPromotions = async (req, res) => {
  try {
    const promotions = await Promotion.find();
    res.json(promotions);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getPromotionById = async (req, res) => {
  try {
    const promotion = await Promotion.findById(req.params.id);
    res.json(promotion);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.createPromotion = async (req, res) => {
  try {
    const promotion = new Promotion(req.body);
    await promotion.save();
    res.json({ message: "Promotion created" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updatePromotion = async (req, res) => {
  try {
    await Promotion.findByIdAndUpdate(req.params.id, req.body);
    res.json({ message: "Promotion updated" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deletePromotion = async (req, res) => {
  try {
    await Promotion.findByIdAndDelete(req.params.id);
    res.json({ message: "Promotion deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.affectLessonToPromotion = async (req, res) => {
  console.log(req.body);
  try {
    const promotion = await Promotion.findById(req.body.promotionId);
    console.log(promotion);
    promotion.lessons.push(req.body.lessonId);
    await promotion.save();
    const lesson = await Lesson.findById(req.body.lessonId);
    lesson.promotions.push(req.body.promotionId);
    await lesson.save();
    res.json({ message: "Lesson succesfully affected to the promotion" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
