const Ticket = require("../models/Ticket");

exports.UserTicket = async (req, res) => {
    try {
        const userId = req.user.id; // Extract user ID from the verified token
        const tickets = await Ticket.find({ user: userId }).populate("event", "title eventDate eventTime location").populate("booking", "event user ticketType ticketCount totalAmount").populate("user", "name");

        if (!tickets || tickets.length === 0) {
            return res.status(404).json({ message: "No tickets found for this user." });
        }

        res.json(tickets);
    } catch (error) {
        console.error("Error fetching user tickets:", error);
        res.status(500).json({ message: "Server error" });
    }
}

exports.DeleteTicket = async (req, res) => {
    try {
        const ticketId = req.params.ticketId;
        const userId = req.user.id; // Extract user ID from the verified token

        // Find the ticket and check if it belongs to the user
        const ticket = await Ticket.findOne({ _id: ticketId, user: userId });

        if (!ticket) {
            return res.status(404).json({ message: "Ticket not found or does not belong to this user." });
        }

        // Delete the ticket
        await Ticket.deleteOne({ _id: ticketId });
        console.log("Ticket deleted successfully:", ticketId);
        res.json({ message: "Ticket deleted successfully." });
    } catch (error) {
        console.error("Error deleting ticket:", error);
        res.status(500).json({ message: "Server error" });
    }
}