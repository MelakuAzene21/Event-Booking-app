// const mongoose = require('mongoose');
// const bcrypt = require('bcryptjs');
// const crypto = require('crypto');
// const userSchema = new mongoose.Schema({
//     name: { type: String, required: true },
//     email: { type: String, required: true, unique: true },
//     password: { type: String, required: false },
//     role: { type: String, enum: ['admin', 'organizer', 'user'], default: 'user' },
//     avatar: { type: String }, // Add this field to store the avatar file path or URL
//     status: { type: String, enum: ['active', 'blocked'], default: 'active' },
//     followedOrganizers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
//     resetPasswordToken: {type:String},
//     resetPasswordExpire: {type:Date},
// }, { timestamps: true });
  
// // Hash password before saving
// userSchema.pre('save', async function (next) {
//     if (!this.isModified('password')) return next();
//     this.password = await bcrypt.hash(this.password, 10);
//     next();
// });

// // Compare passwords
// userSchema.methods.comparePassword = async function (password) {
//     return bcrypt.compare(password, this.password);
// };


// // Generate password reset token
// userSchema.methods.generatePasswordResetToken = function () {
//     const resetToken = crypto.randomBytes(20).toString('hex');
//     this.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
//     this.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
//     return resetToken;
// };
// module.exports = mongoose.model('User', userSchema);



const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: false },
    role: { type: String, enum: ['admin', 'organizer', 'user', 'vendor'], default: 'user' }, // Added 'vendor'
    avatar: { type: String, default: 'default.jpg' }, // Aligned with vendorSchema default
    status: { type: String, enum: ['active', 'blocked'], default: 'active' },
    followedOrganizers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    resetPasswordToken: { type: String },
    resetPasswordExpire: { type: Date },
    // Vendor-specific fields from vendorSchema
    serviceProvided: { type: String, required: false, default: 'photographer' }, // Service offered
    docs: [
        {
            url: { type: String, required: true },
            type: { type: String, enum: ['pdf', 'image'], required: true },
            previewUrl: { type: String }
        }
    ],
    rating: { type: Number, default: 0, min: 0, max: 5 }, // Vendor rating
    price: { type: String, required: false, default: '50 birr per hour' }, // Price
    portfolio: [
        {
            title: { type: String, required: false, default: '50 birr per hour' }, // Portfolio item title
            image: { type: String, required: false }, // Portfolio item image URL
            description: { type: String, required: false, default: '50 birr per hour' }, // Portfolio item description
        },
    ], // Array of portfolio items
    description: { type: String, required: false }, // Vendor description
    availability: { type: String, default: 'As needed' }, // Availability status
    location: { type: String, required: false }, // Vendor location

    // Organizer-specific fields
    phoneNumber: { type: String },
    organizationName: { type: String },
    address: { type: String },
    website: { type: String },
    socialLinks: [{ type: String }],
    about: { type: String },
    experience: { type: String },
    eventCategories: [{ type: String }],
    logo: { type: String, default: 'default.jpg' },

}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    if (this.password) {
        this.password = await bcrypt.hash(this.password, 10);
    }
    next();
});

// Compare passwords
userSchema.methods.comparePassword = async function (password) {
    if (!this.password) return false;
    return bcrypt.compare(password, this.password);
};

// Generate password reset token
userSchema.methods.generatePasswordResetToken = function () {
    const resetToken = crypto.randomBytes(20).toString('hex');
    this.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    this.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
    return resetToken;
};

module.exports = mongoose.model('User', userSchema); 