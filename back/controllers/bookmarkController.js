const Bookmark = require("../models/Bookmark");
const Event = require("../models/Event");
const mongoose=require('mongoose')
// 📌 Bookmark an Event
const bookmarkEvent = async (req, res) => {
    try {
        const eventId = req.params.id;
        const userId = req.user._id;

        // Check if already bookmarked
        const existingBookmark = await Bookmark.findOne({ userId, eventId });
        if (existingBookmark) {
            return res.status(400).json({ success: false, message: "Event already bookmarked" });
        }

        const newBookmark = new Bookmark({ userId, eventId });
        await newBookmark.save();

        res.json({ success: true, message: "Event bookmarked successfully" });
    } catch (error) {
        console.error("Error bookmarking event:", error);
        res.status(500).json({ success: false, message: "Error bookmarking event" });
    }
};

// 📌 Unbookmark an Event
const unbookmarkEvent = async (req, res) => {
    try {
        const eventId = req.params.id;
        const userId = req.user._id;

        const deletedBookmark = await Bookmark.findOneAndDelete({ userId, eventId });

        if (!deletedBookmark) {
            return res.status(404).json({ success: false, message: "Bookmark not found" });
        }

        res.json({ success: true, message: "Event unbookmarked successfully" });
    } catch (error) {
        console.error("Error unbookmarking event:", error);
        res.status(500).json({ success: false, message: "Error unbookmarking event" });
    }
};

// 📌 Fetch All Bookmarked Events
const getBookmarkedEvents = async (req, res) => {
    try {
        const userId = req.user._id;

        const bookmarkedEvents = await Bookmark.find({ userId }).populate({
            path: "eventId",
            populate: { path: "user", select: "name" } // Populate event owner details
        });
        if (!bookmarkedEvents.length) {
            return res.status(404).json({ success: false, message: "No bookmarks found" });
        }
        const events = bookmarkedEvents.map(bookmark => bookmark.eventId);

        res.status(200).json(events);
    } catch (error) {
        console.error("Error fetching bookmarked events:", error);
        res.status(500).json({ error: "Failed to fetch bookmarked events" });
    }
};


const toggleBookmark = async (req, res) => {
    try {
        const { eventId } = req.params;
        const userId = req.user._id;

        if (!mongoose.isValidObjectId(eventId)) {
            return res.status(400).json({ error: "Invalid event ID format" });
        }

        const event = await Event.findById(eventId);
        if (!event) {
            return res.status(404).json({ error: "Event not found" });
        }

        // Check if the bookmark exists for this user
        const existingBookmark = await Bookmark.findOne({ userId, eventId });

        if (existingBookmark) {
            // If it exists, remove the bookmark (unbookmark)
            await Bookmark.deleteOne({ _id: existingBookmark._id });

            return res.status(200).json({
                success: true,
                message: "Bookmark removed",
                isBookmarked: false, // Indicate that the bookmark was removed
            });
        } else {
            // If it doesn't exist, create a new bookmark (bookmark the event)
            await Bookmark.create({ userId, eventId });

            return res.status(201).json({
                success: true,
                message: "Bookmarked successfully",
                isBookmarked: true, // Indicate that the event is now bookmarked
            });
        }
    } catch (error) {
        console.error("Error toggling bookmark:", error);
        res.status(500).json({ success: false, message: "Failed to update bookmark" });
    }
};


module.exports = { bookmarkEvent, unbookmarkEvent, getBookmarkedEvents,toggleBookmark };
