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

exports.submitValidation = [
  body("language_id").notEmpty().withMessage("Language ID wajib diisi.").isInt().withMessage("Language ID harus berupa angka bulat."),
  body("score").notEmpty().withMessage("Skor kuis wajib diisi.").isFloat({ min: 0, max: 100 }).withMessage("Skor harus berupa angka desimal/bulat antara 0 sampai 100."),
  validate,
];

exports.questionValidation = [
  body("language_id").notEmpty().withMessage("Language ID wajib diisi.").isInt().withMessage("Language ID harus berupa angka bulat."),
  body("question").trim().notEmpty().withMessage("Pertanyaan kuis wajib diisi."),
  body("opt_a").trim().notEmpty().withMessage("Pilihan opsi A wajib diisi."),
  body("opt_b").trim().notEmpty().withMessage("Pilihan opsi B wajib diisi."),
  body("opt_c").trim().notEmpty().withMessage("Pilihan opsi C wajib diisi."),
  body("opt_d").trim().notEmpty().withMessage("Pilihan opsi D wajib diisi."),
  body("answer").trim().notEmpty().withMessage("Kunci jawaban benar wajib diisi.").isIn(["A", "B", "C", "D"]).withMessage("Kunci jawaban harus berupa salah satu huruf kapital: A, B, C, atau D."),
  validate,
];
