const express = require("express");
const teacherController = require("../controllers/teacherController");

const router = express.Router();

router.get("/teachers", teacherController.getAllTeachers);
router.get("/teacher/:id", teacherController.getTeacherById);
router.post("/teacher", teacherController.createTeacher);
router.put("/teacher/:id", teacherController.updateTeacher);

module.exports = router;
