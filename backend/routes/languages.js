const express = require("express");
const router = express.Router();

const languageController = require("../controllers/languageController");
const { authenticateToken, isAdmin } = require("../middleware/authMiddleware");
const { languageValidation, enrollValidation } = require("../middleware/validator/languageValidator");

// Student Network Endpoints
router.get("/", authenticateToken, languageController.exploreLanguages);
router.post("/enroll", authenticateToken, enrollValidation, languageController.enrollLanguage);
router.get("/my-study", authenticateToken, languageController.getMyLanguages);
router.delete("/my-study/:id", authenticateToken, languageController.unenrollLanguage);

// Administrator CRUD Management Endpoints
router.post("/admin", authenticateToken, isAdmin, languageValidation, languageController.createLanguage);
router.put("/admin/:id", authenticateToken, isAdmin, languageValidation, languageController.updateLanguage);
router.delete("/admin/:id", authenticateToken, isAdmin, languageController.deleteLanguage);

module.exports = router;
