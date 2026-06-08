require("dotenv").config();
const express = require("express");
const cors = require("cors");
const db = require("./models");

const authRoutes = require("./routes/auth");
const languageRoutes = require("./routes/languages");
const materialRoutes = require("./routes/material");
const quizRoutes = require("./routes/quiz");
const leaderboardRoutes = require("./routes/leaderboard");
const historyRoutes = require("./routes/history");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/auth", authRoutes);
app.use("/api/languages", languageRoutes);
app.use("/api/materials", materialRoutes);
app.use("/api/quizzes", quizRoutes);
app.use("/api/leaderboard", leaderboardRoutes);
app.use("/api/history", historyRoutes);

app.use((req, res, next) => {
  return res.status(404).json({
    status: "fail",
    message: "Endpoint tidak ditemukan di dalam sistem API.",
  });
});

app.use((err, req, res, next) => {
  return res.status(500).json({
    status: "error",
    message: "Terjadi kesalahan internal pada server.",
    error: err.message,
  });
});

db.sequelize
  .authenticate()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`LinguaSync API Gateway is running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Database connection configuration failed:", err);
  });
