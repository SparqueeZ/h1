const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
  let token = req.cookies.token;
  if (!req.cookies.token) {
    token = req.headers["token"];
  }
  if (!token) {
    return res.status(401).send("Access denied");
  }

  try {
    const decoded = jwt.verify(token, "your_jwt_secret");
    req.user = decoded;
    next();
  } catch (error) {
    res.status(400).send("Invalid token");
  }
};

module.exports = authenticateToken;
