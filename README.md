# 💰 Fee Management App

A Flutter-based mobile application for managing student fee records efficiently.  
Built with **Firebase** for authentication and real-time data storage.

---

## 📱 Features

- 🔐 User Authentication (Login & Register) via Firebase
- 🏠 Home dashboard to view all students
- ➕ Add new student records
- 📋 Manage and track fee payments
- 🌐 Cross-platform support (Android, iOS, Web, Windows, Linux, macOS)

---

## 🛠️ Tech Stack

| Technology | Details |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Backend / Auth | Firebase Authentication + Firestore |
| State Management | Built-in Flutter State |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK → [Install Flutter](https://docs.flutter.dev/get-started/install)
- Firebase project → [Firebase Console](https://console.firebase.google.com/)
- Android Studio or VS Code

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/Hamzah1507/Fee-Management-App.git
cd Fee-Management-App
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Run the app**

```bash
flutter run
```

---

## 📁 Project Structure

```
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
```

---

## 🔧 Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the Firebase project
3. Download and replace `google-services.json` in `android/app/`
4. Enable **Email/Password** Authentication in Firebase Console

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ using Flutter</p>
