// const axios = require('axios');
// const dotenv = require('dotenv');
// const booking = require('../models/Booking');
// dotenv.config();
// // Determine the base URL based on the environment
// const baseUrl = process.env.NODE_ENV === 'production'
//     ? 'https://e-market-hbf7.onrender.com'
//     : 'http://localhost:3000';

// exports.InializePayment = async (req, res) => {
//     try {
//         const { amount, currency, email, firstName, lastName, tx_ref } = req.body;

//         if (!email || !email.includes('@')) {
//             return res.status(400).json({ message: 'Invalid email format' });
//         }

//         const paymentData = {
//             amount,
//             currency,
//             email,
//             first_name: firstName,
//             last_name: lastName,
//             tx_ref,
//             // callback_url: 'http://localhost:5000/payment/callback',
//             callback_url: `https://3508-213-55-102-49.ngrok-free.app/payment/callback?tx_ref=${tx_ref}`,
//             return_url: `${baseUrl}/success?tx_ref=${tx_ref}`, // Dynamically set return_url
//             customization: {
//                 "title": "Ticket Booking"

//             }
//         };

//         const chapaResponse = await axios({
//             method: 'post',
//             url: 'https://api.chapa.co/v1/transaction/initialize',
//             headers: {
//                 Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`,
//                 'Content-Type': 'application/json'
//             },
//             data: paymentData
//         });
//         // res.json(chapaResponse.data)
//         return res.status(200).json({ payment_url: chapaResponse.data.data.checkout_url });
//     } catch (error) {
//         console.error('Error initializing payment:', error.response ? error.response.data : error.message);
//         res.status(500).json({
//             message: 'Error initializing payment',
//             error: error.response ? error.response.data : error.message
//         });
//     }
// }

// exports.verifyTransaction = async (req, res) => {
//     try {
//         const txRef = req.params.tx_ref; // Get tx_ref from the route parameter
//         const url = `https://api.chapa.co/v1/transaction/verify/${txRef}`;

//         // Make a request to verify the transaction with Chapa API
//         const response = await axios.get(url, {
//             headers: {
//                 Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`
//             }
//         });

//         if (response.status === 200 && response.data.status === 'success') {
//             const { tx_ref, status } = response.data.data;

//             // Check if the payment status is "success"
//             if (status === 'success' && tx_ref) {
//                 // Find the order in the database using the tx_ref
//                 const book = await booking.findOne({ tx_ref: tx_ref });
//                 console.log('Booking data by tx refs from verifying', book);

//                 // Check if the order exists and its payment status is "pending"
//                 if (book && book.status && book.status === 'pending') {
//                     // Update the status status to "booked"
//                     book.status = 'booked';

//                     await book.save();
//                     console.log("booking ID want for QR code", book._id);

//                     // Send a response indicating the book was successfully updated
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Transaction verified and book payment status updated successfully.',
//                         bookingId: book._id,
//                         book
//                     });
//                 } else if (!book) {
//                     console.error('booking', book);
//                     return res.status(404).json({
//                         success: false,
//                         message: 'book not found'
//                     });
//                 } else if (book.status !== 'pending') {
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Payment already processed for this Booking.',
//                         bookingId: book._id,
//                         book
//                     });
//                 }
//             }
//         }

//         // If the transaction verification failed, return an error
//         res.status(400).json({
//             success: false,
//             message: 'Transaction verification failed or invalid transaction reference.'
//         });
//     } catch (error) {
//         console.error('Error verifying transaction:', error);
//         res.status(500).json({
//             success: false,
//             message: 'Error verifying transaction',
//             error: error.response ? error.response.data : error.message
//         });
//     }
// };



// const axios = require('axios');
// const dotenv = require('dotenv');
// const nanoid = async () => (await import('nanoid')).nanoid;
// const Booking = require('../models/Booking');
// dotenv.config();

// exports.InializePayment = async (req, res) => {
//     try {
//         console.log('Received payment initialization request:', req.body);
//         const { amount, currency } = req.body;

//         if (!amount || !currency) {
//             return res.status(400).json({ message: 'Missing required fields: amount and currency' });
//         }

//         // Generate unique transaction reference
//         const generateTxRef = await nanoid();
// const tx_ref = generateTxRef();


//         // Prepare Chapa payment data
//         const paymentData = {
//             amount,
//             tx_ref,
//             currency
//         };

//         // Make request to Chapa's initialize endpoint
//         const chapaResponse = await axios.post(
//             'https://api.chapa.co/v1/transaction/initialize', // Updated endpoint
//             paymentData,
//             {
//                 headers: {
//                     Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`,
//                     'Content-Type': 'application/json'
//                 }
//             }
//         );

//         console.log('Chapa API response:', chapaResponse.data);

//         if (chapaResponse.data.status === 'success') {
//             return res.status(200).json({
//                 message: 'Payment initialized successfully',
//                 paymentUrl: chapaResponse.data.data.checkout_url,
//                 tx_ref
//             });
//         } else {
//             return res.status(500).json({
//                 message: 'Failed to initialize payment',
//                 error: chapaResponse.data
//             });
//         }
//     } catch (error) {
//         console.error('Error initializing payment:', error.response ? error.response.data : error.message);
//         res.status(500).json({
//             message: 'Error initializing payment',
//             error: error.response ? error.response.data : error.message
//         });
//     }
// };

// exports.verifyTransaction = async (req, res) => {
//     try {
//         console.log('Received transaction verification request:', req.params, req.body);
//         const txRef = req.params.tx_ref;
//         const { eventId, ticketType, ticketCount, userId } = req.body;

//         // Validate required fields for booking creation
//         if (!eventId || !ticketType || !ticketCount || !userId) {
//             return res.status(400).json({ message: 'Missing required fields for booking creation' });
//         }

//         const url = `https://api.chapa.co/v1/transaction/verify/${txRef}`;

//         // Verify transaction with Chapa API
//         const response = await axios.get(url, {
//             headers: {
//                 Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`
//             }
//         });

//         console.log('Chapa verification response:', response.data);

//         if (response.status === 200 && response.data.status === 'success') {
//             const { tx_ref, status, amount } = response.data.data;

//             if (status === 'success' && tx_ref) {
//                 // Check if booking already exists
//                 let book = await Booking.findOne({ tx_ref });

//                 if (book) {
//                     if (book.status === 'booked') {
//                         return res.status(200).json({
//                             success: true,
//                             message: 'Payment already processed for this booking',
//                             bookingId: book._id,
//                             book
//                         });
//                     } else if (book.status === 'pending') {
//                         // Update existing pending booking to booked
//                         book.status = 'booked';
//                         await book.save();
//                         return res.status(200).json({
//                             success: true,
//                             message: 'Transaction verified and booking updated successfully',
//                             bookingId: book._id,
//                             book
//                         });
//                     }
//                 } else {
//                     // Create new booking
//                     book = await Booking.create({
//                         event: eventId,
//                         user: userId,
//                         ticketType,
//                         ticketCount,
//                         totalAmount: amount,
//                         tx_ref,
//                         status: 'booked'
//                     });
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Transaction verified and booking created successfully',
//                         bookingId: book._id,
//                         book
//                     });
//                 }
//             }
//         }

//         // Transaction verification failed
//         res.status(400).json({
//             success: false,
//             message: 'Transaction verification failed or invalid transaction reference'
//         });
//     } catch (error) {
//         console.error('Error verifying transaction:', error.response ? error.response.data : error.message);
//         res.status(500).json({
//             success: false,
//             message: 'Error verifying transaction',
//             error: error.response ? error.response.data : error.message
//         });
//     }
// };



const axios = require('axios');
const dotenv = require('dotenv');
const nanoid = async () => (await import('nanoid')).nanoid;
const Booking = require('../models/Booking');
dotenv.config();
const Event = require('../models/Event');
const Ticket = require('../models/Ticket');
const User = require('../models/User');
const QRCode = require('qrcode');
const sendEmail = require('../helpers/Send-Email');
exports.InializePayment = async (req, res) => {
    try {
        console.log('Received payment initialization request:', req.body);
        const { amount, currency } = req.body;

        if (!amount || !currency) {
            return res.status(400).json({ message: 'Missing required fields: amount and currency' });
        }

        // Generate unique transaction reference
        const generateTxRef = await nanoid();
const tx_ref = generateTxRef();

        // Prepare Chapa payment data
        const paymentData = {
            amount,
            tx_ref,
            currency
        };

        // Make request to Chapa's initialize endpoint
        const chapaResponse = await axios.post(
            'https://api.chapa.co/v1/transaction/initialize',
            paymentData,
            {
                headers: {
                    Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`,
                    'Content-Type': 'application/json'
                }
            }
        );

        console.log('Chapa API response:', chapaResponse.data);

        if (chapaResponse.data.status === 'success') {
            return res.status(200).json({
                message: 'Payment initialized successfully',
                paymentUrl: chapaResponse.data.data.checkout_url,
                tx_ref
            });
        } else {
            return res.status(500).json({
                message: 'Failed to initialize payment',
                error: chapaResponse.data
            });
        }
    } catch (error) {
        console.error('Error initializing payment:', error.response ? error.response.data : error.message);
        res.status(500).json({
            message: 'Error initializing payment',
            error: error.response ? error.response.data : error.message
        });
    }
};

// exports.verifyTransaction = async (req, res) => {

//     try {
//         console.log('Received transaction verification request:', req.params, req.body);
//         const { tx_ref } = req.params; // Consistent with route parameter
//         const { eventId, ticketType, ticketCount, userId } = req.body;

//         // Validate required fields
//         if (!tx_ref) {
//             return res.status(400).json({ message: 'Missing transaction reference' });
//         }
//         if (!eventId || !ticketType || !ticketCount || !userId) {
//             return res.status(400).json({ message: 'Missing required fields: eventId, ticketType, ticketCount, userId' });
//         }

//         const url = `https://api.chapa.co/v1/transaction/verify/${tx_ref}`;

//         // Verify transaction with Chapa API
//         const response = await axios.get(url, {
//             headers: {
//                 Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`
//             }
//         });

//         console.log('Chapa verification response:', response.data);

//         if (response.status === 200 && response.data.status === 'success') {
//             const { tx_ref: verifiedTxRef, status, amount } = response.data.data;

//             if (status === 'success' && verifiedTxRef === tx_ref) {
//                 // Check if booking already exists
//                 let book = await Booking.findOne({ tx_ref });

//                 if (book) {
//                     if (book.status === 'booked') {
//                         return res.status(200).json({
//                             success: true,
//                             message: 'Payment already processed for this booking',
//                             bookingId: book._id,
//                             book
//                         });
//                     } else if (book.status === 'pending') {
//                         book.status = 'booked';
//                         await book.save();
//                         return res.status(200).json({
//                             success: true,
//                             message: 'Transaction verified and booking updated successfully',
//                             bookingId: book._id,
//                             book
//                         });
//                     }
//                 } else {
//                     // Create new booking
//                     book = await Booking.create({
//                         event: eventId,
//                         user: userId,
//                         ticketType,
//                         ticketCount,
//                         totalAmount: amount,
//                         tx_ref,
//                         status: 'booked'
//                     });
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Transaction verified and booking created successfully',
//                         bookingId: book._id,
//                         book
//                     });
//                 }
//             }
//         }

//         // Transaction verification failed
//         res.status(400).json({
//             success: false,
//             message: 'Transaction verification failed or invalid transaction reference'
//         });
//     } catch (error) {
//         console.error('Error verifying transaction:', error.response ? error.response.data : error.message);
//         res.status(500).json({
//             success: false,
//             message: 'Error verifying transaction',
//             error: error.response ? error.response.data : error.message
//         });
//     }
// };




exports.verifyTransaction = async (req, res) => {
    try {
        console.log('Received transaction verification request:', req.params, req.body);
        const { tx_ref } = req.params;
        const { eventId, ticketType, ticketCount, userId } = req.body;

        // Validate required fields
        if (!tx_ref) {
            return res.status(400).json({ message: 'Missing transaction reference' });
        }
        if (!eventId || !ticketType || !ticketCount || !userId) {
            return res.status(400).json({ message: 'Missing required fields: eventId, ticketType, ticketCount, userId' });
        }

        const url = `https://api.chapa.co/v1/transaction/verify/${tx_ref}`;

        // Verify transaction with Chapa API
        const response = await axios.get(url, {
            headers: {
                Authorization: `Bearer ${process.env.CHAPA_SECRET_KEY}`
            }
        });

        console.log('Chapa verification response:', response.data);

        if (response.status === 200 && response.data.status === 'success') {
            const { tx_ref: verifiedTxRef, status, amount, id } = response.data.data;

            if (status === 'success' && verifiedTxRef === tx_ref) {
                // Check if booking already exists
                let book = await Booking.findOne({ tx_ref });

                if (book) {
                    if (book.status === 'booked') {
                        return res.status(200).json({
                            success: true,
                            message: 'Payment already processed for this booking',
                            bookingId: book._id,
                            book
                        });
                    } else if (book.status === 'pending') {
                        book.status = 'booked';
                        await book.save();
                        return res.status(200).json({
                            success: true,
                            message: 'Transaction verified and booking updated successfully',
                            bookingId: book._id,
                            book
                        });
                    }
                } else {
                    // Create new booking
                    book = await Booking.create({
                        event: eventId,
                        user: userId,
                        ticketType,
                        ticketCount,
                        totalAmount: amount,
                        tx_ref,
                        paymentId: tx_ref, // Assuming 'id' is the transaction ID from Chapa
                        status: 'booked'
                    });

                    // Find the event
                    const event = await Event.findById(eventId);
                    if (!event) {
                        // Optionally rollback booking if event not found
                        await Booking.deleteOne({ _id: book._id });
                        return res.status(404).json({ message: 'Event not found' });
                    }

                    // Update ticket availability
                    let updatedTicketTypes = event.ticketTypes.map(ticket => {
                        if (ticket.name === ticketType) {
                            ticket.booked = (ticket.booked ?? 0) + Number(ticketCount);
                            ticket.available = (ticket.available ?? ticket.limit) - Number(ticketCount);
                        }
                        return ticket;
                    });

                    event.ticketTypes = updatedTicketTypes;
                    await event.save();

                    // Generate tickets and QR codes
                    const tickets = [];
                    const qrCodeAttachments = [];

                    for (let i = 0; i < ticketCount; i++) {
                        // Generate a unique ticket number
                        const ticketNumber = `TCK-${Date.now()}-${i}`;

                        // Generate QR code data
                        const qrData = `${ticketNumber}-${userId}-${eventId}`;

                        // Generate QR code as Data URL
                        const qrCodeImage = await QRCode.toDataURL(qrData);

                        // Save ticket in the database
                        const ticket = await Ticket.create({
                            booking: book._id,
                            event: eventId,
                            user: userId,
                            ticketNumber,
                            qrCode: qrData,
                            isUsed: false
                        });

                        tickets.push(ticket);

                        // Push QR code as an attachment
                        qrCodeAttachments.push({
                            filename: `Ticket-${i + 1}.png`,
                            content: qrCodeImage.split("base64,")[1],
                            encoding: "base64"
                        });
                    }

                    // Fetch user for email
                    const attendee = await User.findById(userId);
                    if (!attendee) {
                        console.warn('User not found for email notification:', userId);
                    } else {
                        // Create ticket details for email
                        const ticketDetails = tickets.map((ticket, index) => `
                            <p><strong>Ticket ${index + 1}:</strong> ${ticket.ticketNumber}</p>
                        `).join('');

                        // Send booking confirmation email
                        await sendEmail(attendee.email, "Your Ticket Booking Confirmation", "ticketConfirmation", {
                            name: attendee.name,
                            eventTitle: event.title,
                            eventDate: event.eventDate.toDateString(),
                            eventTime: event.eventTime,
                            eventLocation: event.location,
                            ticketCount,
                            ticketDetails
                        }, qrCodeAttachments);
                    }

                    return res.status(200).json({
                        success: true,
                        message: 'Transaction verified, booking created, tickets generated, and event updated successfully',
                        bookingId: book._id,
                        book,
                        tickets
                    });
                }
            }
        }

        // Transaction verification failed
        res.status(400).json({
            success: false,
            message: 'Transaction verification failed or invalid transaction reference'
        });
    } catch (error) {
        console.error('Error verifying transaction:', error.response ? error.response.data : error.message);
        res.status(500).json({
            success: false,
            message: 'Error verifying transaction',
            error: error.response ? error.response.data : error.message
        });
    }
};