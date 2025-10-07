# 📚 StudyHub - Your All-in-One Student Companion

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**A comprehensive student productivity app built with Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Setup](#-setup-instructions) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

StudyHub is a feature-rich student utility app that combines four essential modules to help students manage their academic life effectively. Built with Flutter for cross-platform compatibility, offline-first architecture, and beautiful Material 3 design.

## ✨ Features

### 🏠 **Home Dashboard**
- Visual radar chart displaying upcoming deadlines
- Quick stats for active and overdue assignments
- Quick access cards to all modules
- Real-time deadline tracking

### 📝 **Peer Notes**
- Create, edit, and delete notes with rich formatting
- Organize notes by subject and tags
- **Share notes via:**
  - Plain text
  - JSON export/import
  - QR code generation (scan to import)
- Import notes from files
- Offline-first storage

### 📅 **Deadline Radar**
- Add assignments with title, subject, due date, and priority
- Visual radar chart showing deadline proximity
- Three priority levels (High, Medium, Low)
- Mark deadlines as completed
- Color-coded urgency indicators
- Local notifications (24h and 1h before due)
- Filter overdue and completed tasks

### 💬 **Class Whisper**
- Anonymous feedback posting system
- Real-time Firebase integration
- Mark feedback as resolved (for class representatives)
- Community-driven class improvement
- No login required (anonymous authentication)

### 💸 **ClassSplit**
- Create expense groups for projects or trips
- Add multiple members
- Log shared expenses with payer tracking
- **Smart settlement calculation:**
  - Automatic balance computation
  - Simplified settlement suggestions
  - Fair expense distribution
- Export summaries as CSV
- Share settlement reports

### ⚙️ **Settings**
- Dark/Light theme toggle
- Data management (backup/restore)
- Notification preferences
- About app information

---

## 🎨 UI/UX Highlights

- **Material 3 Design** with modern, clean aesthetics
- **Teal & Indigo** color scheme for a calming study environment
- **Smooth animations** and transitions
- **Responsive layouts** for different screen sizes
- **Intuitive navigation** with bottom navigation bar
- **Visual feedback** with snackbars and dialogs
- **Card-based layouts** for better content organization

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Provider |
| **Local Database** | SQLite (sqflite) |
| **Cloud Backend** | Firebase (Firestore, Auth) |
| **Notifications** | flutter_local_notifications |
| **Sharing** | share_plus, qr_flutter |
| **File Operations** | file_picker, path_provider |
| **Export** | CSV generation |

---

## 📱 Setup Instructions

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**
- **Firebase account** (only needed for Class Whisper feature)

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/studyhub.git
cd studyhub
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup (Required for Class Whisper)

> **Note:** If you don't need the Class Whisper feature, you can skip Firebase setup. The app will work fine without it!

#### For Android:

1. **Create a Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project" and follow the wizard
   - Enable Google Analytics (optional)

2. **Register Android App:**
   - Click the Android icon in Firebase Console
   - Enter package name: `com.example.study_hub` (or your custom package name)
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`

3. **Enable Firestore Database:**
   - In Firebase Console, go to "Firestore Database"
   - Click "Create database"
   - Start in **test mode** (for development)
   - Choose your region

4. **Enable Anonymous Authentication:**
   - Go to "Authentication" → "Sign-in method"
   - Enable "Anonymous" authentication

5. **Update Firestore Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /whispers/{document=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

6. **Update Android build.gradle:**
   
   `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
   
   `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### For iOS (Optional):

1. Register iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place in: `ios/Runner/GoogleService-Info.plist`
4. Update `ios/Runner/Info.plist` with Firebase configuration

### Step 4: Configure Android Permissions

The app already includes necessary permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### Step 5: Update Minimum SDK Version

Ensure `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for Firebase and modern features
        targetSdkVersion 34
    }
}
```

### Step 6: Run the App

```bash
# Connect your device or start an emulator
flutter run

# For release build:
flutter build apk --release
```

---

## 📦 Project Structure

```
lib/
├── main.dart                      # App entry point
├── app_hub_screen.dart            # Main navigation
├── core/
│   ├── database/
│   │   └── database_helper.dart   # SQLite database manager
│   ├── providers/
│   │   └── theme_provider.dart    # Theme state management
│   └── services/
│       └── notification_service.dart # Local notifications
├── features/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       └── deadline_radar_widget.dart
│   ├── notes/
│   │   ├── models/
│   │   │   └── note_model.dart
│   │   ├── screens/
│   │   │   ├── notes_list_screen.dart
│   │   │   └── note_edit_screen.dart
│   │   └── widgets/
│   │       └── note_card.dart
│   ├── deadlines/
│   │   ├── models/
│   │   │   └── deadline_model.dart
│   │   ├── screens/
│   │   │   ├── deadlines_list_screen.dart
│   │   │   └── deadline_edit_screen.dart
│   │   └── widgets/
│   │       └── deadline_card.dart
│   ├── whisper/
│   │   ├── models/
│   │   │   └── whisper_model.dart
│   │   ├── services/
│   │   │   └── whisper_service.dart
│   │   ├── screens/
│   │   │   └── whisper_screen.dart
│   │   └── widgets/
│   │       └── whisper_card.dart
│   ├── split/
│   │   ├── models/
│   │   │   └── expense_model.dart
│   │   ├── screens/
│   │   │   ├── split_groups_screen.dart
│   │   │   └── group_details_screen.dart
│   │   └── widgets/
│   │       └── group_card.dart
│   └── settings/
│       └── screens/
│           └── settings_screen.dart
```

---

## 🚀 Key Features Walkthrough

### Creating a Note with Tags

1. Navigate to **Notes** tab
2. Tap the **+** button
3. Fill in title, subject, and content
4. Add tags for organization (e.g., "important", "exam")
5. Save the note

### Sharing a Note

1. Long-press a note card or tap the share button
2. Choose sharing method:
   - **As Text**: Share via any messaging app
   - **As JSON**: Export for backup or sharing with other StudyHub users
   - **QR Code**: Generate a scannable QR code

### Importing a Note

1. Tap the download icon in Notes screen
2. Select a `.json` file
3. Note will be imported automatically

### Setting Up Deadline Notifications

1. Create a deadline with due date/time
2. Notifications are automatically scheduled:
   - 24 hours before
   - 1 hour before
3. View notifications in your device's notification tray

### Splitting Expenses

1. Go to **ClassSplit** tab
2. Create a new group
3. Add member names (comma-separated)
4. Add expenses with payer and amount
5. Tap **Summary** to see who owes whom
6. Export as CSV for record-keeping

---

## 🔧 Troubleshooting

### Firebase Issues

**Problem:** "Class Whisper" shows error  
**Solution:** Ensure Firebase is properly configured. The app works without Firebase, but Whisper feature requires it.

### Notifications Not Working

**Problem:** Deadline notifications don't appear  
**Solution:**
- Ensure notification permissions are granted
- Check that device's Do Not Disturb is off
- Verify `minSdkVersion` is 21 or higher

### Build Errors

**Problem:** Gradle build fails  
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### QR Code Generation Fails

**Problem:** QR code doesn't display  
**Solution:** Ensure `qr_flutter` package is properly installed and note data isn't too large

---

## 📊 Database Schema

### Notes Table
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | UUID primary key |
| title | TEXT | Note title |
| body | TEXT | Note content |
| subject | TEXT | Subject/category |
| tags | TEXT | JSON array of tags |
| createdAt | TEXT | ISO timestamp |
| shared | INTEGER | Boolean flag |

### Deadlines Table
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | UUID primary key |
| title | TEXT | Deadline title |
| subject | TEXT | Subject/course |
| dueDate | TEXT | ISO timestamp |
| priority | INTEGER | 0=low, 1=medium, 2=high |
| completed | INTEGER | Boolean flag |

### Groups Table
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | UUID primary key |
| name | TEXT | Group name |
| members | TEXT | JSON array of names |
| expenses | TEXT | JSON array of expense objects |

---

## 🎯 Future Enhancements

- [ ] Cloud sync for notes and deadlines
- [ ] Study timer with Pomodoro technique
- [ ] Calendar view for deadlines
- [ ] Note collaboration in real-time
- [ ] Dark mode scheduling
- [ ] Widget support for home screen
- [ ] Bluetooth/WiFi Direct for offline note sharing
- [ ] AI-powered study recommendations
- [ ] Integration with Google Calendar
- [ ] Voice note recording

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material 3 design guidelines
- All open-source contributors

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Open an issue on GitHub
3. Contact via email

---

<div align="center">

**Made with ❤️ for students, by students**

⭐ Star this repo if you find it helpful!

</div>