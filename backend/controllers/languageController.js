const { Language, Enrollment, sequelize } = require("../models");
const { Op } = require("sequelize");

const languageController = {
  exploreLanguages: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const search = req.query.search || "";

      const { count, rows } = await Language.findAndCountAll({
        where: {
          name: { [Op.like]: `%${search}%` },
        },
        limit,
        offset,
        order: [["name", "ASC"]],
      });

      const userId = req.user ? req.user.id : null;
      
      const languagesWithEnrollment = await Promise.all(
        rows.map(async (lang) => {
          let isEnrolled = false;
          if (userId) {
            const enrollment = await Enrollment.findOne({
              where: { user_id: userId, language_id: lang.id },
            });
            isEnrolled = !!enrollment;
          }
          return {
            ...lang.toJSON(),
            is_enrolled: isEnrolled,
          };
        })
      );

      return res.status(200).json({
        status: "success",
        page,
        limit,
        totalItems: count,
        totalPages: Math.ceil(count / limit),
        data: languagesWithEnrollment,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memuat data eksplorasi bahasa.",
        });
    }
  },

  enrollLanguage: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { language_id } = req.body;
      const userId = req.user.id;

      const targetLanguage = await Language.findByPk(language_id, { transaction: t });
      if (!targetLanguage) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang dipilih tidak ditemukan.",
        });
      }

      const existingEnrollment = await Enrollment.findOne({
        where: { user_id: userId, language_id },
        transaction: t,
      });

      if (existingEnrollment) {
        await t.rollback();
        return res.status(400).json({
          status: "fail",
          message: "Anda sudah mendaftar (enrolled) pada kursus bahasa ini.",
        });
      }

      await Enrollment.create(
        {
          user_id: userId,
          language_id,
          status: "active",
        },
        { transaction: t },
      );

      await t.commit();
      return res.status(201).json({
        status: "success",
        message: "Pendaftaran bahasa berhasil. Selamat belajar!",
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan sistem saat memproses enrollment.",
        });
    }
  },

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
        });
    }
  },

  unenrollLanguage: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const enrollmentId = req.params.id;
      const userId = req.user.id;

      const enrollment = await Enrollment.findOne({
        where: { id: enrollmentId, user_id: userId },
        transaction: t,
      });

      if (!enrollment) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Data pendaftaran tidak ditemukan atau bukan milik Anda.",
        });
      }

      await enrollment.destroy({ transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Berhasil menghapus bahasa dari daftar MyStudy.",
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memproses penghapusan daftar studi.",
        });
    }
  },

  createLanguage: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { name, description } = req.body;
      const newLanguage = await Language.create({ name, description }, { transaction: t });
      await t.commit();
      return res.status(201).json({
        status: "success",
        message: "Entitas bahasa baru berhasil ditambahkan.",
        data: newLanguage,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan bahasa baru.",
        });
    }
  },

  updateLanguage: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const languageId = req.params.id;
      const { name, description } = req.body;

      const language = await Language.findByPk(languageId, { transaction: t });
      if (!language) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang akan diperbarui tidak ditemukan.",
        });
      }

      await language.update({ name, description }, { transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Informasi bahasa berhasil diperbarui.",
        data: language,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data bahasa.",
        });
    }
  },

  deleteLanguage: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const languageId = req.params.id;

      const language = await Language.findByPk(languageId, { transaction: t });
      if (!language) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Bahasa yang akan dihapus tidak ditemukan.",
        });
      }

      await language.destroy({ transaction: t });
      await t.commit();

      return res.status(200).json({
        status: "success",
        message: "Bahasa berhasil dihapus. Seluruh materi, kuis, dan data riwayat terkait ikut dibersihkan.",
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal menghapus entitas data bahasa.",
        });
    }
  },
};

module.exports = languageController;
