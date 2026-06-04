const db = require("../config/db");

// add items to cart
exports.addToCart = (req, res) => {
  const userId = req.user.id;
  const { item_id, quantity } = req.body;
  const qty = quantity || 1;

  const checkStockQuery = "SELECT stock FROM items WHERE id = ?";
  db.query(checkStockQuery, [item_id], (err, stockResults) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (stockResults.length === 0) {
      return res.status(404).json({ error: "Item not found" });
    }

    const productStock = stockResults[0].stock;

    if (productStock <= 0) {
      return res.status(400).json({ error: "Out of stock" });
    }

    const checkCartQuery =
      "SELECT quantity FROM cart WHERE user_id = ? AND item_id = ?";
    db.query(checkCartQuery, [userId, item_id], (err, cartResults) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      let currentQuantity;
      if (cartResults.length > 0) {
        currentQuantity = cartResults[0].quantity;
      } else {
        currentQuantity = 0;
      }

      if (currentQuantity + qty > productStock) {
        return res.status(400).json({ error: "Cannot exceed available stock" });
      }

      if (cartResults.length > 0) {
        const updateQuery =
          "UPDATE cart SET quantity = quantity + ? WHERE user_id = ? AND item_id = ?";
        db.query(updateQuery, [qty, userId, item_id], (err, results) => {
          if (err) {
            res.status(500).json({ error: err.message });
          }
          res
            .status(200)
            .json({ message: "item(s) successfully added to cart" });
        });
      } else {
        const insertQuery =
          "INSERT INTO cart(user_id, item_id, quantity) VALUES (?,?,?)";
        db.query(insertQuery, [userId, item_id, qty], (err, results) => {
          if (err) {
            return res.status(500).json({ error: err.message });
          }
          res.status(201).json({ message: "Item successfully added to cart" });
        });
      }
    });
  });
};

// get user cart details
exports.getCart = (req, res) => {
  const userId = req.user.id;

  const query = `
    SELECT c.id AS cart_id, c.item_id, i.name, i.type, i.category, i.stars, i.price, i.image_url, i.stock, c.quantity
    FROM cart c 
    JOIN items i ON c.item_id = i.id
    WHERE c.user_id = ?
    `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json(results);
  });
};

// buy item(s) from cart
exports.checkout = (req, res) => {
  const userId = req.user.id;

  const getCartQuery = `
    SELECT c.item_id, c.quantity, i.stock, i.name 
    FROM cart c 
    JOIN items i ON c.item_id = i.id 
    WHERE c.user_id = ?
  `;

  db.query(getCartQuery, [userId], (err, cartItems) => {
    if (err) return res.status(500).json({ error: err.message });
    if (cartItems.length === 0)
      return res.status(400).json({ error: "Keranjang Anda kosong" });

    for (let item of cartItems) {
      if (item.stock < item.quantity) {
        return res
          .status(400)
          .json({ error: `Stok untuk ${item.name} tidak mencukupi!` });
      }
    }
    const moveQuery = `
      INSERT INTO inventory (user_id, item_id, quantity) 
      SELECT user_id, item_id, quantity FROM cart WHERE user_id = ?
    `;

    db.query(moveQuery, [userId], (err, moveResult) => {
      if (err) return res.status(500).json({ error: err.message });

      let completedUpdates = 0;

      let isResponded = false;

      cartItems.forEach((item) => {
        const updateStockQuery =
          "UPDATE items SET stock = stock - ? WHERE id = ?";
        db.query(
          updateStockQuery,
          [item.quantity, item.item_id],
          (err, stockResults) => {
            if (isResponded) return;

            if (err) {
              isResponded = true;
              return res.status(500).json({ error: err.message });
            }

            completedUpdates++;
            if (completedUpdates === cartItems.length) {
              const clearCartQuery = "DELETE FROM cart WHERE user_id = ?";
              db.query(clearCartQuery, [userId], (err, clearResult) => {
                if (isResponded) return;

                if (err) {
                  isResponded = true;
                  return res.status(500).json({ error: err.message });
                }

                isResponded = true;
                res.status(200).json({
                  message:
                    "Pembelian berhasil! Barang telah dikirim ke Inventory Anda.",
                });
              });
            }
          },
        );
      });
    });
  });
};

// get user inventory details
exports.getInventory = (req, res) => {
  const userId = req.user.id;

  const query = `
    SELECT inv.id AS inventory_id, inv.item_id, i.name, i.type, i.category, i.image_url, inv.quantity, inv.purchased_at 
    FROM inventory inv 
    JOIN items i ON inv.item_id = i.id 
    WHERE inv.user_id = ?
    ORDER BY inv.purchased_at DESC
  `;

  db.query(query, [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
};

// remove cart item(s)
exports.reduceCart = (req, res) => {
  const userId = req.user.id;
  const { item_id } = req.body;

  const checkQuery = "SELECT * FROM cart WHERE user_id = ? AND item_id = ?";
  db.query(checkQuery, [userId, item_id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });

    if (results.length > 0) {
      if (results[0].quantity > 1) {
        // Jika qty lebih dari 1, kurangi 1
        const updateQuery =
          "UPDATE cart SET quantity = quantity - 1 WHERE user_id = ? AND item_id = ?";
        db.query(updateQuery, [userId, item_id], (err) => {
          if (err) return res.status(500).json({ error: err.message });
          res.status(200).json({ message: "Quantity dikurangi" });
        });
      } else {
        // Jika qty sisa 1, hapus dari keranjang
        const deleteQuery =
          "DELETE FROM cart WHERE user_id = ? AND item_id = ?";
        db.query(deleteQuery, [userId, item_id], (err) => {
          if (err) return res.status(500).json({ error: err.message });
          res.status(200).json({ message: "Item dihapus dari keranjang" });
        });
      }
    } else {
      res.status(404).json({ error: "Item tidak ditemukan" });
    }
  });
};
