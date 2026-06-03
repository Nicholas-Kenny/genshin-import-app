const db = require("../config/db");

// read - get all items from catalog
exports.getAllItems = (req, res) => {
  const query = "SELECT * FROM items";
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json(results);
  });
};

// create - add new items
exports.createItem = (req, res) => {
  const { name, type, category, description, stock, price, stars } = req.body;
  let imageUrl = null;

  if (req.file) {
    imageUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
  }

  const query =
    "INSERT INTO items (name, type, category, description, stock, price, stars, image_url) VALUES (?,?,?,?,?,?,?,?)";

  db.query(
    query,
    [name, type, category, description, stock, price, stars, imageUrl],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({
        message: "Item successfully added",
        id: results.insertId,
        image_url: imageUrl,
      });
    },
  );
};

// update - edit existing items
exports.updateItem = (req, res) => {
  const itemId = req.params.id;
  const { name, type, category, description, stock, price, stars } = req.body;

  // PERBAIKAN: Ambil image_url lama dari body, tapi jika ada file baru di-upload, timpa dengan yang baru
  let imageUrl = req.body.image_url;
  if (req.file) {
    imageUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
  }

  const query =
    "UPDATE items SET name=?, type=?, category=?, description=?, stock=?, price=?, stars=?, image_url=? WHERE id=?";

  db.query(
    query,
    [name, type, category, description, stock, price, stars, imageUrl, itemId],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      if (results.affectedRows == 0) {
        return res.status(404).json({ message: "Item not found" });
      }

      res
        .status(200)
        .json({ message: "Item successfully edited", image_url: imageUrl });
    },
  );
};

// delete - delete item
exports.deleteItem = (req, res) => {
  const itemId = req.params.id;
  const query = "DELETE FROM items WHERE id=?";

  db.query(query, [itemId], (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (results.affectedRows == 0) {
      return res.status(404).json({ message: "Item not found" });
    }

    res.status(200).json({ message: "Item successfully deleted" });
  });
};
