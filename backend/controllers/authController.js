const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { User } = require("../models");

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN;

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        status: "fail",
        message: "Email is already registered.",
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
      message: "Account successfully registered. Please proceed to login.",
    });
  } catch (error) {
    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(400).json({
        status: "fail",
        message: "Email already registered. Please use another Email.",
      });
    }
    res.status(500).json({
      status: "error",
      message: "Terjadi kesalahan pada server",
      error: error.message,
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Access database data block using email reference index values
    const user = await User.findOne({ where: { email } });

    // Early rejection block to avoid execution delays or timing leaks
    if (!user) {
      return res.status(401).json({
        status: "fail",
        message: "Invalid email or password.",
      });
    }

    // REQ-LOGIN-03: Evaluate stored Bcrypt string values against raw parameters
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        status: "fail",
        message: "Invalid email or password.",
      });
    }

    // REQ-LOGIN-04 / REQ-LOGIN-06: Formulate standard industry payload layout
    const tokenPayload = {
      id: user.id,
      role: user.role,
    };

    // Wrap payload values inside sign function bound to security deadlines
    const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    // Return a 200 OK status code with user dataset parameters for Flutter's secure state tracking
    return res.status(200).json({
      status: "success",
      message: "Authentication successful.",
      data: {
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    // REQ-LOGIN-07: Comprehensive crash catching protection response block
    return res.status(500).json({
      status: "error",
      message: "An internal server error occurred during authentication.",
      error: error.message,
    });
  }
};
