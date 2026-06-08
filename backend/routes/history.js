const express = require("express");
const router = express.Router();
const historyController = require("../controllers/historyController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.get("/", authenticateToken, historyController.getUserHistory);

module.exports = router;
