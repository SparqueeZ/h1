const Promotion = require("../models/Promotion");
const Lesson = require("../models/Lesson");
const Student = require("../models/Student");

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
  try {
    // Ajoute les la lesson dans la liste des lessons de promotion
    const promotion = await Promotion.findById(req.body.promotionId);
    promotion.lessons.push(req.body.lessonId);
    await promotion.save();
    // Ajoute la promotion dans la liste des promotions de lesson
    const lesson = await Lesson.findById(req.body.lessonId);
    lesson.promotions.push(req.body.promotionId);
    await lesson.save();
    // Ajoute tous les étudiants d'une promotion dans la liste des étudiants de lesson
    const students = await Student.find({ promotions: req.body.promotionId });
    students.forEach(async (student) => {
      lesson.students.push(student._id);
      await lesson.save();
    });
    res.json({ message: "Lesson succesfully affected to the promotion" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
