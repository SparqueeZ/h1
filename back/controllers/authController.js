const User = require("../models/User");
const Teacher = require("../models/Teacher");
const Student = require("../models/Student");
const Promotion = require("../models/Promotion");
const Moderator = require("../models/Moderator");
const Lesson = require("../models/Lesson");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  console.log("[INFO] Trying to register...");
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
    } else if (role === "moderator") {
      const student = new Moderator({
        user: user._id,
        firstname,
        lastname,
        age,
      });
      await student.save();
    }

    res.status(201).json({ message: "User registered" });
  } catch (error) {
    console.log(error);
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
          select: "title description date duration students sessionToken _id",
          // populate: {
          //   path: "students",
          //   select: "firstname lastname isPresent -_id",
          // },
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
      userInfo = await Moderator.findOne({ user: user._id });
    }

    // Récupération des informations détaillées des promotions
    let promotions = [];
    if (!user.roles.includes("moderator")) {
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

          const studentIds = foundPromotion.students.map(
            (student) => student._id
          );
          let studentsInPromotion = await Student.find({
            _id: { $in: studentIds },
          }).lean();

          studentsInPromotion = filterStudents(studentsInPromotion);

          // Formater les données filtrer les données sensibles
          lessons = filterLessons(lessons);
          foundPromotion.lessons = lessons;
          foundPromotion.students = studentsInPromotion;
          promotions.push(foundPromotion);

          // Formater les données des promotions pout filtrer les données sensibles
          promotions = filterPromotions(promotions);
        }
      }
    }

    let lessons = user.roles.includes("teacher") ? userInfo.lessons : undefined;

    if (user.roles.includes("teacher")) {
      const updatedLessons = [];
      for (const lesson of lessons) {
        const lessonObj = lesson.toObject();
        let populatedStudents = [];
        for (const student of lessonObj.students) {
          const studentInfo = await Student.findById(student._id).lean();
          if (studentInfo) {
            // console.log("Student found");
            studentInfo.isPresent = student.isPresent;
            populatedStudents.push(studentInfo);
          } else {
            // console.log("Student not found");
          }
        }

        // Find the lesson in the database
        const lessonInfo = await Lesson.findById(lessonObj._id).lean();
        if (!lessonInfo) {
          console.log("Lesson not found");
        } else {
          let populatedPromotions = [];
          for (const promotion of lessonInfo.promotions) {
            const promotionInfo = await Promotion.findById(
              promotion.toString()
            ).lean();
            if (promotionInfo) {
              populatedPromotions.push(promotionInfo.name);
            } else {
              console.log("Promotion not found");
            }
          }
          lessonObj.promotions = populatedPromotions;
        }

        populatedStudents = filterStudents(populatedStudents);
        lessonObj.students = populatedStudents;
        updatedLessons.push(lessonObj);
      }
      lessons = updatedLessons;
    }

    if (user.roles.includes("moderator")) {
      promotions = undefined;
    }

    const dataToSend = {
      user: {
        id: userInfo._id,
        email: user.email,
        roles: user.roles,
        firstname: userInfo.firstname,
        lastname: userInfo.lastname,
        age: userInfo.age,
      },
      promotions,
      lessons,
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
    students: promotion.students,
  }));
};
const filterLessons = (lessons) => {
  return lessons.map((lesson) => ({
    id: lesson._id,
    title: lesson.title,
    description: lesson.description,
    date: lesson.date,
    duration: lesson.duration,
    teachers: lesson.teachers,
    students: lesson.students,
    // promotions: lesson.promotions,
  }));
};
const filterTeachers = (teachers) => {
  return teachers.map((teacher) => ({
    firstname: teacher.firstname,
    lastname: teacher.lastname,
  }));
};
const filterStudents = (students) => {
  return students.map((student) => ({
    firstname: student.firstname,
    lastname: student.lastname,
    isPresent: student.isPresent,
  }));
};
