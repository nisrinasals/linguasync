const { body, validationResult } = require("express-validator");

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      status: "fail",
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
      })),
    });
  }
  next();
};

const authValidator = {
  registerValidation: [
    body("name").trim().notEmpty().withMessage("Nama lengkap wajib diisi."),
    body("email").trim().notEmpty().withMessage("Email wajib diisi.").isEmail().withMessage("Format email tidak valid."),
    body("password").notEmpty().withMessage("Password wajib diisi.").isLength({ min: 6 }).withMessage("Password harus terdiri dari minimal 6 karakter."),
    validate,
  ],

  loginValidation: [body("email").trim().notEmpty().withMessage("Email wajib diisi.").isEmail().withMessage("Format email tidak valid."), body("password").notEmpty().withMessage("Password wajib diisi."), validate],
};

module.exports = authValidator;
