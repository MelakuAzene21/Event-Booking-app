const mongoose = require('mongoose');

const ticketSchema = new mongoose.Schema(
    {
        booking: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true }, // Reference to the Booking
        event: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true }, // Reference to the Event
        user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the User
        ticketNumber: { type: String, required: true, unique: true }, // Unique ticket identifier
        qrCode: { type: String, required: true }, // QR code data (URL or base64)
        isUsed: { type: Boolean, default: false }, // Whether the ticket has been checked in
    },
    { timestamps: true } // Automatically adds createdAt and updatedAt fields
);

module.exports = mongoose.model('Ticket', ticketSchema);
