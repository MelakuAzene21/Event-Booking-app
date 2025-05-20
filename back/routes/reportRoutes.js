const express = require("express");
const router = express.Router();

const verifyToken = require("../middlewares/verifyToken");
const { ReportOrganizer } = require("../controllers/reportController");

// Get event reports for the organizer
router.get("/", verifyToken, ReportOrganizer);

module.exports = router;
