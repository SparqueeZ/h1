const Teacher = require("../models/Teacher");
const Promotion = require("../models/Promotion");
const Lesson = require("../models/Lesson");
const mongoose = require("mongoose");

exports.getAllTeachers = async (req, res) => {
  try {
    const teachers = await Teacher.find();
    res.json(teachers);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getTeacherById = async (req, res) => {
  try {
    const teacher = await Teacher.findById(req.params.id);
    res.json(teacher);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.createTeacher = async (req, res) => {
  try {
    const teacher = new Teacher(req.body);
    await teacher.save();
    res.json({ message: "Teacher created" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateTeacher = async (req, res) => {
  try {
    await Teacher.findByIdAndUpdate(req.params.id, req.body);
    res.json({ message: "Teacher updated" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteTeacher = async (req, res) => {
  try {
    await Teacher.findByIdAndDelete(req.params.id);
    res.json({ message: "Teacher deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.affectTeacherToPromotion = async (req, res) => {
  try {
    const teacher = await Teacher.findById(req.body.teacherId);
    teacher.promotions.push(req.body.promotionId);
    await teacher.save();
    const promotion = await Promotion.findById(req.body.promotionId);
    promotion.teachers.push(req.body.teacherId);
    await promotion.save();
    res.json({ message: "Teacher succesfully affected to the promotion" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getTeacherLessons = async (req, res) => {
  try {
    // Find all lessons where the teacher is in the list of teachers
    const lessons = await Lesson.find({ teachers: req.params.id });
    res.json(lessons);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
