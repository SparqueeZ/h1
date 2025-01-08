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
  console.log("Adding Student...");
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
    // Add promotion to student table
    const student = await Student.findById(req.body.studentId);
    student.promotions.push(req.body.promotionId);
    await student.save();
    // Add student to promotion's student array
    const promotion = await Promotion.findById(req.body.promotionId);
    promotion.students.push(req.body.studentId);
    await promotion.save();
    // Add student to all lessons of the promotion
    const lessons = await Lesson.find({ _id: { $in: promotion.lessons } });
    lessons.forEach((l) => {
      l.students.push({ _id: req.body.studentId, isPresent: false });
      l.save();
    });

    res.json({ message: "Student succesfully affected to the promotion" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.removeStudentFromPromotion = async (req, res) => {
  try {
    // Remove promotions from student table
    const student = await Student.findById(req.body.studentId);
    const promotionIndex = student.promotions.findIndex(
      (p) => p?.toString() === req.body.promotionId
    );
    student.promotions.splice(promotionIndex, 1);
    await student.save();
    // Remove student from promotion's student array
    const promotion = await Promotion.findById(req.body.promotionId);
    promotion.students = promotion.students.filter(
      (s) => s !== req.body.studentId
    );
    await promotion.save();
    // Remove student from all lessons of the promotion
    const lessons = await Lesson.find({ _id: { $in: promotion.lessons } });
    lessons.forEach(async (l) => {
      const studentIndex = l.students.findIndex(
        (s) => s.student?.toString() === req.body.studentId
      );
      l.students.splice(studentIndex, 1);
      await l.save();
    });
    res.json({ message: "Student succesfully removed from the promotion" });
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

exports.changeStudentPresentValue = async (req, res) => {
  console.log("[INFO] Changing student presence value");
  const { sessionToken, lessonId } = req.body;
  const recievedSessionToken = sessionToken;
  if (!sessionToken || !lessonId || !req.params.id) {
    return res
      .status(400)
      .json({ message: "Request not successfully filled." });
  }

  console.log("sessionToken:", sessionToken);
  console.log("lessonId:", lessonId);
  console.log("studentId:", req.params.id);

  try {
    const student = await Student.findById(req.params.id);
    if (!student) {
      console.error("[ERROR] Student not found.");
      return res.status(404).json({ message: "Student not found." });
    }
    const lesson = await Lesson.findById(lessonId);
    if (!lesson) {
      console.error("[ERROR] Lesson not found.");
      return res.status(404).json({ message: "Lesson not found." });
    }
    const index = lesson.students.findIndex(
      (s) => s._id.toString() === student._id.toString()
    );
    // Check if the sessionToken is good
    if (recievedSessionToken !== lesson.sessionToken) {
      console.error("[ERROR] Wrong session token.");
      return res.status(400).json({ message: "Wrong session token." });
    }
    if (index === -1) {
      console.error("[ERROR] Student not found in the lesson.");
      return res
        .status(400)
        .json({ message: "Student not found in the lesson." });
    }
    console.log("studentId:", req.params.id);
    console.log("index:", index);
    console.log("student:", lesson.students[index]);

    // Change the student's presence value
    lesson.students[index].isPresent = !lesson.students[index].isPresent;
    await lesson.save();
    res.json({ message: "Student presence value changed" });
    // lesson.students[index].isPresent = req.body.present;
    // await lesson.save();
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message });
  }
};
