// const multer = require('multer');
// const { CloudinaryStorage } = require('multer-storage-cloudinary');
// const cloudinary = require('cloudinary').v2;
// const dotenv = require('dotenv');
// const path = require('path');
// const pdf = require('pdf-parse');

// dotenv.config();

// cloudinary.config({
//     cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
//     api_key: process.env.CLOUDINARY_API_KEY,
//     api_secret: process.env.CLOUDINARY_API_SECRET,
// });

// cloudinary.api.ping((error, result) => {
//     if (error) {
//         console.error('Cloudinary connection failed:', error);
//     } else {
//         console.log('Cloudinary connection successful:', result);
//     }
// });

// const validatePdf = async (buffer) => {
//     try {
//         if (!buffer || !(buffer instanceof Buffer)) {
//             console.error('Invalid buffer: Buffer is undefined or not a Buffer');
//             return false;
//         }
//         await pdf(buffer);
//         console.log('PDF validated successfully');
//         return true;
//     } catch (error) {
//         console.error('Invalid PDF:', error.message);
//         return false;
//     }
// };

// const upload = multer({
//     storage: multer.memoryStorage(), // Use memory storage to access buffer
//     limits: {
//         fileSize: 5 * 1024 * 1024, // 5MB limit
//         files: 6, // Max 1 avatar + 5 docs
//     },
//     fileFilter: (req, file, cb) => {
//         console.log('File filter:', file.fieldname, file.mimetype);
//         const allowedTypes = {
//             avatar: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/avif'],
//             docs: ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'],
//         };
//         if (!allowedTypes[file.fieldname]?.includes(file.mimetype)) {
//             return cb(new Error(`Invalid file type for ${file.fieldname}. Allowed types: ${allowedTypes[file.fieldname].join(', ')}`), false);
//         }
//         cb(null, true);
//     },
// }).fields([
//     { name: 'avatar', maxCount: 1 },
//     { name: 'docs', maxCount: 5 },
// ]);

// const uploadMiddleware = async (req, res, next) => {
//     console.log('Incoming FormData fields:', Object.keys(req.body || {}));
//     upload(req, res, async (err) => {
//         if (err instanceof multer.MulterError) {
//             console.error('Multer error:', err);
//             return res.status(400).json({ message: 'File upload error', error: err.message });
//         } else if (err) {
//             console.error('Upload error:', err);
//             return res.status(400).json({ message: 'Error uploading files', error: err.message });
//         }

//         // Validate PDFs and upload to Cloudinary
//         try {
//             if (req.files) {
//                 const uploadedFiles = { avatar: [], docs: [] };

//                 // Process avatar
//                 if (req.files.avatar) {
//                     for (const file of req.files.avatar) {
//                         const extension = path.extname(file.originalname).toLowerCase().replace('.', '');
//                         const baseName = path.basename(file.originalname, `.${extension}`);

//                         const uploadResult = await new Promise((resolve, reject) => {
//                             const stream = cloudinary.uploader.upload_stream(
//                                 {
//                                     folder: 'user_avatars',
//                                     allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'avif'],
//                                     format: extension,
//                                     transformation: [
//                                         { width: 200, height: 200, crop: 'fill' },
//                                         { quality: 'auto' },
//                                         { fetch_format: 'auto' },
//                                     ],
//                                     resource_type: 'image',
//                                     public_id: `avatar_${Date.now()}_${baseName}`,
//                                 },
//                                 (error, result) => {
//                                     if (error) {
//                                         reject(error);
//                                     } else {
//                                         resolve(result);
//                                     }
//                                 }
//                             );
//                             stream.end(file.buffer);
//                         });

//                         uploadedFiles.avatar.push({
//                             path: uploadResult.secure_url,
//                             mimetype: file.mimetype,
//                             public_id: uploadResult.public_id,
//                             format: uploadResult.format,
//                         });
//                     }
//                 }
//                 // Process docs
//                 if (req.files.docs) {
//                     for (const file of req.files.docs) {
//                         const isImage = ['image/jpeg', 'image/jpg', 'image/png'].includes(file.mimetype);
//                         const extension = path.extname(file.originalname).toLowerCase().replace('.', '');
//                         const baseName = path.basename(file.originalname, `.${extension}`);

//                         // Validate PDF
//                         if (file.mimetype === 'application/pdf') {
//                             const isValidPdf = await validatePdf(file.buffer);
//                             if (!isValidPdf) {
//                                 return res.status(400).json({ message: `Invalid PDF file: ${file.originalname}` });
//                             }
//                         }

//                         const uploadResult = await new Promise((resolve, reject) => {
//                             const stream = cloudinary.uploader.upload_stream(
//                                 {
//                                     folder: 'vendor_docs',
//                                     allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
//                                     format: isImage ? extension : 'pdf',
//                                     resource_type: 'image', // Use 'image' for PDFs
//                                     transformation: isImage
//                                         ? [{ quality: 'auto' }, { fetch_format: 'auto' }]
//                                         : undefined,
//                                     public_id: `doc_${Date.now()}_${baseName}`,
//                                 },
//                                 (error, result) => {
//                                     if (error) {
//                                         reject(error);
//                                     } else {
//                                         resolve(result);
//                                     }
//                                 }
//                             );
//                             stream.end(file.buffer);
//                         });

//                         uploadedFiles.docs.push({
//                             path: uploadResult.secure_url,
//                             mimetype: file.mimetype,
//                             public_id: uploadResult.public_id,
//                             format: uploadResult.format,
//                         });
//                     }
//                 }

//                 req.files = uploadedFiles; // Update req.files with Cloudinary results
//                 console.log('Uploaded files:', req.files);
//             }
//             next();
//         } catch (error) {
//             console.error('Cloudinary upload error:', error);
//             return res.status(400).json({ message: 'Error uploading to Cloudinary', error: error.message });
//         }
//     });
// };

// module.exports = uploadMiddleware;





const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('cloudinary').v2;
const dotenv = require('dotenv');
const path = require('path');
const pdf = require('pdf-parse');

dotenv.config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

cloudinary.api.ping((error, result) => {
    if (error) {
        console.error('Cloudinary connection failed:', error);
    } else {
        console.log('Cloudinary connection successful:', result);
    }
});

const validatePdf = async (buffer) => {
    try {
        if (!buffer || !(buffer instanceof Buffer)) {
            console.error('Invalid buffer: Buffer is undefined or not a Buffer');
            return false;
        }
        await pdf(buffer);
        console.log('PDF validated successfully');
        return true;
    } catch (error) {
        console.error('Invalid PDF:', error.message);
        return false;
    }
};

const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
        files: 6, // Max 1 avatar + 5 docs
    },
    fileFilter: (req, file, cb) => {
        console.log('File filter:', file.fieldname, file.mimetype);
        if (file.fieldname === 'avatar') {
            // Allow any image MIME type for avatar
            if (file.mimetype.startsWith('image/')) {
                cb(null, true);
            } else {
                cb(new Error('Invalid file type for avatar. Must be an image.'), false);
            }
        } else if (file.fieldname === 'docs') {
            // Keep existing restrictions for docs
            const allowedDocTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
            if (allowedDocTypes.includes(file.mimetype)) {
                cb(null, true);
            } else {
                cb(new Error(`Invalid file type for docs. Allowed types: ${allowedDocTypes.join(', ')}`), false);
            }
        } else {
            cb(new Error('Unknown field name'), false);
        }
    },
}).fields([
    { name: 'avatar', maxCount: 1 },
    { name: 'docs', maxCount: 5 },
]);

const uploadMiddleware = async (req, res, next) => {
    console.log('Incoming FormData fields:', Object.keys(req.body || {}));
    upload(req, res, async (err) => {
        if (err instanceof multer.MulterError) {
            console.error('Multer error:', err);
            return res.status(400).json({ message: 'File upload error', error: err.message });
        } else if (err) {
            console.error('Upload error:', err);
            return res.status(400).json({ message: 'Error uploading files', error: err.message });
        }

        try {
            if (req.files) {
                const uploadedFiles = { avatar: [], docs: [] };

                // Process avatar
                if (req.files.avatar) {
                    for (const file of req.files.avatar) {
                        const extension = path.extname(file.originalname).toLowerCase().replace('.', '');
                        const baseName = path.basename(file.originalname, `.${extension}`);

                        const uploadResult = await new Promise((resolve, reject) => {
                            const stream = cloudinary.uploader.upload_stream(
                                {
                                    folder: 'user_avatars',
                                    // Remove allowed_formats to accept all image formats supported by Cloudinary
                                    transformation: [
                                        { width: 200, height: 200, crop: 'fill' },
                                        { quality: 'auto' },
                                        { fetch_format: 'auto' },
                                    ],
                                    resource_type: 'image',
                                    public_id: `avatar_${Date.now()}_${baseName}`,
                                },
                                (error, result) => {
                                    if (error) {
                                        reject(error);
                                    } else {
                                        resolve(result);
                                    }
                                }
                            );
                            stream.end(file.buffer);
                        });

                        uploadedFiles.avatar.push({
                            path: uploadResult.secure_url,
                            mimetype: file.mimetype,
                            public_id: uploadResult.public_id,
                            format: uploadResult.format,
                        });
                    }
                }

                // Process docs
                if (req.files.docs) {
                    for (const file of req.files.docs) {
                        const isImage = ['image/jpeg', 'image/jpg', 'image/png'].includes(file.mimetype);
                        const extension = path.extname(file.originalname).toLowerCase().replace('.', '');
                        const baseName = path.basename(file.originalname, `.${extension}`);

                        // Validate PDF
                        if (file.mimetype === 'application/pdf') {
                            const isValidPdf = await validatePdf(file.buffer);
                            if (!isValidPdf) {
                                return res.status(400).json({ message: `Invalid PDF file: ${file.originalname}` });
                            }
                        }

                        const uploadResult = await new Promise((resolve, reject) => {
                            const stream = cloudinary.uploader.upload_stream(
                                {
                                    folder: 'vendor_docs',
                                    allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
                                    format: isImage ? extension : 'pdf',
                                    resource_type: 'image',
                                    transformation: isImage
                                        ? [{ quality: 'auto' }, { fetch_format: 'auto' }]
                                        : undefined,
                                    public_id: `doc_${Date.now()}_${baseName}`,
                                },
                                (error, result) => {
                                    if (error) {
                                        reject(error);
                                    } else {
                                        resolve(result);
                                    }
                                }
                            );
                            stream.end(file.buffer);
                        });

                        uploadedFiles.docs.push({
                            path: uploadResult.secure_url,
                            mimetype: file.mimetype,
                            public_id: uploadResult.public_id,
                            format: uploadResult.format,
                        });
                    }
                }

                req.files = uploadedFiles;
                console.log('Uploaded files:', req.files);
            }
            next();
        } catch (error) {
            console.error('Cloudinary upload error:', error);
            return res.status(400).json({ message: 'Error uploading to Cloudinary', error: error.message });
        }
    });
};

module.exports = uploadMiddleware;