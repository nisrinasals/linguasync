const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const authController = require("../controllers/authController");
const { authenticateToken } = require("../middleware/authMiddleware");
const { registerValidation, loginValidation } = require("../middleware/validator/authValidator");

// Multer File Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, "../uploads");
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|webp/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error("Hanya diperbolehkan mengunggah file gambar (jpeg, jpg, png, webp)!"));
  },
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB limit
});

router.post("/register", registerValidation, authController.register);
router.post("/login", loginValidation, authController.login);
router.get("/profile", authenticateToken, authController.getProfile);
router.put("/profile", authenticateToken, upload.single("foto_profile"), authController.updateProfile);

module.exports = router;
