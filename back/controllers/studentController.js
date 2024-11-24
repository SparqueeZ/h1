const Student = require("../models/Teacher");

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
    res.json({ message: "Teacher created" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateStudent = async (req, res) => {
  try {
    await Student.findByIdAndUpdate(req.params.id, req.body);
    res.json({ message: "Teacher updated" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteStudent = async (req, res) => {
  try {
    await Student.findByIdAndDelete(req.params.id);
    res.json({ message: "Teacher deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
