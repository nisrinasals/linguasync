const { Material, Language, sequelize } = require("../models");

const materialController = {
  getMaterialsByLanguage: async (req, res) => {
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

      const { count, rows } = await Material.findAndCountAll({
        where: { language_id },
        limit,
        offset,
        order: [["order", "ASC"]],
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
        message: "Gagal memuat daftar materi pembelajaran.",
        error: error.message,
      });
    }
  },

  getMaterialById: async (req, res) => {
    try {
      const { id } = req.params;
      const material = await Material.findByPk(id);

      if (!material) {
        return res.status(404).json({
          status: "fail",
          message: "Detail materi tidak ditemukan.",
        });
      }

      return res.status(200).json({
        status: "success",
        data: material,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memuat rincian materi.",
        error: error.message,
      });
    }
  },

  createMaterial: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { language_id, title, content, order } = req.body;

      const languageExists = await Language.findByPk(language_id, { transaction: t });
      if (!languageExists) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "ID Bahasa induk tidak terdaftar.",
        });
      }

      const newMaterial = await Material.create(
        {
          language_id,
          title,
          content,
          order,
        },
        { transaction: t },
      );

      await t.commit();
      return res.status(201).json({
        status: "success",
        message: "Materi pembelajaran baru berhasil ditambahkan.",
        data: newMaterial,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan entitas materi.",
        error: error.message,
      });
    }
  },

  updateMaterial: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      const { title, content, order } = req.body;

      const material = await Material.findByPk(id, { transaction: t });
      if (!material) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Materi yang akan diperbarui tidak ditemukan.",
        });
      }

      await material.update({ title, content, order }, { transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Data materi pembelajaran berhasil diperbarui.",
        data: material,
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data materi.",
        error: error.message,
      });
    }
  },

  deleteMaterial: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;

      const material = await Material.findByPk(id, { transaction: t });
      if (!material) {
        await t.rollback();
        return res.status(404).json({
          status: "fail",
          message: "Materi yang akan dihapus tidak ditemukan.",
        });
      }

      await material.destroy({ transaction: t });
      await t.commit();
      return res.status(200).json({
        status: "success",
        message: "Materi berhasil dihapus dari sistem.",
      });
    } catch (error) {
      await t.rollback();
      return res.status(500).json({
        status: "error",
        message: "Gagal memproses penghapusan materi.",
        error: error.message,
      });
    }
  },
};

module.exports = materialController;
