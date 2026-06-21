const { User } = require("../models");
const { Op } = require("sequelize");
const bcrypt = require("bcrypt");

const userController = {
  // Read all users (pagination + search by username/email + role filter)
  getAllUsers: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const search = req.query.search || "";
      const role = req.query.role || "";

      const whereClause = {
        [Op.or]: [
          { name: { [Op.like]: `%${search}%` } },
          { email: { [Op.like]: `%${search}%` } },
        ],
      };

      if (role) {
        whereClause.role = role;
      }

      const { count, rows } = await User.findAndCountAll({
        where: whereClause,
        limit,
        offset,
        order: [["name", "ASC"]],
        attributes: { reject: ["password"] },
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
        message: "Gagal mengambil data daftar pengguna.",
        error: error.message,
      });
    }
  },

  // Read single user details by ID
  getUserById: async (req, res) => {
    try {
      const user = await User.findByPk(req.params.id, {
        attributes: { reject: ["password"] },
      });
      if (!user) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna tidak ditemukan.",
        });
      }

      return res.status(200).json({
        status: "success",
        data: user,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal mengambil data pengguna.",
        error: error.message,
      });
    }
  },

  // Create new user (Admin version)
  createUser: async (req, res) => {
    try {
      const { name, email, password, role } = req.body;

      if (!name || !email || !password || !role) {
        return res.status(400).json({
          status: "fail",
          message: "Semua field (name, email, password, role) wajib diisi.",
        });
      }

      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({
          status: "fail",
          message: "Email sudah digunakan oleh akun lain.",
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          status: "fail",
          message: "Password harus terdiri dari minimal 6 karakter.",
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const newUser = await User.create({
        name,
        email,
        password: hashedPassword,
        role,
      });

      const responseUser = newUser.toJSON();
      delete responseUser.password;

      return res.status(201).json({
        status: "success",
        message: "Pengguna baru berhasil ditambahkan.",
        data: responseUser,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menambahkan pengguna baru.",
        error: error.message,
      });
    }
  },

  // Update user details (Admin version)
  updateUser: async (req, res) => {
    try {
      const user = await User.findByPk(req.params.id);
      if (!user) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna tidak ditemukan.",
        });
      }

      const { name, email, password, role } = req.body;

      if (email && email !== user.email) {
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          return res.status(400).json({
            status: "fail",
            message: "Email sudah digunakan oleh akun lain.",
          });
        }
        user.email = email;
      }

      if (name) user.name = name;
      if (role) user.role = role;

      if (password && password.trim() !== "") {
        if (password.length < 6) {
          return res.status(400).json({
            status: "fail",
            message: "Password harus terdiri dari minimal 6 karakter.",
          });
        }
        user.password = await bcrypt.hash(password, 10);
      }

      await user.save();

      const responseUser = user.toJSON();
      delete responseUser.password;

      return res.status(200).json({
        status: "success",
        message: "Data pengguna berhasil diperbarui.",
        data: responseUser,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal memperbarui data pengguna.",
        error: error.message,
      });
    }
  },

  // Delete user by ID
  deleteUser: async (req, res) => {
    try {
      const user = await User.findByPk(req.params.id);
      if (!user) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna tidak ditemukan.",
        });
      }

      // Hindari admin menghapus dirinya sendiri
      if (req.user.id === user.id) {
        return res.status(400).json({
          status: "fail",
          message: "Anda tidak dapat menghapus akun Anda sendiri.",
        });
      }

      await user.destroy();

      return res.status(200).json({
        status: "success",
        message: "Pengguna berhasil dihapus beserta data terkait.",
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Gagal menghapus pengguna.",
        error: error.message,
      });
    }
  },
};

module.exports = userController;
