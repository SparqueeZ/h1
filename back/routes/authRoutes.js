const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const authenticateToken = require("../middlewares/authentification");

router.post("/auth/register", authController.register);
router.post("/auth/login", authController.login);
router.get("/auth/data", authenticateToken, authController.getUserInfo);

module.exports = router;
