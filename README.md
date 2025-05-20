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




📸 Screenshots


![image](https://github.com/user-attachments/assets/5b2f58a6-5de8-4b41-9acd-3fd38d07cbc9)
![image](https://github.com/user-attachments/assets/984ec523-80b5-4454-bccb-9f5e7a8a01fa)
![image](https://github.com/user-attachments/assets/21c2b20d-7394-4af9-839d-5dc5cd67447b)
![image](https://github.com/user-attachments/assets/d6e3d841-7879-4709-91d3-9bcb7a74db84)


