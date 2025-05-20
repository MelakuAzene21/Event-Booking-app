# 🎟️ Event Booking App

An end-to-end **Event Booking Application** built using **Flutter** for the frontend and **Node.js (Express)** with **MongoDB** for the backend.

This project allows users to browse events, book tickets, manage their bookings, and more. It includes user authentication

---

## 🗂️ Project Structure
    back/ # Backend - Node.js + Express + MongoDB
    event_front/ # Frontend - Flutter App

    

---

## 🚀 Features

### ✅ Flutter Frontend (`event_front`)
- Cross-platform mobile UI (Android/iOS)
- User authentication (Login/Register)
- Event listing and detailed pages
- Ticket booking and QR code generation
- Favorite/bookmarked events
### ✅ Node.js Backend (`back`)
- REST API built with Express.js
- MongoDB database (Mongoose ODM)
- Authentication using JWT
- Event creation with admin approval
- Booking system with QR code tickets
- Secure file uploads using UploadThing (or similar)

---

## 🛠️ Tech Stack

| Category     | Technology                     |
|--------------|-------------------------------|
| Frontend     | Flutter, Dart, Riverpod       |
| Backend      | Node.js, Express.js, MongoDB  |
| Auth         | JWT                           |
| File Uploads | Cloudinary                   |
| Others       | Mongoose, Bcrypt, Nodemailer  |

---

## 🧑‍💻 Getting Started

### 1️⃣ Clone the repository


git clone https://github.com/MelakuAzene21/event-booking-app.git
cd event-booking-app

cd back
npm install
node server.js

PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
CLIENT_URL=http://localhost:3000  # or your frontend URL



cd ../event_front
flutter pub get

flutter run


