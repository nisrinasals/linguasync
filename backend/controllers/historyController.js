const { QuizHistory, Language, User } = require("../models");
const { Op } = require("sequelize");

const historyController = {
  // Read current student's quiz history (User view)
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

  // Read all quiz histories (Admin CRUD - pagination + search by student name/language name)
  getAllHistoriesAdmin: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const search = req.query.search || "";
      const languageId = req.query.language_id || "";

      const whereClause = {};
      if (search) {
        whereClause[Op.or] = [
          { "$User.username$": { [Op.like]: `%${search}%` } },
          { "$Language.name$": { [Op.like]: `%${search}%` } },
        ];
      }

      if (languageId) {
        whereClause.language_id = languageId;
      }

      const { count, rows } = await QuizHistory.findAndCountAll({
        where: whereClause,
        include: [
          {
            model: User,
            attributes: ["id", "name", "email"],
          },
          {
            model: Language,
            attributes: ["id", "name"],
          },
        ],
        limit,
        offset,
        order: [["createdAt", "DESC"]],
      });

      const formattedData = rows.map((row) => ({
        id: row.id,
        user_id: row.user_id,
        user_name: row.User ? row.User.name : "N/A",
        user_email: row.User ? row.User.email : "N/A",
        language_id: row.language_id,
        language_name: row.Language ? row.Language.name : "N/A",
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
        message: "Gagal mengambil daftar riwayat kuis admin.",
        error: error.message,
      });
    }
  },

  // Read single quiz history detail (Admin CRUD)
  getHistoryByIdAdmin: async (req, res) => {
    try {
      const history = await QuizHistory.findByPk(req.params.id, {
        include: [
          { model: User, attributes: ["id", "name", "email"] },
          { model: Language, attributes: ["id", "name"] },
        ],
      });

      if (!history) {
        return res.status(404).json({
          status: "fail",
          message: "Data riwayat kuis tidak ditemukan.",
        });
      }

      return res.status(200).json({
        status: "success",
        data: {
          id: history.id,
          user_id: history.user_id,
          user_name: history.User ? history.User.name : "N/A",
          language_id: history.language_id,
          language_name: history.Language ? history.Language.name : "N/A",
          score: history.score,
          createdAt: history.createdAt,
        },
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal mengambil data detail riwayat kuis.",
        error: error.message,
      });
    }
  },

  // Create new quiz history entry (Admin CRUD)
  createHistoryAdmin: async (req, res) => {
    try {
      const { user_id, language_id, score } = req.body;

      if (!user_id || !language_id || score === undefined) {
        return res.status(400).json({
          status: "fail",
          message: "Field user_id, language_id, dan score wajib diisi.",
        });
      }

      // Check user existence
      const userExists = await User.findByPk(user_id);
      if (!userExists) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna (user_id) tidak ditemukan.",
        });
      }

      // Check language existence
      const languageExists = await Language.findByPk(language_id);
      if (!languageExists) {
        return res.status(404).json({
          status: "fail",
          message: "Bahasa (language_id) tidak ditemukan.",
        });
      }

      const newHistory = await QuizHistory.create({
        user_id,
        language_id,
        score: parseFloat(score),
      });

      return res.status(201).json({
        status: "success",
        message: "Riwayat kuis baru berhasil dicatat oleh admin.",
        data: newHistory,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal mencatat riwayat kuis baru.",
        error: error.message,
      });
    }
  },

  // Update existing quiz history entry (Admin CRUD)
  updateHistoryAdmin: async (req, res) => {
    try {
      const history = await QuizHistory.findByPk(req.params.id);
      if (!history) {
        return res.status(404).json({
          status: "fail",
          message: "Data riwayat kuis tidak ditemukan.",
        });
      }

      const { user_id, language_id, score } = req.body;

      if (user_id) {
        const userExists = await User.findByPk(user_id);
        if (!userExists) {
          return res.status(404).json({
            status: "fail",
            message: "Pengguna (user_id) tidak ditemukan.",
          });
        }
        history.user_id = user_id;
      }

      if (language_id) {
        const languageExists = await Language.findByPk(language_id);
        if (!languageExists) {
          return res.status(404).json({
            status: "fail",
            message: "Bahasa (language_id) tidak ditemukan.",
          });
        }
        history.language_id = language_id;
      }

      if (score !== undefined) {
        history.score = parseFloat(score);
      }

      await history.save();

      return res.status(200).json({
        status: "success",
        message: "Data riwayat kuis berhasil diperbarui oleh admin.",
        data: history,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data riwayat kuis.",
        error: error.message,
      });
    }
  },

  // Delete quiz history entry (Admin CRUD)
  deleteHistoryAdmin: async (req, res) => {
    try {
      const history = await QuizHistory.findByPk(req.params.id);
      if (!history) {
        return res.status(404).json({
          status: "fail",
          message: "Data riwayat kuis tidak ditemukan.",
        });
      }

      await history.destroy();

      return res.status(200).json({
        status: "success",
        message: "Data riwayat kuis berhasil dihapus.",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menghapus data riwayat kuis.",
        error: error.message,
      });
    }
  },
};

module.exports = historyController;
