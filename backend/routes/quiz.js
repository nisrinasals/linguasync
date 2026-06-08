const express = require("express");
const router = express.Router();
const quizController = require("../controllers/quizController");
const { authenticateToken, isAdmin } = require("../middlewares/authMiddleware");
const { submitValidation, questionValidation } = require("../middlewares/quizValidator");

router.get("/", authenticateToken, quizController.getQuestionsByLanguage);
router.post("/submit", authenticateToken, submitValidation, quizController.submitQuizResult);

router.get("/admin", authenticateToken, isAdmin, quizController.adminGetQuestions);
router.post("/admin", authenticateToken, isAdmin, questionValidation, quizController.adminCreateQuestion);
router.put("/admin/:id", authenticateToken, isAdmin, questionValidation, quizController.adminUpdateQuestion);
router.delete("/admin/:id", authenticateToken, isAdmin, quizController.adminDeleteQuestion);

module.exports = router;
