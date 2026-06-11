const { QuizHistory, User, sequelize } = require("../models");
const { Op } = require("sequelize");

const leaderboardController = {
  getGlobalLeaderboard: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const currentUserId = req.user.id;

      const latestSubquery = `(
        SELECT id FROM quizhistories AS qh
        WHERE qh.createdAt = (
          SELECT MAX(createdAt) 
          FROM quizhistories 
          WHERE user_id = qh.user_id AND language_id = qh.language_id
        )
      )`;

      const uniqueUsers = await QuizHistory.findAll({
        attributes: [[sequelize.fn('DISTINCT', sequelize.col('user_id')), 'user_id']],
        where: { id: { [Op.in]: sequelize.literal(latestSubquery) } },
      });
      const totalUniqueUsers = uniqueUsers.length;

      const rows = await QuizHistory.findAll({
        attributes: ["user_id", [sequelize.fn("SUM", sequelize.col("score")), "totalScore"]],
        include: [
          {
            model: User,
            attributes: ["name"],
          },
        ],
        where: { id: { [Op.in]: sequelize.literal(latestSubquery) } },
        group: ["user_id", "User.id"],
        order: [[sequelize.literal("totalScore"), "DESC"]],
        limit,
        offset,
      });

      const allRankings = await QuizHistory.findAll({
        attributes: ["user_id", [sequelize.fn("SUM", sequelize.col("score")), "totalScore"]],
        where: { id: { [Op.in]: sequelize.literal(latestSubquery) } },
        group: ["user_id"],
        order: [[sequelize.literal("totalScore"), "DESC"]],
      });

      let currentUserRank = null;
      let currentUserScore = 0;

      for (let i = 0; i < allRankings.length; i++) {
        if (allRankings[i].user_id === currentUserId) {
          currentUserRank = i + 1;
          currentUserScore = parseFloat(allRankings[i].getDataValue("totalScore")) || 0;
          break;
        }
      }

      const formattedData = rows.map((row, index) => ({
        rank: offset + index + 1,
        user_id: row.user_id,
        name: row.User.name,
        totalScore: parseFloat(row.getDataValue("totalScore")) || 0,
      }));

      return res.status(200).json({
        status: "success",
        page,
        limit,
        totalItems: totalUniqueUsers,
        totalPages: Math.ceil(totalUniqueUsers / limit),
        currentUser: {
          rank: currentUserRank,
          totalScore: currentUserScore,
        },
        data: formattedData,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memuat papan peringkat global.",
        });
    }
  },
};

module.exports = leaderboardController;
