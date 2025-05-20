const { Server } = require("socket.io");

let io;
const initializeSocket = (server) => {
    io = new Server(server, {
        cors: {
            origin: ["http://localhost:3000", "http://localhost:5173"],  // Allow frontend
            methods: ["GET", "POST"],
            credentials: true,
        },
        transports: ["websocket", "polling"], // Ensure fallback for WebSockets
    });

    io.on("connection", (socket) => {
        console.log("User connected:", socket.id);

        socket.on("join", (userId) => {
            socket.join(userId);
            console.log(`User ${userId} joined notification channel`);
        });

        socket.on("disconnect", () => {
            console.log("User disconnected:", socket.id);
        });
    });

    return io;
};

module.exports = { initializeSocket, getIO: () => io };
