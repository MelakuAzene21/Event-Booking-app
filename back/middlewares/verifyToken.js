// const jwt = require('jsonwebtoken');
// const User = require('../models/User'); // Adjust the path

// const verifyToken = async (req, res, next) => {
//     try {
//         const token = req.cookies.token; // Fetch token from cookies
//         console.log('Token received:', token); // Debugging
//         if (!token) {
//             return res.status(401).json({ message: 'Authentication required' });
//         }

//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const user = await User.findById(decoded.id);
//         if (!user) {
//             return res.status(401).json({ message: 'User not found' });
//         }

//         req.user = user; // Attach user to the request
//         next();
//     } catch (error) {
//         console.error('Error in verifyToken:', error.message);
//         res.status(401).json({ message: 'Invalid token' });
//     }
// };

// module.exports = verifyToken;



const jwt = require('jsonwebtoken');
const User = require('../models/User');

const verifyToken = async (req, res, next) => {
    try {
        let token;
        const authHeader = req.headers.authorization;

        // Check Authorization header first
        if (authHeader && authHeader.startsWith('Bearer ')) {
            token = authHeader.split(' ')[1];
            console.log('Token from Authorization header:', token); // Debug: Log token
        } else {
            // Fallback to cookie
            token = req.cookies.token;
            console.log('Token from cookie:', token); // Debug: Log token
        }

        if (!token) {
            console.log('No token provided');
            return res.status(401).json({ message: 'Authentication required' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log('Decoded token:', decoded); // Debug: Log decoded token

        const user = await User.findById(decoded.id);
        if (!user) {
            console.log('User not found for ID:', decoded.id);
            return res.status(401).json({ message: 'User not found' });
        }

        req.user = user; // Attach user to the request
        next();
    } catch (error) {
        console.error('Error in verifyToken:', error.message);
        res.status(401).json({ message: 'Invalid token' });
    }
};

module.exports = verifyToken;

