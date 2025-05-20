const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/verifyToken');
const Booking = require('../models/Booking');
const Event = require('../models/Event');
const Ticket = require('../models/Ticket');
const sendEmail = require('../helpers/Send-Email');
const User = require("../models/User");
const QRCode = require("qrcode");

exports.CreateBooking = async (req, res) => {
    try {
        req.body.user = req.user._id;

        // Create a booking
        const booking = await Booking.create(req.body);

        // Find the event
        const event = await Event.findById(req.body.event);
        if (!event) {
            return res.status(404).json({ message: "Event not found" });
        }

        // Update ticket availability
        let updatedTicketsTypes = event.ticketTypes.map(ticketType => {
            if (ticketType.name === req.body.ticketType) {
                ticketType.booked = (ticketType.booked ?? 0) + Number(req.body.ticketCount);
                ticketType.available = (ticketType.available ?? ticketType.limit) - Number(req.body.ticketCount);
            }
            return ticketType;
        });

        event.ticketTypes = updatedTicketsTypes;
        await event.save();

        // Generate tickets and QR codes
        const tickets = [];
        const qrCodeAttachments = [];

        for (let i = 0; i < booking.ticketCount; i++) {
            // Generate a unique ticket number
            const ticketNumber = `TCK-${Date.now()}-${i}`;

            // Generate QR code data
            const qrData = `${ticketNumber}-${req.user._id}-${req.body.event}`;

            // Generate QR code as Data URL
            const qrCodeImage = await QRCode.toDataURL(qrData);

            // Save ticket in the database
            const ticket = await Ticket.create({
                booking: booking._id,
                event: booking.event,
                user: booking.user,
                ticketNumber: ticketNumber,
                qrCode: qrData,
                isUsed: false
            });

            tickets.push(ticket);

            // Push QR code as an attachment
            qrCodeAttachments.push({
                filename: `Ticket-${i + 1}.png`,
                content: qrCodeImage.split("base64,")[1], // Extract base64 image data
                encoding: "base64"
            });
        }

        const attendee = await User.findById(req.body.user);

        // Create ticket details for email
        const ticketDetails = tickets.map((ticket, index) => `
            <p><strong>Ticket ${index + 1}:</strong> ${ticket.ticketNumber}</p>
        `).join('');

        // Send Booking Confirmation Email
        await sendEmail(attendee.email, "Your Ticket Booking Confirmation", "ticketConfirmation", {
            name: attendee.name,
            eventTitle: event.title,
            eventDate: event.eventDate.toDateString(),
            eventTime: event.eventTime,
            eventLocation: event.location,
            ticketCount: booking.ticketCount,
            ticketDetails: ticketDetails
        }, qrCodeAttachments);

        return res.status(201).json({ message: "Booking Successfully Created", booking });

    } catch (error) {
        console.error('Error occurred: ', error);
        return res.status(500).json({ message: error.message });
    }
}



exports.FetchBooking=async (req, res) => {
    try {
        const tickets = await Ticket.find({booking:req.params.id});   // Find the booking
        if(!tickets||tickets.length===0){
            return res.status(404).json({ message: "Ticket not found for this Booking" });
        }
        res.json(tickets);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

exports.AllBookings= async (req, res) => {
    try {
        const bookings = await Booking.find({ status: "booked" }) // Only fetch booked bookings
            .populate("user", "name") // Fetch only 'name' field from User model
            .populate("event", "title eventDate"); // Fetch 'title' and 'eventDate' from Event model

        // Calculate total revenue by summing up 'totalAmount' of booked tickets
        const totalRevenue = bookings.reduce((sum, booking) => sum + booking.totalAmount, 0);

        res.json({ bookings, totalRevenue });
    } catch (error) {
        console.error("Error fetching bookings:", error);
        res.status(500).json({ message: "Failed to fetch bookings" });
    }
}


exports.RevenueMonthly= async (req, res) => {
    try {
        const bookings = await Booking.aggregate([
            {
                $match: { status: "booked" } // Only include successful bookings
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$createdAt" },
                        month: { $month: "$createdAt" }
                    },
                    totalRevenue: { $sum: "$totalAmount" } // Sum revenue per month
                }
            },
            { $sort: { "_id.year": 1, "_id.month": 1 } } // Sort by year and month
        ]);

        // Calculate total revenue across all months
        const totalRevenue = bookings.reduce((sum, entry) => sum + entry.totalRevenue, 0);

        res.json({ totalRevenue, monthlyRevenue: bookings });
    } catch (error) {
        console.error("Error fetching monthly revenue:", error);
        res.status(500).json({ message: "Failed to fetch monthly revenue" });
    }
}

exports.FetchBookingForOrganizer = async (req, res) => {
    try {
        const organizerId = req.user.id; // Assuming the logged-in user is an organizer

        // Find bookings where the event's organizer matches the logged-in user's ID
        const bookings = await Booking.find()
            .populate({
                path: "event",
                match: { organizer: organizerId }, // Filter events by the organizer
                select: "title eventDate" // Only select title and eventDate
            })
            .populate("user", "name") // Fetch the user's name
            .exec();

        // Remove bookings where the event is null (i.e., does not belong to the organizer)
        const filteredBookings = bookings.filter(booking => booking.event !== null);

        res.json(filteredBookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

exports.AttendeBooking = async (req, res) => {
    try {
        const bookings = await Booking.find({
            user: req.user._id,
            // Ensure user and event fields are not null
            $and: [{ user: { $ne: null } }, { event: { $ne: null } }],
        })
            .populate({
                path: "user",
                select: "name",
                match: { _id: { $exists: true } }, // Ensure populated user exists
            })
            .populate({
                path: "event",
                select: "title eventDate",
                match: { _id: { $exists: true } }, // Ensure populated event exists
            });

        // Filter out bookings where user or event is null after population
        const validBookings = bookings.filter(
            booking => booking.user && booking.event
        );

        res.json(validBookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
exports.deleteBooking=async (req, res) => {
    try {
        const booking = await Booking.findById(req.params.id);
        if (!booking) {
            return res.status(404).json({ message: "Booking not found" });
        }

        await booking.deleteOne();
        res.json({ message: "Booking deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}


exports.updateBooking = async (req, res) => {
    try {
        let booking = await Booking.findById(req.params.id);
        if (!booking) {
            return res.status(404).json({ message: "Booking not found" });
        }
        booking = await Booking.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ message: "Booking updated successfully", booking });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}