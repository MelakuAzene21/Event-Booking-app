const express = require('express');
const http = require("http");
const dotenv = require('dotenv');
const path=require('path')
const passport = require("passport");
const session = require('express-session');
require("./config/passport");
const { initializeSocket } = require('./config/socket')
const cookieParser = require('cookie-parser');
const connectDB = require('./config/db'); // Import the database connection
const authRoutes = require('./routes/authRoutes');
const eventRoutes = require('./routes/eventRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const paymentRoute = require('./routes/payment');
const reviewRoutes = require('./routes/reviewRoutes');
const reportRoutes = require('./routes/reportRoutes');
const ticketRoutes = require('./routes/ticketRoutes');
const bookmarkRoutes = require('./routes/bookmarkRoutes');
const notificationRoutes=require('./routes/notificationRoutes')
// Load environment variables
dotenv.config();

// Initialize the application
const app = express();
const server = http.createServer(app);

const io = initializeSocket(server); // Initialize WebSocket

const cors = require('cors');
// Configure CORS to allow requests from your frontend
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:5173' ,'http://10.161.166.119'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization'],
}));
 

// Parse URL-encoded data (optional, after multer)
app.use(express.urlencoded({ extended: true }));
// Middleware
app.use(cookieParser()); 

app.use(express.json());

// Session middleware (for Passport)
app.use(
    session({
        secret: process.env.JWT_SECRET,
        resave: false,
        saveUninitialized: false,
    })
);
app.use(passport.initialize());
app.use(passport.session());

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/payment', paymentRoute); 
app.use("/api/reviews", reviewRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/bookmarks', bookmarkRoutes);
app.use("/api/notifications", notificationRoutes);


app.use(express.json());

// Start the server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
 