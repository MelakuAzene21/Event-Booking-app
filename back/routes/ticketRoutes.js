const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/verifyToken");
const { UserTicket, DeleteTicket } = require("../controllers/ticketController");
// Fetch all tickets for a logged-in user
router.get("/user", verifyToken, UserTicket);

router.delete("/delete/:ticketId", verifyToken, DeleteTicket);
module.exports = router;
