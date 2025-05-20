const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/verifyToken');

const { CreateBooking, FetchBooking, AllBookings, RevenueMonthly, FetchBookingForOrganizer, AttendeBooking, deleteBooking, updateBooking } = require('../controllers/bookingController');

// Create a booking
router.post("/create-booking", verifyToken, CreateBooking);


// Fetch booking and QR code from ticket
router.get("/booking/:id", verifyToken, FetchBooking);


// Fetch All Bookings (For Admin)
router.get("/all-booking", verifyToken,AllBookings);

// Fetch Monthly Revenue + Total Revenue (For Admin)
router.get("/monthly-revenue", verifyToken,RevenueMonthly);


//fetch booking for a specific organizer event
router.get("/", verifyToken, FetchBookingForOrganizer);


router.get("/attendee", verifyToken,AttendeBooking);


//delete booking
router.delete("/:id", verifyToken, deleteBooking);

//update booking
router.put("/booking/:id", verifyToken,updateBooking);

module.exports = router;
