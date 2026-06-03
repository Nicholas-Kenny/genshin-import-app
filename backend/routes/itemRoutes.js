const express = require("express");
const router = express.Router();
const itemController = require("../controllers/itemController");

const { verifyToken, isAdmin } = require("../middleware/authMiddleware");

const upload = require('../middleware/uploadMiddleware');

router.get("/", itemController.getAllItems);
router.post("/", verifyToken, isAdmin, upload.single('image'), itemController.createItem);
router.put("/:id", verifyToken, isAdmin, upload.single('image'), itemController.updateItem);
router.delete("/:id", verifyToken, isAdmin, itemController.deleteItem);

module.exports = router;
