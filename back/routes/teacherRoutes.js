const express = require("express");
const teacherController = require("../controllers/teacherController");

const router = express.Router();

router.get("/teachers", teacherController.getAllTeachers);
router.get("/teacher/:id", teacherController.getTeacherById);
router.post("/teacher", teacherController.createTeacher);
router.put("/teacher/:id", teacherController.updateTeacher);
router.delete("/teacher/:id", teacherController.deleteTeacher);

router.post(
  "/teacher/addToPromotion",
  teacherController.affectTeacherToPromotion
);

router.get("/teacher/:id/lessons", teacherController.getTeacherLessons);

module.exports = router;
