const cloudinary = require('cloudinary').v2;

// Delete old avatar from Cloudinary
exports.deleteOldAvatar = async (avatarUrl) => {
    try {
        if (avatarUrl) {
            // Extract public_id from the URL
            const publicId = avatarUrl.split('/').pop().split('.')[0];
            await cloudinary.uploader.destroy(`user_avatars/${publicId}`);
        }
    } catch (error) {
        console.error('Error deleting old avatar:', error);
        throw new Error('Failed to delete old avatar');
    }
};