const db = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// register
exports.register = async (req, res) => {
  const { username, email, password } = req.body;
  if (!password || password.length < 8) {
    return res.status(400).json({ 
      error: "Validation error", 
      detail: "Password must be at least 8 characters" 
    });
  }
  try {
    const hashedpassword = await bcrypt.hash(password, 10);
    const query =
      "INSERT INTO users (username, email, password) VALUES (?,?,?)";
    db.query(query, [username, email, hashedpassword], (err, results) => {
      if (err) {
        return res.status(400).json({
          error: "Email / Username already registered",
          detail: err.message,
        });
      }

      res
        .status(201)
        .json({ message: "Successfully registered! Now please login" });
    });
  } catch (error) {
    res.status(500).json({ error: "Server error: " + error.message });
  }
};

// login
exports.login = (req, res) => {
  const { username, password } = req.body;
  const query = "SELECT * FROM users WHERE username=?";
  db.query(query, [username], async (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (results.length === 0) {
      return res.status(400).json({ error: "Username not found" });
    }

    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Wrong Password" });
    }

    const token = jwt.sign(
      {
        id: user.id,
        role: user.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "24h",
      },
    );
    res.status(200).json({
      message: "Login Successfully",
      token: token,
      role: user.role,
    });
  });
};

//login - google
exports.googleLogin = async (req, res) => {
  const { idToken } = req.body;
  try {
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const email = payload["email"];
    const username = email.split("@")[0];

    const checkQuery = "SELECT * FROM users WHERE email=?";
    db.query(checkQuery, [email], (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      if (results.length > 0) {
        const user = results[0];
        const token = jwt.sign(
          {
            id: user.id,
            role: user.role,
          },
          process.env.JWT_SECRET,
          { expiresIn: "24h" },
        );
        return res.status(200).json({
          message: "Successfully login with google",
          token: token,
          role: user.role,
        });
      } else {
        const insertQuery =
          "INSERT INTO users(username, email, oauth_provider)VALUES (?, ?, ?)";
        db.query(insertQuery, [username, email, "google"], (err, results) => {
          if (err) {
            return res.status(400).json({
              error: "Register via google failed",
              detail: err.message,
            });
          }

          const token = jwt.sign(
            {
              id: results.insertId,
              role: "customer",
            },
            process.env.JWT_SECRET,
            { expiresIn: "24h" },
          );
          return res.status(201).json({
            message: "Successfully register and login with google",
            token: token,
            role: "customer",
          });
        });
      }
    });
  } catch (error) {
    res
      .status(401)
      .json({ error: "Google token not valid", detail: error.message });
  }
};
