const jwt = require("jsonwebtoken");
const JWT_SECRET = process.env.JWT_SECRET;

exports.authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token == null) {
    return res.status(401).json({ message: "Akses ditolak. Token tidak disediakan." });
  }

  jwt.verify(token, JWT_SECRET, (err, userPayload) => {
    if (err) {
      const message = err.name === "TokenExpiredError" ? "Sesi Anda telah berakhir. Silakan login kembali." : "Token tidak valid.";
      return res.status(403).json({ message });
    }
    req.user = userPayload;
    next();
  });
};

exports.isAdmin = (req, res, next) => {
  if (req.user && req.user.role === "admin") {
    next();
  } else {
    return res.status(403).json({ message: "Akses ditolak. Hanya untuk admin." });
  }
};
