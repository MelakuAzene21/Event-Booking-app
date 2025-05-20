const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const dotenv = require('dotenv');

dotenv.config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Test Cloudinary configuration
console.log("Cloudinary Config:", {
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET ? "****" : undefined
});

// Verify Cloudinary connection
cloudinary.api.ping((error, result) => {
    if (error) {
        console.error("Cloudinary connection failed:", error);
    } else {
        console.log("Cloudinary connection successful:", result);
    }
});

const storage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'EMS_Events',
        allowed_formats: ['jpg', 'jpeg', 'png','avif','webp'], // Add 'avif' and 'webp' formats
        transformation: [{ width: 800, height: 600, crop: 'limit' }] // Optional: resize images
    },
});

module.exports = { cloudinary, storage };