const { Quiz, QuizHistory, Language, sequelize } = require("../models");

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
        });
    }
  },

  submitQuizResult: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { language_id, score } = req.body;
      const userId = req.user.id;

      const languageExists = await Language.findByPk(language_id, { transaction: t });
      if (!languageExists) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "ID Bahasa tidak ditemukan.",
        });
      }

      const newHistory = await QuizHistory.create(
        {
          user_id: userId,
          language_id,
          score,
        },
        { transaction: t },
      );

      await t.commit();
      return res.status(201).json({
        status: "success",
        message: "Hasil kuis berhasil disimpan.",
        data: newHistory,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal menyimpan hasil kuis ke database.",
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
        });
    }
  },

  adminCreateQuestion: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { language_id, question, opt_a, opt_b, opt_c, opt_d, answer } = req.body;

      const languageExists = await Language.findByPk(language_id, { transaction: t });
      if (!languageExists) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "ID Bahasa induk tidak terdaftar.",
        });
      }

      const newQuestion = await Quiz.create(
        {
          language_id,
          question,
          option_a: opt_a,
          option_b: opt_b,
          option_c: opt_c,
          option_d: opt_d,
          correct_answer: answer.toLowerCase(),
        },
        { transaction: t },
      );

      await t.commit();
      return res.status(201).json({
        status: "success",
        message: "Pertanyaan kuis baru berhasil ditambahkan.",
        data: newQuestion,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan pertanyaan kuis.",
        });
    }
  },

  adminUpdateQuestion: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      const { question, opt_a, opt_b, opt_c, opt_d, answer } = req.body;

      const quizQuestion = await Quiz.findByPk(id, { transaction: t });
      if (!quizQuestion) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Pertanyaan kuis tidak ditemukan.",
        });
      }

      await quizQuestion.update({ 
        question, 
        option_a: opt_a, 
        option_b: opt_b, 
        option_c: opt_c, 
        option_d: opt_d, 
        correct_answer: answer.toLowerCase()
      }, { transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Pertanyaan kuis berhasil diperbarui.",
        data: quizQuestion,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data kuis.",
        });
    }
  },

  adminDeleteQuestion: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;

      const quizQuestion = await Quiz.findByPk(id, { transaction: t });
      if (!quizQuestion) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Pertanyaan kuis tidak ditemukan.",
        });
      }

      await quizQuestion.destroy({ transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Pertanyaan kuis berhasil dihapus dari sistem.",
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memproses penghapusan data kuis.",
        });
    }
  },
};

module.exports = quizController;
