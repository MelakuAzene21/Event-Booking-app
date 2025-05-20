// const multer = require('multer');
// const path = require('path');

// // Multer configuration for multiple image uploads
// const storage = multer.diskStorage({
//     destination: function (req, file, cb) {
//         cb(null, 'uploads/events/'); // Folder where images will be stored
//     },
//     filename: function (req, file, cb) {
//         const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1E9)}`;
//         cb(null, `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`);
//     }
// });

// const fileFilter = (req, file, cb) => {
//     const allowedTypes = /jpeg|jpg|png/;
//     const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
//     const mimetype = allowedTypes.test(file.mimetype);

//     if (extname && mimetype) {
//         cb(null, true);
//     } else {
//         cb('Images only!'); // Reject non-image files
//     }
// };

// const upload = multer({
//     storage,
//     limits: { fileSize: 2000000 }, // 2MB file size limit per file
//     fileFilter
// });

// module.exports = upload;

// const multer = require('multer');
// const { storage } = require('./cloudinaryConfig');

// const upload = multer({
//     storage,
//     limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
// });

// module.exports = upload;


const multer = require('multer');
const storage = require('./cloudinaryConfig').storage; // Assuming you have cloudinaryConfig.js set up
const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/avif'];
        if (!allowedTypes.includes(file.mimetype)) {
            return cb(new Error('Only JPEG, JPG, and PNG images are allowed'), false);
        }
        cb(null, true);
    }
}).array('images', 5);

//Wrap the multer middleware to handle errors
const uploadMiddleware = (req, res, next) => {
    upload(req, res, (err) => {
        if (err) {
            console.error("Multer error:", err);
            return res.status(400).json({ message: "Error uploading images", error: err.message });
        }
        next();
    });
};

module.exports = uploadMiddleware;