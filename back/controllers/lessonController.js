const Lesson = require("../models/Lesson");
const Teacher = require("../models/Teacher");

exports.getAllLessons = async (req, res) => {
  console.log("[INFO] Trying to get all lessons...");
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
  console.log("[INFO] Trying to create a lesson...");
  const lessonObject = req.body;
  try {
    const lesson = new Lesson(lessonObject);
    await lesson.save();
    res.json({ message: "Lesson created" });
  } catch (error) {
    console.error("[ERROR] " + error.message);
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

exports.affectTeacherToLesson = async (req, res) => {
  try {
    // Add the teacher to the lesson's list of teachers
    const lesson = await Lesson.findById(req.params.id);
    lesson.teachers.push(req.body.teacherId);
    await lesson.save();
    // Add the lesson to the teacher's list of lessons
    const teacher = await Teacher.findById(req.body.teacherId);
    teacher.lessons.push(req.params.id);
    await teacher.save();
    res.json({ message: "Teacher succesfully affected to the lesson" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
