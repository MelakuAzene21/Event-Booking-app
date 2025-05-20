const express = require('express');
const axios = require('axios');
const verifyToken = require('../middlewares/verifyToken');
const dotenv = require('dotenv');
const booking = require('../models/Booking');
const { InializePayment,  verifyTransaction } = require('../controllers/paymentController');
dotenv.config();
// Determine the base URL based on the environment
const baseUrl = process.env.NODE_ENV === 'production'
    ? 'https://e-market-hbf7.onrender.com'
    : 'http://localhost:3000';
const router = express.Router();
 
// router.post('/initialize', async (req, res) => {
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
// });









// Verify transaction and update booking status


router.post('/initialize', verifyToken,InializePayment)
router.post('/verify-transaction/:tx_ref',verifyToken, verifyTransaction) 
// router.get('/verify-transaction/:tx_ref', async (req, res) => {
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
//             const { tx_ref, status } = response.data.data;  // Extracting transaction details from Chapa response

//             // Check if the payment status is "success"
//             if (status === 'success' && tx_ref) {
//                 // Find  the order in the database using the tx_ref
//                 const book = await booking.findOne({ tx_ref: tx_ref });
//                 console.log('Booking data by tx refs from verifying', book)
//                 // Check if the order exists and its payment status is "pending"
//                 if (book && book.status && book.status === 'pending') {
//                     // Update the status status to "booked"
//                     book.status = 'booked';

//                     await book.save();  // Save the updated book status
//                     console.log("booking ID want for QR code", book._id)

//                     // Send a response indicating the book was successfully updated
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Transaction verified and book payment status updated successfully.',
//                         bookingId: book._id, //  Send bookingId in the response

//                         book
//                     });
//                 } else if (!book) {
//                     console.error('booking', book)
//                     // If book doesn't exist, return an error response
//                     return res.status(404).json({
//                         success: false,
//                         message: 'book not found'
//                     });
//                 } else if (book.status !== 'pending') {
//                     // If the book payment status is already updated, return an acknowledgment
//                     return res.status(200).json({
//                         success: true,
//                         message: 'Payment already processed for this Booking.',
//                         bookingId: book._id, // ✅ Send bookingId in the response
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
// });







//handle Payment callback from chapa

// router.post('/callback', async (req, res) => {
//     try {
//         const chapaData = req.body;
//         console.log('Received Chapa callback:', chapaData);

//         // You can check the transaction status here (e.g., 'success', 'failed')
//         if (chapaData.status === 'success') {
//             // Find the order in the database using chapaData.orderId (assuming chapaData contains this)
//             const order = await Order.findById(chapaData.orderId);

//             if (order) {
//                 // Update payment details
//                 order.isPaid = true; // Mark the order as paid
//                 order.paidAt = Date.now(); // Set the paid time
//                 order.status = {
//                     id: chapaData.paymentId,  // Assuming chapaData has the paymentId
//                     status: chapaData.status,
//                     update_time: chapaData.updateTime, // Assuming chapaData has the updateTime
//                     email_address: chapaData.email,  // Assuming chapaData has the payer's email
//                 };

//                 // Save the updated order
//                 const updatedOrder = await order.save();

//                 // Respond back to the frontend with success
//                 return res.status(200).json({ message: 'Transaction processed successfully', order: updatedOrder });
//             } else {
//                 return res.status(404).json({ message: 'Order not found' });
//             }
//         } else {
//             // Handle failed transaction case
//             console.log('Transaction failed:', chapaData);
//             return res.status(400).json({ message: 'Transaction failed' });
//         }
//     } catch (error) {
//         console.error('Error in payment callback:', error);
//         return res.status(500).json({ message: 'Error processing callback', error });
//     }
// });


module.exports = router;