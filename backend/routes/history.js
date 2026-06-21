const express = require("express");
const router = express.Router();
const historyController = require("../controllers/historyController");
const { authenticateToken, isAdmin } = require("../middleware/authMiddleware");

// Student view of their own history
router.get("/", authenticateToken, historyController.getUserHistory);

// Administrator CRUD operations for history
router.get("/admin", authenticateToken, isAdmin, historyController.getAllHistoriesAdmin);
router.get("/admin/:id", authenticateToken, isAdmin, historyController.getHistoryByIdAdmin);
router.post("/admin", authenticateToken, isAdmin, historyController.createHistoryAdmin);
router.put("/admin/:id", authenticateToken, isAdmin, historyController.updateHistoryAdmin);
router.delete("/admin/:id", authenticateToken, isAdmin, historyController.deleteHistoryAdmin);

module.exports = router;
