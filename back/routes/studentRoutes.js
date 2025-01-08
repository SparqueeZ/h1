const express = require("express");
const studentController = require("../controllers/studentController");

const router = express.Router();

router.get("/students", studentController.getAllStudents);
router.get("/student/:id", studentController.getStudentById);
router.post("/student", studentController.createStudent);
router.put("/student/:id", studentController.updateStudent);
router.delete("/student/:id", studentController.deleteStudent);

router.post(
  "/student/addToPromotion",
  studentController.affectStudentToPromotion
);
router.post(
  "/student/removeFromPromotion",
  studentController.removeStudentFromPromotion
);
router.get("/student/:id/lessons", studentController.getStudentLessons);

router.post("/student/badge/:id", studentController.changeStudentPresentValue);

module.exports = router;
