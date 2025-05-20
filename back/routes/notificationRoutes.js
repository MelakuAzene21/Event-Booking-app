const express = require("express");
const router = express.Router();
const { getUserNotifications, markNotificationAsRead, adminNotification, markNotificationAsReadAdmin } = require("../controllers/notificationController");
const verifyToken = require("../middlewares/verifyToken");

router.get("/unread-notifications",verifyToken, getUserNotifications);
router.get("/admin/:userId", verifyToken,adminNotification);
router.put("/mark-as-read", verifyToken, markNotificationAsRead);
router.post("/admin/mark-read", verifyToken, markNotificationAsReadAdmin);

module.exports = router;
