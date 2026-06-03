const express = require("express");
const cors = require("cors");
require("dotenv").config();

const db = require("./config/db");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("Hello World!");
});

// itemRoutes
const itemRoutes = require("./routes/itemRoutes");
app.use("/api/items", itemRoutes);

// authRoutes
const authRoutes = require("./routes/authRoutes");
app.use("/api/auth", authRoutes);

//cartRoutes
const cartRoutes = require("./routes/cartRoutes");
app.use("/api/cart", cartRoutes);

// localhost
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`app listening on port ${port}`);
});
