const { Quiz, QuizHistory, Language } = require("../models");

const quizController = {
  getQuestionsByLanguage: async (req, res) => {
    try {
      const { language_id } = req.query;

      if (!language_id) {
        return res.status(400).json({
          status: "fail",
          message: "Language ID harus disertakan dalam parameter kueri.",
        });
      }

      const questions = await Quiz.findAll({
        where: { language_id },
        order: [["id", "ASC"]],
      });

      return res.status(200).json({
        status: "success",
        data: questions,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memuat pertanyaan kuis.",
        error: error.message,
      });
    }
  },

  submitQuizResult: async (req, res) => {
    try {
      const { language_id, score } = req.body;
      const userId = req.user.id;

      const languageExists = await Language.findByPk(language_id);
      if (!languageExists) {
        return res.status(404).json({
          status: "fail",
          message: "ID Bahasa tidak ditemukan.",
        });
      }

      const newHistory = await QuizHistory.create({
        user_id: userId,
        language_id,
        score,
      });

      return res.status(201).json({
        status: "success",
        message: "Hasil kuis berhasil disimpan.",
        data: newHistory,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menyimpan hasil kuis ke database.",
        error: error.message,
      });
    }
  },

  adminGetQuestions: async (req, res) => {
    try {
      const { language_id } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;

      if (!language_id) {
        return res.status(400).json({
          status: "fail",
          message: "Language ID harus disertakan dalam parameter kueri.",
        });
      }

      const { count, rows } = await Quiz.findAndCountAll({
        where: { language_id },
        limit,
        offset,
        order: [["id", "ASC"]],
      });

      return res.status(200).json({
        status: "success",
        page,
        limit,
        totalItems: count,
        totalPages: Math.ceil(count / limit),
        data: rows,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memuat bank soal kuis.",
        error: error.message,
      });
    }
  },

  adminCreateQuestion: async (req, res) => {
    try {
      const { language_id, question, opt_a, opt_b, opt_c, opt_d, answer } = req.body;

      const languageExists = await Language.findByPk(language_id);
      if (!languageExists) {
        return res.status(404).json({
          status: "fail",
          message: "ID Bahasa induk tidak terdaftar.",
        });
      }

      const newQuestion = await Quiz.create({
        language_id,
        question,
        opt_a,
        opt_b,
        opt_c,
        opt_d,
        answer,
      });

      return res.status(201).json({
        status: "success",
        message: "Pertanyaan kuis baru berhasil ditambahkan.",
        data: newQuestion,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan pertanyaan kuis.",
        error: error.message,
      });
    }
  },

  adminUpdateQuestion: async (req, res) => {
    try {
      const { id } = req.params;
      const { question, opt_a, opt_b, opt_c, opt_d, answer } = req.body;

      const quizQuestion = await Quiz.findByPk(id);
      if (!quizQuestion) {
        return res.status(404).json({
          status: "fail",
          message: "Pertanyaan kuis tidak ditemukan.",
        });
      }

      await quizQuestion.update({ question, opt_a, opt_b, opt_c, opt_d, answer });

      return res.status(200).json({
        status: "success",
        message: "Pertanyaan kuis berhasil diperbarui.",
        data: quizQuestion,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data kuis.",
        error: error.message,
      });
    }
  },

  adminDeleteQuestion: async (req, res) => {
    try {
      const { id } = req.params;

      const quizQuestion = await Quiz.findByPk(id);
      if (!quizQuestion) {
        return res.status(404).json({
          status: "fail",
          message: "Pertanyaan kuis tidak ditemukan.",
        });
      }

      await quizQuestion.destroy();

      return res.status(200).json({
        status: "success",
        message: "Pertanyaan kuis berhasil dihapus dari sistem.",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memproses penghapusan data kuis.",
        error: error.message,
      });
    }
  },
};

module.exports = quizController;
