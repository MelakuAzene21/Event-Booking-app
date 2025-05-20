const passport = require("passport");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
const User = require("../models/User");
const jwt = require("jsonwebtoken");
const dotenv = require('dotenv');

dotenv.config();

passport.use(
    new GoogleStrategy(
        {
            clientID: process.env.GOOGLE_CLIENT_ID,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET,
            callbackURL: "/api/auth/google/callback",
            passReqToCallback: true,  // Enables passing req as first parameter
            prompt: "select_account"  // Forces Google to show account selection
        },
        async (req, accessToken, refreshToken, profile, done) => {  // Add `req` as first parameter
            try {
                let user = await User.findOne({ email: profile.emails[0].value });
                console.log("Access token",accessToken);
                console.log("Refresh token", refreshToken);
                if (!user) {
                    // Create a new user if they don't exist
                    user = new User({
                        name: profile.displayName,
                        email: profile.emails[0].value,
                        password: "", // No password required for OAuth
                        avatar: profile.photos[0].value,
                    });
                    await user.save();
                }

                // Generate a JWT token
                const token = jwt.sign(
                    { id: user._id, role: user.role },
                    process.env.JWT_SECRET,
                    { expiresIn: "1d" }
                );

                return done(null, { user, token });  // Ensure `done` is called correctly
            } catch (error) {
                return done(error, null);  // Return `done` properly
            }
        }
    )
);

// Serialize user
passport.serializeUser((data, done) => {
    done(null, data.user._id);
});

// Retrieve user from session
passport.deserializeUser(async (id, done) => {
    try {
        const user = await User.findById(id);
        done(null, user);
    } catch (error) {
        done(error, null);
    }
});