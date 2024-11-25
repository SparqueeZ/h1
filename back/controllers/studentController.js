const Student = require("../models/Student");
const Promotion = require("../models/Promotion");
const Lesson = require("../models/Lesson");

exports.getAllStudents = async (req, res) => {
  try {
    const students = await Student.find();
    res.json(students);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getStudentById = async (req, res) => {
  try {
    const students = await Student.findById(req.params.id);
    res.json(students);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.createStudent = async (req, res) => {
  try {
    const students = new Student(req.body);
    await students.save();
    res.json({ message: "Student created" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateStudent = async (req, res) => {
  try {
    await Student.findByIdAndUpdate(req.params.id, req.body);
    res.json({ message: "Student updated" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteStudent = async (req, res) => {
  try {
    await Student.findByIdAndDelete(req.params.id);
    res.json({ message: "Student deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.affectStudentToPromotion = async (req, res) => {
  try {
    const student = await Student.findById(req.body.studentId);
    student.promotions = req.body.promotionId;
    await student.save();
    const promotion = await Promotion.findById(req.body.promotionId);
    promotion.students.push(req.body.studentId);
    await promotion.save();
    res.json({ message: "Student succesfully affected to the promotion" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getStudentLessons = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);
    const promotion = await Promotion.findById(student.promotions);
    const lessons = await Lesson.find({ _id: { $in: promotion.lessons } });
    res.json(lessons);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
