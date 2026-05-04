# 🎓 Student Management System

A full-stack **Flutter + Node.js** application for managing students and academic marks. Features role-based access — admins manage students and assign marks, while students view their own results with live grade previews.

---

## ✨ Features

### 👨‍💼 Admin Role
- View all registered students
- Tap any student to add marks
- Assign marks by type: **Quiz**, **Assignment**, or **Lab**
- Live grade preview with auto-calculated percentage and grade (A+, A, B, C, D, F)

### 👨‍🎓 Student Role
- View personal academic results dashboard
- Results grouped by assessment type
- Circular progress indicators with animated arc per assessment
- Average percentage and grade per category

### 🔐 Auth
- Register & Login with JWT token
- Role-based routing (admin → Students screen, student → Dashboard)
- Token stored securely via `SharedPreferences`

---

## 📁 Project Structure

```
StudentManagementFlutter_App/
├── frontened/               # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   └── secreens/
│   │       ├── login.dart          # Login screen
│   │       ├── register.dart       # Registration screen
│   │       ├── addMarks.dart       # Students list + Add marks (Admin)
│   │       ├── dashboard.dart      # Results dashboard (Student)
│   │       ├── appbar.dart         # Shared AppBar widget
│   │       └── router.dart         # App navigation/routing
│   ├── .env                        # API base URL config
│   └── pubspec.yaml
│
└── Backened/                # Node.js + Express API
    ├── index.js
    ├── db.js
    ├── authentication/
    ├── models/
    └── node_code/
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Node.js (18+)
- MongoDB (local or Atlas)

---

### Backend Setup

```bash
cd Backened
npm install
```

Create a `.env` file in `Backened/`:
```env
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
PORT=3000
```

Start the server:
```bash
node index.js
```

---

### Frontend Setup

```bash
cd frontened
flutter pub get
```

Create a `.env` file in `frontened/`:
```env
BACKEND_API=192.168.x.x   # Your local IP (not localhost)
```

> ⚠️ Use your machine's **local IP address** (e.g. `192.168.1.5`), not `localhost`, so the Flutter app can reach the backend on a real device.

Run the app:
```bash
flutter run
```

---

## 🔗 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/register` | Register new user |
| POST | `/users/login` | Login, returns JWT + role |
| GET | `/users/all` | Get all students (Admin only) |
| POST | `/marks/student` | Add marks for a student (Admin) |
| GET | `/marks/student` | Get own marks (Student) |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| State | `setState` + `AnimationController` |
| HTTP | `http` package |
| Storage | `shared_preferences` |
| Config | `flutter_dotenv` |
| Backend | Node.js + Express |
| Database | MongoDB |
| Auth | JWT |

---

## 📱 Screens

| Screen | File | Description |
|--------|------|-------------|
| Login | `login.dart` | Glassmorphism login with gradient background |
| Register | `register.dart` | New account creation |
| Students | `addMarks.dart` | Admin: list of all students with animated cards |
| Add Marks | `addMarks.dart` | Admin: assign quiz/assignment/lab marks |
| Dashboard | `dashboard.dart` | Student: results with circular arc progress |

---

## 👥 Team

| Name | Role |
|------|------|
| Ali Hamza | Full Stack Developer |

---

## 📄 License

This project is for educational purposes.
