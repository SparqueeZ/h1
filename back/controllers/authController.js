const User = require("../models/User");
const Teacher = require("../models/Teacher");
const Student = require("../models/Student");
const Promotion = require("../models/Promotion");
const Lesson = require("../models/Lesson");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  const { email, password, role, firstname, lastname, age } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ email, password: hashedPassword, roles: [role] });
    await user.save();

    if (role === "teacher") {
      const teacher = new Teacher({ user: user._id, firstname, lastname, age });
      await teacher.save();
    } else if (role === "student") {
      const student = new Student({ user: user._id, firstname, lastname, age });
      await student.save();
    }

    res.status(201).json({ message: "User registered" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).send("Invalid credentials");
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).send("Invalid credentials");
    }
    const token = jwt.sign({ userId: user._id }, "your_jwt_secret", {
      expiresIn: "1h",
    });
    res.cookie("token", token, { httpOnly: true });
    res
      .status(200)
      .json({ message: "Succesfully authenticated", token: token });
    console.log("Data sent : ", token);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error during authentication", error: error });
  }
};

exports.getUserInfo = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).send("User not found");
    }

    let userInfo;
    if (user.roles.includes("teacher")) {
      userInfo = await Teacher.findOne({ user: user._id })
        .populate({
          path: "promotions",
          select: "name year -_id",
        })
        .populate({
          path: "lessons",
          populate: {
            path: "students.data",
            select: "firstname lastname age",
          },
        });
    } else if (user.roles.includes("student")) {
      userInfo = await Student.findOne({ user: user._id }).populate({
        path: "promotions",
        select: "name year",
        // populate: {
        //   path: "lessons",
        //   populate: {
        //     path: "teachers",
        //   },
        // },
      });
    } else if (user.roles.includes("moderator")) {
      userInfo = await Moderator.findOne({ user: user._id }).populate({});
    }

    // Récupération des informations détaillées des promotions
    let promotions = [];
    for (const promotion of userInfo.promotions) {
      const foundPromotion = await Promotion.findById(promotion._id).lean();
      if (foundPromotion) {
        const lessonIds = foundPromotion.lessons.map((lesson) => lesson._id);
        let lessons = await Lesson.find({ _id: { $in: lessonIds } }).lean();

        for (const lesson of lessons) {
          const studentIds = lesson.students.map((student) => student._id);
          const students = await Student.find({
            _id: { $in: studentIds },
          }).lean();

          let studentsWithPresence = students.map((student) => {
            const lessonStudent = lesson.students.find(
              (ls) => ls._id.toString() === student._id.toString()
            );
            return {
              ...student,
              isPresent: lessonStudent?.isPresent || false,
            };
          });

          const teacherIds = lesson.teachers.map((teacher) => teacher._id);
          let teachers = await Teacher.find({
            _id: { $in: teacherIds },
          }).lean();

          // Formater les données filtrer les données sensibles
          teachers = filterTeachers(teachers);
          studentsWithPresence = filterStudents(studentsWithPresence);

          // Assigner les étudiants et teachers à la lesson
          lesson.students = studentsWithPresence;
          lesson.teachers = teachers;
        }

        // Formater les données filtrer les données sensibles
        lessons = filterLessons(lessons);
        foundPromotion.lessons = lessons;
        promotions.push(foundPromotion);

        // Formater les données des promotions pout filtrer les données sensibles
        promotions = filterPromotions(promotions);
      }
    }

    const dataToSend = {
      user: {
        email: user.email,
        roles: user.roles,
        firstname: userInfo.firstname,
        lastname: userInfo.lastname,
        age: userInfo.age,
      },
      // promotions: userInfo.promotions,
      promotions, // Envoie toutes les informations des promotions récupérées
      // lessons, // Vous pouvez ajouter les leçons si nécessaire
    };

    res.json(dataToSend);
  } catch (error) {
    console.error("Error retrieving user information:", error);
    res.status(500).send("Error retrieving user information");
  }
};

const filterPromotions = (promotions) => {
  return promotions.map((promotion) => ({
    name: promotion.name,
    year: promotion.year,
    lessons: promotion.lessons,
  }));
};
const filterLessons = (lessons) => {
  return lessons.map((lesson) => ({
    title: lesson.title,
    description: lesson.description,
    date: lesson.date,
    duration: lesson.duration,
    teachers: lesson.teachers,
    students: lesson.students,
  }));
};
const filterTeachers = (teachers) => {
  return teachers.map((teacher) => ({
    fisrtname: teacher.firstname,
    lastname: teacher.lastname,
  }));
};
const filterStudents = (students) => {
  return students.map((student) => ({
    fisrtname: student.firstname,
    lastname: student.lastname,
    isPresent: student.isPresent,
  }));
};
