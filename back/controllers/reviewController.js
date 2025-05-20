const Review = require("../models/Review");

// Create a review
exports.createReview = async (req, res) => {
    try {
        const { eventId, attendeeId, rating, comment } = req.body;
        const review = new Review({ eventId, attendeeId, rating, comment });
        await review.save();
        res.status(201).json(review);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// Get all reviews for a specific event
exports.getReviewsByEvent = async (req, res) => {
    try {
        const reviews = await Review.find({ eventId: req.params.eventId }).populate("attendeeId", "name");
        res.json(reviews);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getAllReviewEvent= async (req, res) => {
    try {
        const reviews = await Review.find({ eventId: req.params.eventId })
            .populate("attendeeId", "name avatar");
        res.json(reviews);
    } catch (error) {
        res.status(500).json({ error: "Error fetching reviews" });
    }
};


// Update a review
exports.updateReview = async (req, res) => {
    try {
        const { rating, comment } = req.body;
        const updatedReview = await Review.findByIdAndUpdate(
            req.params.reviewId,
            { rating, comment },
            { new: true }
        );
        res.json(updatedReview);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Delete a review
exports.deleteReview = async (req, res) => {
    try {
        await Review.findByIdAndDelete(req.params.reviewId);
        res.json({ message: "Review deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
