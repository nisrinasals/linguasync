const express = require("express");
const router = express.Router();
const leaderboardController = require("../controllers/leaderboardController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.get("/", authenticateToken, leaderboardController.getGlobalLeaderboard);

module.exports = router;
