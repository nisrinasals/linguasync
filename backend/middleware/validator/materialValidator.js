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

exports.materialValidation = [
  body("language_id").notEmpty().withMessage("Language ID wajib diisi.").isInt().withMessage("Language ID harus berupa angka bulat."),
  body("title").trim().notEmpty().withMessage("Judul materi wajib diisi."),
  body("content").trim().notEmpty().withMessage("Konten isi materi pembelajaran wajib diisi."),
  body("order").notEmpty().withMessage("Nomor urutan materi wajib diisi.").isInt({ min: 1 }).withMessage("Nomor urutan harus berupa angka bulat positif."),
  validate,
];
