const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
    {
        title: { type: String, required: true },
        description: { type: String },
        category: { type: String },
        eventDate: { type: Date, required: true }, // If 'date' is the same as 'eventDate', you can remove one of them
        eventTime: { type: String, required: true },
        location: {
            name: { type: String, required: false }, // e.g., "New York"
            latitude: { type: Number, required: false }, // Latitude
            longitude: { type: Number, required: false }, // Longitude
        },
        organizer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the user organizing the event
        user: { // Ensure this field exists
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: false
        },
        
        ticketTypes: [
            {
                name: { type: String, required: false }, // e.g., "VIP", "Regular", "Student"
                price: { type: Number, required: false }, // price of the ticket
                limit: { type: Number, required: false, min: 0 },// Number of tickets available
                booked: { type: Number, default: 0 }, // Number of tickets booked
                available: { type: Number, default: function () { return this.limit; } } // Number of tickets available
            }
        ],
        images: { type: [String], required: false }, // URL or path to an event image
        likes: { type: Number, default: 0 }, // Number of likes
        usersLiked: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Users who liked the event
        bookmarkedBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Users who bookmarked the event
        status: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },

    },
    { timestamps: true } // Automatically add createdAt and updatedAt fields
);

module.exports = mongoose.model('Event', eventSchema)