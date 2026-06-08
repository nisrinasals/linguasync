const { Language, Enrollment } = require("../models");
const { Op } = require("sequelize");

const languageController = {
  // REQ-EXPL: Student explores all languages with server-side search and pagination
  exploreLanguages: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const search = req.query.search || "";

      const { count, rows } = await Language.findAndCountAll({
        where: {
          name: {
            [Op.like]: `%${search}%`,
          },
        },
        limit,
        offset,
        order: [["name", "ASC"]],
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
        message: "Gagal memuat data eksplorasi bahasa.",
        error: error.message,
      });
    }
  },

  // REQ-ENR: Student registers for a language module
  enrollLanguage: async (req, res) => {
    try {
      const { language_id } = req.body;
      const userId = req.user.id;

      const targetLanguage = await Language.findByPk(language_id);
      if (!targetLanguage) {
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang dipilih tidak ditemukan.",
        });
      }

      const existingEnrollment = await Enrollment.findOne({
        where: { user_id: userId, language_id },
      });

      if (existingEnrollment) {
        return res.status(400).json({
          status: "fail",
          message: "Anda sudah mendaftar (enrolled) pada kursus bahasa ini.",
        });
      }

      await Enrollment.create({
        user_id: userId,
        language_id,
        status: "active",
      });

      return res.status(201).json({
        status: "success",
        message: "Pendaftaran bahasa berhasil. Selamat belajar!",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan sistem saat memproses enrollment.",
        error: error.message,
      });
    }
  },

  // REQ-STUDY: Fetch student-specific courses with pagination mapping
  getMyLanguages: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const userId = req.user.id;

      const { count, rows } = await Enrollment.findAndCountAll({
        where: { user_id: userId },
        include: [
          {
            model: Language,
            attributes: ["id", "name", "description"],
          },
        ],
        limit,
        offset,
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
        message: "Gagal memuat daftar studi pribadi Anda.",
        error: error.message,
      });
    }
  },

  // REQ-STUDY-04: Student drops a chosen language track
  unenrollLanguage: async (req, res) => {
    try {
      const enrollmentId = req.params.id;
      const userId = req.user.id;

      const enrollment = await Enrollment.findOne({
        where: { id: enrollmentId, user_id: userId },
      });

      if (!enrollment) {
        return res.status(404).json({
          status: "fail",
          message: "Data pendaftaran tidak ditemukan atau bukan milik Anda.",
        });
      }

      await enrollment.destroy();

      return res.status(200).json({
        status: "success",
        message: "Berhasil menghapus bahasa dari daftar MyStudy.",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memproses penghapusan daftar studi.",
        error: error.message,
      });
    }
  },

  // REQ-ADM-LANG-02: Admin creates a new language course
  createLanguage: async (req, res) => {
    try {
      const { name, description } = req.body;

      const newLanguage = await Language.create({ name, description });

      return res.status(201).json({
        status: "success",
        message: "Entitas bahasa baru berhasil ditambahkan.",
        data: newLanguage,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan bahasa baru.",
        error: error.message,
      });
    }
  },

  // REQ-ADM-LANG-04: Admin updates a language's details
  updateLanguage: async (req, res) => {
    try {
      const languageId = req.params.id;
      const { name, description } = req.body;

      const language = await Language.findByPk(languageId);
      if (!language) {
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang akan diperbarui tidak ditemukan.",
        });
      }

      await language.update({ name, description });

      return res.status(200).json({
        status: "success",
        message: "Informasi bahasa berhasil diperbarui.",
        data: language,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data bahasa.",
        error: error.message,
      });
    }
  },

  // REQ-ADM-LANG-05: Admin deletes a language route (Triggers ON DELETE CASCADE automatically)
  deleteLanguage: async (req, res) => {
    try {
      const languageId = req.params.id;

      const language = await Language.findByPk(languageId);
      if (!language) {
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang akan dihapus tidak ditemukan.",
        });
      }

      await language.destroy();

      return res.status(200).json({
        status: "success",
        message: "Bahasa berhasil dihapus. Seluruh materi, kuis, dan data riwayat terkait ikut dibersihkan.",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menghapus entitas data bahasa.",
        error: error.message,
      });
    }
  },
};

module.exports = languageController;
