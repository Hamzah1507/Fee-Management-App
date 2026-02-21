# 💰 Fee Management App

A professional Flutter-based mobile application for managing student fee records at the college level.  
Built with **Firebase** for authentication and real-time data storage.

---

## 📱 Features

- 🔐 **User Authentication** — Login & Register via Firebase Auth
- 🏠 **Home Dashboard** — Live overview of all students with search
- ➕ **Add Students** — Add students with course, fees and due date
- 📋 **Fee Collection** — Collect fees with semester selector and payment method
- 🧾 **PDF Receipts** — Generate semester-wise fee receipts with university branding
- 📊 **Analytics Screen** — Collection rate, monthly bar chart, course-wise breakdown
- ⚠️ **Overdue Alerts** — Red badges for students past their due date
- 📤 **Excel Export** — Export full fee report with 3 sheets (Summary, Students, Payments)
- 👤 **Profile Screen** — View account info, quick stats and sign out
- 🎨 **Professional UI** — Navy + blue design system with GLS University branding
- 💦 **Splash Screen** — Custom splash with app icon
- 🗂️ **Payment History** — Full timeline of all payments per student

---

## 🛠️ Tech Stack

| Technology | Details |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Backend / Auth | Firebase Authentication + Firestore |
| PDF Generation | pdf + printing packages |
| Excel Export | syncfusion_flutter_xlsio |
| Charts | fl_chart |
| File Sharing | share_plus |
| State Management | Built-in Flutter State (setState + StreamBuilder) |

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
│   ├── student.dart
│   └── payment.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── add_student_screen.dart
│   ├── student_details_screen.dart
│   ├── collect_fee_screen.dart
│   ├── payment_history_screen.dart
│   ├── analytics_screen.dart
│   └── profile_screen.dart
└── services/
    ├── auth_service.dart
    ├── receipt_service.dart
    └── excel_service.dart
```

---

## 🔧 Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the Firebase project
3. Download and replace `google-services.json` in `android/app/`
4. Enable **Email/Password** Authentication in Firebase Console
5. Create a **Firestore Database** with the following collections:
   - `users` — stores user profile data
   - `students` — stores student fee records
   - `payments` — stores individual payment transactions

---

## 🗃️ Firestore Data Structure

```
students/
  └── {studentId}
        ├── name
        ├── course
        ├── totalFees
        ├── paidFees
        ├── currentSemester
        ├── dueDate
        └── createdAt

payments/
  └── {paymentId}
        ├── studentId
        ├── amount
        ├── method (cash / upi / bank)
        ├── semester
        └── createdAt
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ using Flutter & Firebase</p>
