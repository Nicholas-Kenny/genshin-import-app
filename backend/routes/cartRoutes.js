const express = require("express");
const router = express.Router();
const cartController = require("../controllers/cartController");
const { verifyToken } = require("../middleware/authMiddleware");

router.use(verifyToken);

router.post("/add", cartController.addToCart);
router.get("/", cartController.getCart);
router.post("/checkout", cartController.checkout);
router.get("/inventory", cartController.getInventory);
router.post("/reduce", cartController.reduceCart);

module.exports = router;
