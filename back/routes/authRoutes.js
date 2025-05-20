const express = require('express');
const { register, login, logout, getProfile, updateProfile,
    getAllUsers, googleCallback, logoutGoogle, deleteUser,
    forgotPassword, resetPassword, updateUser, followedOrganizers,
    totalFollowerOfOrganizer, uploadAvatar, getAllVendors, getVendorById, 
    getOrganizerDEtails} = require('../controllers/authController');
const verifyToken = require('../middlewares/verifyToken');
const checkRole = require('../middlewares/checkRole');
const router = express.Router();
const upload=require('../utils/uploadAavatar');
const passport = require("passport");
const uploadMiddleware = require('../utils/uploadAavatar');
// const { CloudinaryStorage } = require('multer-storage-cloudinary');
// const cloudinary = require('cloudinary').v2;
require("../config/passport");
router.post('/register',uploadMiddleware, register);
router.post('/login', login);
router.post('/logout',verifyToken, logout);
router.get('/profile',verifyToken, getProfile);
router.post('/forgot-password', forgotPassword);
router.put('/reset-password/:token', resetPassword);
router.get('/vendors', getAllVendors)
router.get('/vendor/:id', getVendorById);

// // Google OAuth Login
// router.get("/google", passport.authenticate("google",

//     { scope: ["profile", "email"] ,
//     prompt: 'select_account consent' , // Forces Google to show account selection and persmission dialog
//     accessType: 'offline' ,// Enables refresh token
//     authtype:'reauthenticate'  }));

// // Google OAuth Callback
// router.get(
//     "/google/callback",
//     passport.authenticate("google", { failureRedirect: "http://localhost:3000/login" }),
//     (req, res) => {

//         console.log("Google response",req.query);
// const{code}=req.query;
// console.log("Authorization code",code);
//         const token = req.user.token;
//         console.log("Token from google authenticated",token);
//         // Store token in a cookie
//         res.cookie("token", req.user.token, {
//             httpOnly: true,
//             secure: false, // Change to true in production (for HTTPS)
//             sameSite: "strict",
//         });
//         res.redirect("http://localhost:3000");
//     }
// );

// // Logout Route
// router.get("/logout", (req, res) => {
//     req.logout((err) => {
//         if (err) return res.status(500).send("Error logging out.");
//         res.clearCookie("token");
//         res.redirect("http://localhost:3000");
//     });
// });


// Google OAuth Login
router.get(
    '/google',
    passport.authenticate('google', {
        scope: ['profile', 'email'],
        prompt: 'select_account consent', // Forces Google to show account selection and permission dialog
        accessType: 'offline', // Enables refresh token
        authType: 'reauthenticate',
    })
);

// Google OAuth Callback
router.get(
    '/google/callback',
    passport.authenticate('google', { failureRedirect: 'http://localhost:3000/login' }),
    googleCallback
);

// Logout Route
router.get('/logout', logoutGoogle);


router.delete("/users/:id", verifyToken, checkRole('admin'), deleteUser);
router.put("/users/:id", verifyToken, checkRole('admin'), updateUser);


router.put('/updateProfile/:id',verifyToken, updateProfile);
router.get('/getAllUser',verifyToken,checkRole('admin'), getAllUsers);
// router.get('/getAllUser',  getAllUsers);
router.post('/organizers/follow',verifyToken, followedOrganizers);
router.get('/organizers/:organizerId/followers',  totalFollowerOfOrganizer)
router.get('/organizer/:id',getOrganizerDEtails)
router.post('/upload-avatar', verifyToken, uploadMiddleware, uploadAvatar);

// const multer = require('multer');
// const User = require('../models/User'); // Adjust the path to your user model
// // Configure Cloudinary Storage for avatars
// const storage = new CloudinaryStorage({
//     cloudinary: cloudinary,
//     params: {
//         folder: 'user_avatars', // Specific folder for avatars
//         allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'avif'],
//         transformation: [
//             { width: 200, height: 200, crop: 'fill' }, // Optional: resize avatar
//             { quality: 'auto' },
//             { fetch_format: 'auto' }
//         ]
//     }
// });

// // Configure multer
// const upload = multer({
//     storage,
//     limits: { fileSize: 2 * 1024 * 1024 }, // 2MB limit for avatars
//     fileFilter: (req, file, cb) => {
//         const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/avif'];
//         if (!allowedTypes.includes(file.mimetype)) {
//             return cb(new Error('Only JPEG, JPG, PNG, WEBP, and AVIF images are allowed'), false);
//         }
//         cb(null, true);
//     }
// });

// // Upload avatar route
// router.post('/upload-avatar', verifyToken, upload.single('avatar'), async (req, res) => {
//     try {
//         const userId = req.user.id;

//         // The file is now uploaded to Cloudinary, and req.file contains the Cloudinary response
//         if (!req.file) {
//             return res.status(400).json({ message: 'No file uploaded' });
//         }

//         // Get the secure URL from Cloudinary
//         const avatarUrl = req.file.path; // Cloudinary returns the URL in path property

//         // Update the user's avatar in the database
//         const updatedUser = await User.findByIdAndUpdate(
//             userId,
//             { avatar: avatarUrl },
//             { new: true }
//         );

//         if (!updatedUser) {
//             return res.status(404).json({ message: 'User not found' });
//         }

//         res.status(200).json({
//             message: 'Avatar uploaded successfully',
//             avatar: avatarUrl
//         });
//     } catch (error) {
//         console.error('Error uploading avatar:', error);
//         res.status(500).json({
//             message: 'Error uploading avatar',
//             error: error.message
//         });
//     }
// });

// // Optional: Delete old avatar from Cloudinary when updating
// const deleteOldAvatar = async (avatarUrl) => {
//     try {
//         if (avatarUrl) {
//             // Extract public_id from the URL
//             const publicId = avatarUrl.split('/').pop().split('.')[0];
//             await cloudinary.uploader.destroy(`user_avatars/${publicId}`);
//         }
//     } catch (error) {
//         console.error('Error deleting old avatar:', error);
//     }
// };




module.exports = router;
