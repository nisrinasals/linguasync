const fs = require("fs");
const path = require("path");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { User } = require("../models");

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN;

const authController = {
  // REQ-REG: Proses Pendaftaran Pengguna Baru
  register: async (req, res) => {
    try {
      const { name, email, password } = req.body;

      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({
          status: "fail",
          message: "Email sudah terdaftar. Silakan gunakan email lain.",
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      await User.create({
        name,
        email,
        password: hashedPassword,
        role: "user",
      });

      return res.status(201).json({
        status: "success",
        message: "Akun berhasil didaftarkan. Silakan login.",
      });
    } catch (error) {
      if (error.name === "SequelizeUniqueConstraintError") {
        return res.status(400).json({
          status: "fail",
          message: "Email sudah terdaftar. Silakan gunakan email lain.",
        });
      }
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan internal pada server.",
      });
    }
  },

  // REQ-LOGIN: Proses Autentikasi Masuk Sesi Akun
  login: async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await User.findOne({ where: { email } });

      if (!user) {
        return res.status(401).json({
          status: "fail",
          message: "Email atau password salah.",
        });
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          status: "fail",
          message: "Email atau password salah.",
        });
      }

      const tokenPayload = {
        id: user.id,
        role: user.role,
      };

      const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

      return res.status(200).json({
        status: "success",
        message: "Autentikasi berhasil.",
        data: {
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            foto_profile: user.foto_profile,
          },
        },
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan internal pada server.",
      });
    }
  },

  // Fetch Current Logged-in User Profile details
  getProfile: async (req, res) => {
    try {
      const user = await User.findByPk(req.user.id);
      if (!user) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna tidak ditemukan.",
        });
      }

      return res.status(200).json({
        status: "success",
        data: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          foto_profile: user.foto_profile,
        },
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan internal pada server.",
      });
    }
  },

  // Update Current Logged-in User Profile details and handle photo uploads
  updateProfile: async (req, res) => {
    try {
      const user = await User.findByPk(req.user.id);
      if (!user) {
        return res.status(404).json({
          status: "fail",
          message: "Pengguna tidak ditemukan.",
        });
      }

      const { name, email, password, old_password } = req.body;

      if (email && email !== user.email) {
        const existingEmail = await User.findOne({ where: { email } });
        if (existingEmail) {
          return res.status(400).json({
            status: "fail",
            message: "Email sudah digunakan oleh akun lain.",
          });
        }
        user.email = email;
      }

      if (name) {
        user.name = name;
      }

      if (password && password.trim() !== "") {
        if (!old_password) {
          return res.status(400).json({
            status: "fail",
            message: "Password lama wajib diisi untuk mengubah password.",
          });
        }
        const isOldPasswordValid = await bcrypt.compare(old_password, user.password);
        if (!isOldPasswordValid) {
          return res.status(401).json({
            status: "fail",
            message: "Password lama yang Anda masukkan salah.",
          });
        }
        if (password.length < 6) {
          return res.status(400).json({
            status: "fail",
            message: "Password baru harus terdiri dari minimal 6 karakter.",
          });
        }
        user.password = await bcrypt.hash(password, 10);
      }

      if (req.file) {
        // Delete old profile photo if it exists
        if (user.foto_profile) {
          const oldFilePath = path.join(__dirname, "../uploads", user.foto_profile);
          if (fs.existsSync(oldFilePath)) {
            try {
              fs.unlinkSync(oldFilePath);
            } catch (err) {
              console.error("Failed to delete old profile photo file:", err);
            }
          }
        }
        user.foto_profile = req.file.filename;
      }

      await user.save();

      return res.status(200).json({
        status: "success",
        message: "Profil Anda berhasil diperbarui.",
        data: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          foto_profile: user.foto_profile,
        },
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: "Terjadi kesalahan sistem saat memperbarui profil.",
        error: error.message,
      });
    }
  },
};

module.exports = authController;
