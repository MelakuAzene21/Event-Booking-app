const Booking = require("../models/Booking");
const Event = require("../models/Event");
exports.ReportOrganizer = async (req, res) => {
    try {
        const { eventId, startDate, endDate } = req.query;
        const organizerId = req.user._id; // Get organizer's ID from auth

        let eventFilter = { organizer: organizerId };
        if (eventId) eventFilter._id = eventId;

        // Fetch events created by the organizer
        const events = await Event.find(eventFilter);
        if (events.length === 0) {
            return res.status(200).json({ message: "No events found for this organizer." });
        }

        const eventIds = events.map(event => event._id);

        // Filter bookings based on date range
        let bookingFilter = { event: { $in: eventIds }, status: "booked" };
        if (startDate && endDate) {
            bookingFilter.createdAt = { $gte: new Date(startDate), $lte: new Date(endDate) };
        }

        // Fetch bookings for the organizer's events
        const bookings = await Booking.find(bookingFilter);

        const totalBookings = bookings.length;
        const totalRevenue = bookings.reduce((acc, booking) => acc + booking.totalAmount, 0);
        const totalTicketsSold = bookings.reduce((acc, booking) => acc + booking.ticketCount, 0);

        // Group revenue by month
        const monthlyRevenue = {};
        bookings.forEach((booking) => {
            const date = new Date(booking.createdAt);
            const yearMonth = `${date.getFullYear()}-${date.getMonth() + 1}`;

            if (!monthlyRevenue[yearMonth]) {
                monthlyRevenue[yearMonth] = { totalRevenue: 0, totalBookings: 0 };
            }

            monthlyRevenue[yearMonth].totalRevenue += booking.totalAmount;
            monthlyRevenue[yearMonth].totalBookings += 1;
        });

        res.status(200).json({
            totalBookings,
            totalRevenue,
            totalTicketsSold,
            monthlyRevenue: Object.entries(monthlyRevenue).map(([key, value]) => ({
                month: key,
                ...value,
            })),
        });

    } catch (error) {
        console.error("Error fetching reports:", error);
        res.status(500).json({ error: "Failed to generate reports" });
    }
}