const mongoose = require('mongoose');
 
const BookingSchema = new mongoose.Schema(
   {
        user : { type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true }, // Reference to the user booking the event
        event: { type: mongoose.Schema.Types.ObjectId,
         ref: 'Event', 
         required: true }, // Reference to the event being booked
        ticketType: { type: String,
         required: true }, // e.g., "VIP", "Regular", "Student"
        ticketCount: { type: Number, 
        required: true }, // Number of tickets
       totalAmount: { type: Number,
        required: true }, // Total amount of the tickets
      paymentId: { type: String, required: false }, // Payment ID from the payment gateway
      tx_ref: { // Add tx_ref to track the transaction reference
         type: String,
         required: true,
      },
      status: { type: String, enum: ['pending', 'booked', 'canceled'], default: 'pending' },
      createdAt: { type: Date, default: Date.now }, // Booking date
      updatedAt: { type: Date, default: Date.now }, // Last update date

}

)
module.exports = mongoose.model('Booking', BookingSchema);