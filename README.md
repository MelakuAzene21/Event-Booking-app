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


![87pbfZTPOsJFsbxvMkArFuVVKba](https://github.com/user-attachments/assets/f20b83b6-7df3-40ee-b13f-5289c4cdaa6f)
![86PiApiGJdNxdBUhrbvwWcBMydh](https://github.com/user-attachments/assets/2e9b7db5-a4b7-49ce-a802-9d1094213f83)
![84BDmgojVMBVoUYKLxcyoTmeNZt](https://github.com/user-attachments/assets/4dc9979f-4e3b-47c1-8eeb-8318aabbb9e4)
![8NwnJdMjiwKPyuyAAfDPYBlgKby](https://github.com/user-attachments/assets/4d2bafba-0a80-4da9-aa40-b51a3ef4887a)
![8J2AtrdTYHIFipeEHRplDEzcKEv](https://github.com/user-attachments/assets/b4bb2963-9742-4a7d-8fae-f48b57aeb217)
![8IxqmtQWczwpzUJzStdHMODxMyn](https://github.com/user-attachments/assets/6d866238-75bf-4573-9ac0-558c7017674f)
![8GiBHpmnbjDDUflByjwdoBxKLCw](https://github.com/user-attachments/assets/24b81a83-bbc4-4c61-af14-868b7761b1dd)
