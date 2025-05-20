const express = require("express");
const verifyToken=require('../middlewares/verifyToken')
const { bookmarkEvent, unbookmarkEvent, getBookmarkedEvents ,toggleBookmark} = require("../controllers/bookmarkController");

const router = express.Router();

router.post("/event/:id/bookmark", verifyToken, bookmarkEvent);
router.delete("/event/:id/unbookmark", verifyToken, unbookmarkEvent);
router.get("/bookmarkedEvents", verifyToken, getBookmarkedEvents);
router.post("/event/:eventId/toggle", verifyToken, toggleBookmark);

module.exports = router;
