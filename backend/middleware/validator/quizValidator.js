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
  body("language_id").optional({ checkFalsy: true }).isInt().withMessage("Language ID harus berupa angka bulat."),
  body("question").trim().notEmpty().withMessage("Pertanyaan kuis wajib diisi."),
  body("opt_a")
    .trim()
    .notEmpty()
    .withMessage("Pilihan opsi A wajib diisi.")
    .custom((value, { req }) => {
      const opts = [value, req.body.opt_b, req.body.opt_c, req.body.opt_d].map(o => o ? o.toString().trim().toLowerCase() : '');
      const nonEmpties = opts.filter(o => o !== '');
      const uniqueOpts = new Set(nonEmpties);
      if (uniqueOpts.size !== nonEmpties.length) {
        throw new Error("Pilihan opsi jawaban (A, B, C, D) tidak boleh ada yang sama.");
      }
      return true;
    }),
  body("opt_b").trim().notEmpty().withMessage("Pilihan opsi B wajib diisi."),
  body("opt_c").trim().notEmpty().withMessage("Pilihan opsi C wajib diisi."),
  body("opt_d").trim().notEmpty().withMessage("Pilihan opsi D wajib diisi."),
  body("answer").trim().notEmpty().withMessage("Kunci jawaban benar wajib diisi.").isIn(["A", "B", "C", "D"]).withMessage("Kunci jawaban harus berupa salah satu huruf kapital: A, B, C, atau D."),
  validate,
];
