🍽️ FoodFlowSL – Food Donation & Distribution App

FoodFlowSL is a role-based food donation platform built using Flutter (frontend) and Flask with MongoDB (backend). It connects Donors, Receivers, and Volunteers to efficiently manage and deliver surplus food across communities.

📱 App Features

    Role-Based Dashboards

        Donor: Create and track donations

        Receiver: View nearby donations and claim them

        Volunteer: Accept delivery tasks and view delivery routes on a map

    Secure JWT Authentication

        Login, register, update profile, and logout securely

    Donation Management

        Upload food details, images, and expiry time

        Real-time claiming and status updates

        Built-in rating system for donations

    Google Maps Integration

        Device-based location tagging

        Map display for delivery coordination

    Cloud Image Uploads

        Food images stored using Firebase Storage

        Cloud-based notifications to users

🛠️ Tech Stack

    Frontend: Flutter, Dart

    Backend: Python, Flask, JWT, APScheduler

    Database: MongoDB (via Atlas)

    Cloud Storage: Firebase Storage

    Maps & Location: Google Maps Flutter, Geolocator

    Deployment: Google Cloud Run

🚀 Local Setup Instructions

Backend Setup:

    Clone the backend repo
    git clone https://github.com/AdithyaJA/foodflowsl-backend.git
    cd foodflowsl-backend

    Install dependencies
    pip install -r requirements.txt

    (Optional) Set JWT secret key
    export JWT_SECRET_KEY="your_secret_key"

    Run the Flask server
    python run.py

Frontend Setup:

    Clone the frontend repo
    git clone https://github.com/your-username/foodflowsl-frontend.git
    cd foodflowsl-frontend

    Install Flutter dependencies
    flutter pub get

    Run the app
    flutter run

📸 Visual Overview

    Login Screen

    Donor Dashboard

    Claim Donation

    Delivery Map with Markers


🧠 System Architecture Summary

    Donors, Receivers, and Volunteers interact via JSON over HTTP

    Client application handles UI and connects to backend

    JWT is used to authenticate users

    MongoDB stores users, donations, and orders

    Firebase is used for storing uploaded images

    Async background jobs clean expired donations and send reminders
