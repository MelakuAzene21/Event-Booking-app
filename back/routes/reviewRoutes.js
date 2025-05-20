const express = require("express");
const {
    createReview,
    getReviewsByEvent,
    updateReview,
    deleteReview,
    getAllReviewEvent,
} = require("../controllers/reviewController");

const router = express.Router();

router.post("/", createReview);
router.get("/:eventId", getReviewsByEvent);
router.put("/:reviewId", updateReview);
router.delete("/:reviewId", deleteReview);
router.get("/:eventId", getAllReviewEvent);
module.exports = router;
