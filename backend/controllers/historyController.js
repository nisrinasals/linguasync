const { QuizHistory, Language } = require("../models");

const historyController = {
  getUserHistory: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const userId = req.user.id;

      const { count, rows } = await QuizHistory.findAndCountAll({
        where: { user_id: userId },
        include: [
          {
            model: Language,
            attributes: ["name"],
          },
        ],
        limit,
        offset,
        order: [["createdAt", "DESC"]],
      });

      const formattedData = rows.map((row) => ({
        id: row.id,
        language_name: row.Language ? row.Language.name : null,
        score: row.score,
        createdAt: row.createdAt,
      }));

      return res.status(200).json({
        status: "success",
        page,
        limit,
        totalItems: count,
        totalPages: Math.ceil(count / limit),
        data: formattedData,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal mengambil data riwayat kuis Anda.",
        });
    }
  },
};

module.exports = historyController;
