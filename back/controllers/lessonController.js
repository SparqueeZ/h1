const Lesson = require("../models/Lesson");

exports.getAllLessons = async (req, res) => {
  try {
    const lessons = await Lesson.find();
    res.json(lessons);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getLessonById = async (req, res) => {
  try {
    const lesson = await Lesson.findById(req.params.id);
    res.json(lesson);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.createLesson = async (req, res) => {
  try {
    const lesson = new Lesson(req.body);
    await lesson.save();
    res.json({ message: "Lesson created" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateLesson = async (req, res) => {
  try {
    await Lesson.findByIdAndUpdate(req.params.id, req.body);
    res.json({ message: "Lesson updated" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteLesson = async (req, res) => {
  try {
    await Lesson.findByIdAndDelete(req.params.id);
    res.json({ message: "Lesson deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
