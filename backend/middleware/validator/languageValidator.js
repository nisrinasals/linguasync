const { body, validationResult } = require("express-validator");
const { Language } = require("../../models");
const { Op } = require("sequelize");

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

exports.languageValidation = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Nama bahasa wajib diisi.")
    .custom(async (value, { req }) => {
      const languageId = req.params.id;
      const whereCondition = { name: value };

      if (languageId) {
        whereCondition.id = { [Op.ne]: languageId };
      }

      const existingLanguage = await Language.findOne({ where: whereCondition });
      if (existingLanguage) {
        throw new Error("Nama bahasa ini sudah terdaftar di database.");
      }
      return true;
    }),
  body("description").trim().notEmpty().withMessage("Deskripsi bahasa wajib diisi."),
  validate,
];

exports.enrollValidation = [body("language_id").notEmpty().withMessage("Language ID wajib disertakan.").isInt().withMessage("Language ID harus berupa angka bilangan bulat."), validate];
