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
    body("name").trim().notEmpty().withMessage("Full name is required."),
    body("email").trim().notEmpty().withMessage("Email is required.").isEmail().withMessage("Invalid email format."),
    body("password").notEmpty().withMessage("Password is required.").isLength({ min: 6 }).withMessage("Password must be at least 6 characters long."),
    body("confirmPassword")
      .notEmpty()
      .withMessage("Confirmation password is required.")
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error("Passwords do not match.");
        }
        return true;
      }),
    validate,
  ],

  loginValidation: [body("email").trim().notEmpty().withMessage("Email is required.").isEmail().withMessage("Invalid email format."), body("password").notEmpty().withMessage("Password is required."), validate],
};

module.exports = authValidator;
