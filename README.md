# 💰 Fees Manager
A professional cross-platform mobile application for managing student fee records at the college level.  
Built with **Flutter + Firebase** for authentication, real-time data storage, and a complete fee management workflow.

---

## 📱 Features

- 🔐 **User Authentication** — Login & Register via Firebase Auth with validation
- 🏠 **Home Dashboard** — Live overview of all students with search by name or course
- ➕ **Add Students** — Add students with course, semester, fees and due date
- 📋 **Fee Collection** — Collect fees with semester selector and payment method (Cash/UPI/Bank)
- 🧾 **PDF Receipts** — Auto-generate semester-wise fee receipts with GLS University branding
- 📊 **Analytics Screen** — Collection rate, monthly bar chart, course-wise breakdown
- ⚠️ **Overdue Alerts** — Red badges for students past their due date
- 📤 **Excel Export** — Export full fee report with 3 sheets (Summary, All Students, Payment History)
- 👤 **Profile Screen** — View account info, quick stats and sign out
- ⚙️ **Settings Screen** — Dark mode toggle, notification preferences, currency selector, date format
- 🛡️ **Admin Panel** — System overview, financial summary, student status breakdown, recent transactions
- 💱 **Live Currency Rates** — Real-time INR exchange rates via REST API (frankfurter.app)
- 🔔 **Local Notifications** — Push notifications on fee collection and student addition
- 🗂️ **Payment History** — Full timeline of all payments per student
- 🎨 **Professional UI** — Navy + blue gradient design system with GLS University branding
- 💦 **Splash Screen** — Custom splash screen with app icon
- 🔀 **Named Routes** — Smooth fade+slide transitions between all screens

---

## 🛠️ Tech Stack

| Technology | Details |
|---|---|
| Framework | Flutter (Cross Platform) |
| Language | Dart |
| Backend / Auth | Firebase Authentication + Cloud Firestore |
| PDF Generation | pdf + printing packages |
| Excel Export | syncfusion_flutter_xlsio |
| Charts | fl_chart |
| File Sharing | share_plus |
| REST API | frankfurter.app (Live Currency Rates) |
| Notifications | flutter_local_notifications |
| State Management | setState + StreamBuilder + ChangeNotifier |
| Navigation | Named Routes with Custom Transitions |

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

**3. Run the app (debug)**
```bash
flutter run
```

**4. Run the app (release — recommended for demo)**
```bash
flutter run --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, routes, theme
├── models/
│   ├── student.dart                   # Student data model
│   └── payment.dart                   # Payment data model
├── screens/
│   ├── welcome_screen.dart            # Welcome/landing screen
│   ├── login_screen.dart              # Firebase login
│   ├── register_screen.dart           # Firebase register
│   ├── home_screen.dart               # Dashboard with student list
│   ├── add_student_screen.dart        # Add new student form
│   ├── student_details_screen.dart    # Student profile + fee summary
│   ├── collect_fee_screen.dart        # Fee collection with payment method
│   ├── payment_history_screen.dart    # Full payment timeline
│   ├── analytics_screen.dart          # Charts + Excel export
│   ├── profile_screen.dart            # User profile + quick stats
│   ├── settings_screen.dart           # App settings + preferences
│   ├── admin_panel_screen.dart        # Admin dashboard + system overview
│   └── currency_screen.dart           # Live INR exchange rates (REST API)
└── services/
    ├── auth_service.dart              # Firebase Auth logic
    ├── receipt_service.dart           # PDF receipt generation
    ├── excel_service.dart             # Excel export (3 sheets)
    └── notification_service.dart      # Local push notifications
```

---

## 🔧 Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android app to the Firebase project
3. Download and replace `google-services.json` in `android/app/`
4. Enable **Email/Password** Authentication in Firebase Console
5. Create a **Firestore Database** in production mode
6. Add the following collections:
   - `users` — stores user profile data
   - `students` — stores student fee records
   - `payments` — stores individual payment transactions

---

## 🗃️ Firestore Data Structure

```
users/
  └── {userId}
        ├── name
        ├── email
        ├── role (admin)
        └── createdAt

students/
  └── {studentId}
        ├── name
        ├── course
        ├── currentSemester
        ├── totalFees
        ├── paidFees
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

## 🔀 App Navigation Flow

```
Welcome Screen
    ├── Sign In → Login Screen → Home Dashboard
    └── Create Account → Register Screen → Login Screen

Home Dashboard
    ├── Student Card → Student Details → Collect Fee / Payment History
    ├── 🟠 Admin Panel → System Overview + Financial Summary
    ├── 📊 Analytics → Charts + Excel Export
    └── 👤 Profile → Settings → Live Currency Rates
```

---

## 📋 College Requirements Fulfilled

| Requirement | Implementation |
|---|---|
| ✅ Customized UI Screens | Welcome, Login, Home, Profile, Settings |
| ✅ Named Routes | All navigation via named routes in main.dart |
| ✅ Admin Panel | Dedicated admin screen with stats and transactions |
| ✅ Database Integration | Firebase Firestore with full CRUD |
| ✅ REST API Integration | Live currency rates from frankfurter.app |
| ✅ Authentication | Firebase Auth with email/password |
| ✅ Device Features | Local notifications for fee collection & student addition |

---

## 🎓 Academic Details

| Detail | Info |
|---|---|
| Programme | Integrated Master of Computer Applications (iMSc.IT) |
| Semester | VIII |
| Subject | 221601801 — Cross Platform Mobile App Development |



---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ using Flutter & Firebase</p>
<p align="center">Fee Management System v1.0.0</p>
