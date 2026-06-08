const express = require("express");
const router = express.Router();
const materialController = require("../controllers/materialController");
const { authenticateToken, isAdmin } = require("../middleware/authMiddleware");
const { materialValidation } = require("../middleware/validator/materialValidator");

router.get("/", authenticateToken, materialController.getMaterialsByLanguage);
router.get("/:id", authenticateToken, materialController.getMaterialById);

router.post("/admin", authenticateToken, isAdmin, materialValidation, materialController.createMaterial);
router.put("/admin/:id", authenticateToken, isAdmin, materialValidation, materialController.updateMaterial);
router.delete("/admin/:id", authenticateToken, isAdmin, materialController.deleteMaterial);

module.exports = router;
