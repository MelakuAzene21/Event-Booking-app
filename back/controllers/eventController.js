// const Event = require('../models/Event');
// const User = require('../models/User')
// const { cloudinary } = require('../utils/cloudinaryConfig');

// // Event creation handler with multiple image uploads
// exports.createEvent = async (req, res) => {
//     try {
//         const {
//             title,
//             description,
//             category,
//             eventDate,
//             eventTime,
//             location,
//             organizedBy,
//             ticketPrice,
//             Quantity,
//             tickets
//         } = req.body;

//         // Ensure tickets are provided
//         if (!tickets || tickets.length === 0) {
//             return res.status(400).json({ message: 'At least one ticket type is required' });
//         }

//         // Ensure at least one image is uploaded
//         if (!req.files || req.files.length === 0) {
//             return res.status(400).json({ message: 'At least one event image is required' });
//         }

//         // Ensure no more than 5 images are uploaded
//         if (req.files.length > 5) {
//             return res.status(400).json({ message: 'You can upload up to 5 images only' });
//         }

//         // Save image paths
//         const images = req.files.map(file => `/uploads/events/${file.filename}`);
       
       
//         // Cloudinary image URLs
//         // const images = req.files.map(file => file.path);
        
//         const ticketDetails = JSON.parse(tickets);

//         const newEvent = new Event({
//             title,
//             description,
//             category,
//             eventDate,
//             eventTime,
//             location,
//             organizedBy,
//             organizer: req.user._id, // Use the logged-in user ID as the organizer
//             ticketPrice: Number(ticketPrice),
//             Quantity: Number(Quantity),
//             image: images ,// Save array of image paths
//           tickets: ticketDetails, // Array of ticket details

//         });

//         const savedEvent = await newEvent.save();
//         res.status(201).json(savedEvent);
//     } catch (error) {
//         console.error('Error creating event:', error);
//         res.status(500).json({ message: 'Error creating event', error: error.message });
//     }
// };

const Event = require('../models/Event');
const mongoose = require("mongoose");
const User = require('../models/User');
const { cloudinary } = require('../utils/cloudinaryConfig');
const Booking = require('../models/Booking');
const BookMark = require('../models/Bookmark')
const Notification = require("../models/Notification");
const io = require("../config/socket"); // Import WebSocket instance
const { getIO } = require("../config/socket");
const sendEmail =require("../helpers/Send-Email")

const axios = require("axios");

// // Function to get coordinates from OpenStreetMap
// async function getCoordinates(location) {
//     const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(
//         location
//     )}&format=json&limit=1`;

//     try {
//         const response = await axios.get(url);
//         if (response.data.length === 0) return null; // No results found

//         const { lat, lon } = response.data[0];
//         return { latitude: parseFloat(lat), longitude: parseFloat(lon) };
//     } catch (error) {
//         console.error("Error fetching coordinates:", error);
//         return null;
//     }
// }


// Function to get coordinates from OpenStreetMap and ensure location is in Ethiopia
async function getCoordinates(location) {
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(
        location
    )}&format=json&limit=5&addressdetails=1`; // Request multiple results with address details

    try {
        const response = await axios.get(url);
        if (response.data.length === 0) return null; // No results found

        // Filter results to only those in Ethiopia (country_code = "et")
        const ethiopiaLocations = response.data.filter(
            place => place.address && place.address.country_code === "et"
        );

        if (ethiopiaLocations.length === 0) {
            return null; // No Ethiopian locations found
        }

        // Take the first Ethiopian location
        const { lat, lon, display_name } = ethiopiaLocations[0];
        return {
            name: display_name, // Full Ethiopian place name
            latitude: parseFloat(lat),
            longitude: parseFloat(lon),
        };
    } catch (error) {
        console.error("Error fetching coordinates:", error);
        return null;
    }
}


// Event creation handler with multiple image uploads
exports.createEvent = async (req, res) => {
    try {
        const {
            title,
            description,
            category,
            eventDate,
            eventTime,
            location,
            tickets // Expecting an array of { name, price, limit }
        } = req.body;        // Get latitude & longitude using Nominatim
        console.log("location name of event",location)
        const coordinates = await getCoordinates(location);
        console.log("Coordinate for location",coordinates)
        if (!coordinates) return res.status(400).json({ message: "Invalid location" });


        // Ensure tickets are provided
        if (!tickets || tickets.length === 0) {
            return res.status(400).json({ message: 'At least one ticket type is required' });
        }

        // Ensure at least one image is uploaded
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: 'At least one event image is required' });
        }

        // Ensure no more than 5 images are uploaded
        if (req.files.length > 5) {
            return res.status(400).json({ message: 'You can upload up to 5 images only' });
        }

        // // Save images (Cloudinary or local storage)
        // const images = req.files.map(file => `/uploads/events/${file.filename}`);
        
        
        // Get Cloudinary URLs from uploaded files
        // Process images from Cloudinary
        const images = req.files.map(file => file.path); // file.path gives the Cloudinary URL

        // Ensure tickets are parsed correctly (handle both JSON and array cases)
        const parsedTickets = typeof tickets === "string" ? JSON.parse(tickets) : tickets;

        // Validate ticket details and ensure name exists
        const formattedTickets = parsedTickets.map(ticket => ({
            name: ticket.name?.trim(), // Ensure name is not empty
            price: Number(ticket.price),
            limit: Number(ticket.limit),
        }));

        // Check for missing ticket names before proceeding
        if (formattedTickets.some(ticket => !ticket.name)) {
            return res.status(400).json({ message: "Each ticket type must have a name." });
        }


        // Create new event
        const newEvent = new Event({
            title,
            description,
            category,
            eventDate,
            eventTime,
            location: { name: location, ...coordinates },
            organizer: req.user._id, // Use the logged-in user ID
            ticketTypes: formattedTickets, // Store ticket details
            images, // Save array of image paths
        });

        // Save to DB
        const savedEvent = await newEvent.save();
        const io = getIO();
        const message = `🔔 New event "${newEvent.title}" created by ${req.user.name}, awaiting approval.`;

        // Fetch all admins
        const admins = await User.find({ role: "admin" });

        for (const admin of admins) {
            const newNotification = new Notification({
                userId: admin._id,
                eventId: newEvent._id,
                message,
            });
            await newNotification.save();

            console.log(`📩 Sending notification to admin ${admin._id}`);
            // Emit real-time notification if admin is online
            if (io.sockets.adapter.rooms.get(admin._id.toString())) {
                io.to(admin._id.toString()).emit("event-approval-request", {
                    _id: newNotification._id,
                    message: newNotification.message,
                    eventId: newNotification.eventId,
                    isRead: newNotification.isRead,
                });
            }
        

            // sendEmail(admin.email, "🔔 Event Approval Needed", "eventApproval", {
            //     eventTitle: newEvent.title,
            //     organizerName: req.user.name,
            // });
        }
        res.status(201).json(savedEvent);
    } catch (error) {
        console.error('Error creating event:', error);
        res.status(500).json({ message: 'Error creating event', error: error.message });
    }
};

exports.getMostNearUpcomingEvent = async (req, res) => {
    try {
        const now = new Date();
        const limit = parseInt(req.query.limit) || 5; // Default limit to 15 if not provided

        const upcomingEvents = await Event.find({ eventDate: { $gte: now } })
            .sort({ eventDate: 1 }) // Sort by nearest date
            .limit(limit); // Use the dynamic limit

        res.json(upcomingEvents);
    } catch (error) {
        console.error('Error fetching upcoming events:', error);
        res.status(500).json({ error: 'Failed to fetch upcoming events' });
    }
};

exports.getEvents = async (req, res) => {
    try {
        const events = await Event.find({status:"approved"}).populate('organizer', 'avatar name email');
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching events', error });
    }
};




exports.eventDetails = async (req, res) => {
    const { id } = req.params;
    try {
        if (!mongoose.isValidObjectId(id)) {
            return res.status(400).json({ error: "Invalid event ID format" });
        }

        const event = await Event.findById(id).populate("organizer", "name email avatar about organizationName");
        if (!event) {
            return res.status(404).json({ error: "Event not found" });
        }

        let isBookmarked = false;
        // If the user is logged in, check if they have bookmarked the event
        if (req.user) {
            const existingBookmark = await Bookmark.findOne({
                userId: req.user._id,
                eventId: id,
            });
            isBookmarked = !existingBookmark; // true if bookmark exists, false otherwise
        }

        res.status(200).json({ ...event.toObject(), isBookmarked });
    } catch (error) {
        console.error("🚨 Error:", error);
        res.status(500).json({ error: "Failed to fetch event" });
    }
};

exports.getMyEvent = async (req, res) => {
    try {
        const events = await Event.find({ organizer: req.user._id });
        if (events.length === 0) {
            return res.status(200).json({ message: "You have not created any events yet." });
        }

        res.status(200).json(events);
    } catch (error) {
        console.error("Error fetching user's events:", error);
        res.status(500).json({ error: "Failed to fetch Organizer's events" });
    }
};

// exports.UpdateEvent = async (req, res) => {
//     const { id } = req.params;
//     try {
//         const event = await Event.findOne({ _id: id, organizer: req.user._id });
//         if (!event) {
//             return res.status(404).json({ error: "Event not found" });
//         }

//         // Update fields
//         Object.assign(event, req.body);
//         await event.save();

//         res.status(200).json(event);
//     } catch (error) {
//         console.error("Error updating event:", error);
//         res.status(500).json({ error: "Failed to update event" });
//     }
// }



exports.UpdateEvent = async (req, res) => {
    const { id } = req.params;
    try {
        const event = await Event.findOne({ _id: id, organizer: req.user._id });
        if (!event) {
            return res.status(404).json({ error: "Event not found" });
        }

        // Fetch attendees who booked the event
        const attendees = await Booking.find({ event: id, status: "booked" })
            .populate("user", "email name"); // Get user email & name

        // Update event details
        Object.assign(event, req.body);
        await event.save();

        // Send real-time notifications to attendees
        const io = getIO();
        const message = `📢 The event "${event.title}" has been updated!`;

        for (const attendee of attendees) {
            const newNotification = new Notification({
                userId: attendee.user._id,
                message,
                eventId: id,
            });
            await newNotification.save();

            console.log(`📩 Sending notification to user ${attendee.user._id}`);

            // Emit real-time notification
            io.to(attendee.user._id.toString()).emit("event-update", {
                _id: newNotification._id,
                message: newNotification.message,
                eventId: newNotification.eventId,
                isRead: newNotification.isRead,
            });

            // Send Email Notification 📧
            const emailSubject = `🔔 Update: Event "${event.title}" has been modified!`;
            const emailTemplate = "eventUpdate"; // Template name for event update emails
            const emailReplacements = {
                userName: attendee.user.name,
                eventTitle: event.title,
                eventDate: event.eventDate,
                eventLocation: event.location,
                eventDescription: event.description,
            };

            sendEmail(attendee.user.email, emailSubject, emailTemplate, emailReplacements);
        }

        res.status(200).json({ message: "Event updated successfully!" });
    } catch (error) {
        console.error("Error updating event:", error);
        res.status(500).json({ error: "Failed to update event" });
    }
};

exports.approveOrRejectEvent = async (req, res) => {
    try {
        const { status } = req.body; // "approved" or "rejected"
        const event = await Event.findById(req.params.eventId).populate("organizer");

        if (!event) return res.status(404).json({ message: "Event not found" });

        event.status = status;
        await event.save();

        const io = getIO();
        const message = `🔔 Your event "${event.title}" has been ${status}.`;

        const newNotification = new Notification({
            userId: event.organizer._id,
            eventId: event._id,
            message,
        });
        await newNotification.save();

        console.log(`📩 Sending notification to organizer ${event.organizer._id}`);
        io.to(event.organizer._id.toString()).emit("event-update", {
            _id: newNotification._id,
            message: newNotification.message,
            eventId: newNotification.eventId,
            isRead: newNotification.isRead,
        });

        // sendEmail(event.organizer.email, `🔔 Event "${event.title}" ${status}`, "eventStatus", {
        //     eventTitle: event.title,
        //     status: status,
        // });

        res.json({ message: `Event ${status} successfully!`, event });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


exports.deleteEvent = async (req, res) => {
    try {
        const event = await Event.findById(req.params.id);

        if (!event) {
            return res.status(404).json({ message: "Event not found" });
        }

       
        // Allow admin to delete any event or the organizer to delete their own event
        if (req.user.role !== 'admin' && event.organizer.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: "You are not authorized to delete this event" });
        }

        // Use deleteOne to remove the event
        await Event.deleteOne({ _id: event._id });

        res.status(200).json({ message: "Event deleted successfully" });
    } catch (error) {
        console.error("Error deleting event:", error);
        res.status(500).json({ message: "Error deleting event", error: error.message });
    }
};
 

exports.userLike = async function (req, res) {
    try {
        const eventId = req.params.eventId;
        const userId = req.body.userId;

        console.log("User ID:", userId);
        console.log("Event ID:", eventId);

        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }

        const event = await Event.findById(eventId);

        if (!event) {
            return res.status(404).json({ message: "Event not found" });
        }

        // Ensure usersLiked is an array and filter out null/undefined values
        event.usersLiked = (event.usersLiked || []).filter((id) => id != null);

        // Check if user has already liked
        const userHasLiked = event.usersLiked.some((id) => id.toString() === userId.toString());

        if (userHasLiked) {
            // Unlike event
            event.likes = Math.max(0, event.likes - 1);
            event.usersLiked = event.usersLiked.filter((id) => id.toString() !== userId.toString());
        } else {
            // Like event
            event.likes += 1;
            event.usersLiked.push(userId);
        }

        const updatedEvent = await event.save();

        res.json({
            likes: updatedEvent.likes,
            usersLiked: updatedEvent.usersLiked,
        });

    } catch (error) {
        console.error("Error liking/unliking the event:", error);
        res.status(500).json({ message: "Server error" });
    }
};


exports. getEventAttendeeCount = async (req, res) => {
    try {
        const { eventId } = req.params;

        // Count the number of bookings where status is 'booked' for the specific event
        const attendeeCount = await Booking.countDocuments({ event: eventId, status: 'booked' });

        res.status(200).json({ attendeeCount });
    } catch (error) {
        console.error('Error fetching attendee count:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

