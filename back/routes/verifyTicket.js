const express = require("express");
const router = express.Router();
const QRCode = require("qrcode");
const Booking = require("../models/Booking");

router.post("/verify-ticket", async (req, res) => {
    try {
        const { qrData } = req.body;
        const booking = await Booking.findOne({ qrCode: qrData });

        if (!booking || booking.status !== "booked") {
            return res.status(400).json({ message: "Invalid or Unverified Ticket" });
        }

        return res.json({ message: "Ticket Valid", booking });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
});
