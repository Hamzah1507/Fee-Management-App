Fee Management App
A Flutter-based mobile application for managing student fee records efficiently. Built with Firebase for authentication and real-time data storage.
📱 Features

🔐 User Authentication (Login & Register) via Firebase
🏠 Home dashboard to view all students
➕ Add new student records
📋 Manage and track fee payments
🌐 Cross-platform support (Android, iOS, Web, Windows, Linux, macOS)

🛠️ Tech Stack

Framework: Flutter
Language: Dart
Backend/Auth: Firebase (Authentication + Firestore)
State Management: Built-in Flutter state

🚀 Getting Started
Prerequisites

Flutter SDK installed → Install Flutter
Firebase project set up → Firebase Console
Android Studio or VS Code

Installation

Clone the repository

bash   git clone https://github.com/Hamzah1507/Fee-Management-App.git
   cd Fee-Management-App

Install dependencies

bash   flutter pub get

Run the app

bash   flutter run
📁 Project Structure
lib/
├── main.dart
├── models/
│   └── student.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   └── add_student_screen.dart
└── services/
    └── auth_service.dart
🔧 Firebase Setup

Create a Firebase project at Firebase Console
Add your Android/iOS app to the Firebase project
Download and replace google-services.json in android/app/
Enable Email/Password Authentication in Firebase Console


🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.
📄 License
This project is licensed under the MIT License.

Made with ❤️ using Flutter
