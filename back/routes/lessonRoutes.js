const express = require("express");
const lessonController = require("../controllers/lessonController");

const router = express.Router();

router.get("/lessons", lessonController.getAllLessons);
router.get("/lesson/:id", lessonController.getLessonById);
router.post("/lesson", lessonController.createLesson);
router.put("/lesson/:id", lessonController.updateLesson);
router.delete("/lesson/:id", lessonController.deleteLesson);

router.post("/lesson/addTeacher/:id", lessonController.affectTeacherToLesson);

module.exports = router;
