# ✅ StudyHub Setup Checklist

Use this checklist to ensure your StudyHub app is properly configured and ready to run.

---

## 📋 Pre-Installation Checklist

- [ ] **Flutter SDK** (3.0.0+) installed
  ```bash
  flutter --version
  ```

- [ ] **Android Studio** or **VS Code** with Flutter extensions installed

- [ ] **Android device or emulator** available
  ```bash
  flutter devices
  ```

- [ ] **Git** installed and configured

---

## 🚀 Installation Steps

### 1. Project Setup

- [ ] Clone the repository
  ```bash
  git clone <repository-url>
  cd studyhub
  ```

- [ ] Install dependencies
  ```bash
  flutter pub get
  ```

- [ ] Verify no errors
  ```bash
  flutter doctor
  ```

### 2. Android Configuration

- [ ] Check `android/app/build.gradle.kts`:
  - [ ] `minSdkVersion` is 21 or higher
  - [ ] `targetSdkVersion` is 34
  - [ ] Application ID is set correctly

- [ ] Verify permissions in `AndroidManifest.xml`:
  - [ ] INTERNET
  - [ ] WRITE_EXTERNAL_STORAGE (for file operations)
  - [ ] POST_NOTIFICATIONS (for deadline reminders)
  - [ ] SCHEDULE_EXACT_ALARM (for notifications)

### 3. Firebase Setup (OPTIONAL - Only for Class Whisper)

**If you want to use Class Whisper feature:**

- [ ] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)

- [ ] Register Android app with package name matching your `applicationId`

- [ ] Download `google-services.json`

- [ ] Place file in `android/app/google-services.json`

- [ ] Add Google Services plugin to `android/app/build.gradle.kts`:
  ```kotlin
  apply(plugin = "com.google.gms.google-services")
  ```

- [ ] Add classpath to `android/build.gradle.kts`:
  ```kotlin
  classpath("com.google.gms:google-services:4.4.0")
  ```

- [ ] Enable Anonymous Authentication in Firebase Console

- [ ] Create Firestore Database in Test Mode

- [ ] Update Firestore security rules (see `FIREBASE_SETUP.md`)

**If you DON'T need Class Whisper:**

- [ ] App will work fine without Firebase
- [ ] All other features (Notes, Deadlines, Split) work offline

---

## 🧪 Testing

### Pre-Launch Tests

- [ ] Run linter check
  ```bash
  flutter analyze
  ```

- [ ] Format code
  ```bash
  flutter format lib/
  ```

- [ ] Build debug APK
  ```bash
  flutter build apk --debug
  ```

### Feature Tests

After launching the app, verify each feature works:

#### Home Dashboard
- [ ] Dashboard loads successfully
- [ ] Deadline radar displays (empty or with deadlines)
- [ ] Stats cards show correct numbers
- [ ] Quick access cards are clickable
- [ ] Settings button opens settings screen

#### Peer Notes
- [ ] Can create a new note
- [ ] Can add title, subject, body
- [ ] Can add and remove tags
- [ ] Notes list displays correctly
- [ ] Can edit existing notes
- [ ] Can delete notes
- [ ] **Sharing features:**
  - [ ] Share as text works
  - [ ] Share as JSON works
  - [ ] QR code generation works
  - [ ] Import note from JSON file works

#### Deadline Radar
- [ ] Can create a new deadline
- [ ] Can select date and time
- [ ] Can set priority (Low/Medium/High)
- [ ] Deadlines display in list
- [ ] Can edit existing deadlines
- [ ] Can mark as completed
- [ ] Completed deadlines show checkmark
- [ ] Can delete deadlines
- [ ] Radar visualization shows on home screen

#### Class Whisper (if Firebase configured)
- [ ] Screen loads without errors
- [ ] Can post anonymous feedback
- [ ] Posts display in real-time
- [ ] Can mark posts as resolved
- [ ] Resolved posts show indicator
- **If Firebase NOT configured:**
  - [ ] Shows error message gracefully
  - [ ] App doesn't crash

#### ClassSplit
- [ ] Can create a new group
- [ ] Can add member names
- [ ] Group displays in list
- [ ] Can open group details
- [ ] Can add expenses
- [ ] Total calculates correctly
- [ ] Settlement summary works
- [ ] Can export as CSV
- [ ] Can delete groups

#### Settings
- [ ] Dark/Light mode toggle works
- [ ] Theme persists after app restart
- [ ] About dialog displays correctly
- [ ] Share app option works

---

## 🎨 UI/UX Verification

- [ ] App uses Material 3 design
- [ ] Navigation bar works smoothly
- [ ] All icons display correctly
- [ ] Cards have rounded corners
- [ ] Color scheme is consistent (teal/indigo)
- [ ] Dark mode looks good
- [ ] No UI overflow errors
- [ ] Buttons are touchable
- [ ] Forms are easy to use
- [ ] Snackbars show appropriate messages

---

## 📱 Device Testing

Test on multiple configurations:

### Screen Sizes
- [ ] Small phone (< 5.5")
- [ ] Medium phone (5.5" - 6.5")
- [ ] Large phone (> 6.5")
- [ ] Tablet (optional)

### Android Versions
- [ ] Android 5.0 (API 21) - minimum
- [ ] Android 10 (API 29)
- [ ] Android 13 (API 33) - recommended
- [ ] Android 14 (API 34) - latest

### Orientations
- [ ] Portrait mode works
- [ ] Landscape mode works (optional)

---

## 🔔 Notifications Testing

- [ ] Create a deadline with near future time
- [ ] Grant notification permissions
- [ ] Wait for notification to appear
- [ ] Verify notification content is correct
- [ ] Tap notification (should open app)

---

## 📊 Performance Checks

- [ ] App launches in < 3 seconds
- [ ] Navigation is smooth (60 FPS)
- [ ] No memory leaks
- [ ] Database operations are fast
- [ ] Images/icons load quickly
- [ ] No ANRs (Application Not Responding)

---

## 🐛 Common Issues & Solutions

### Issue: Build fails with "Minimum SDK version" error
**Solution:**
```gradle
// In android/app/build.gradle.kts
android {
    defaultConfig {
        minSdkVersion = 21  // Change from 16 to 21
    }
}
```

### Issue: "google-services.json not found"
**Solution:**
- Either add Firebase (see `FIREBASE_SETUP.md`)
- Or comment out Firebase initialization in `lib/main.dart`

### Issue: Notifications don't show
**Solution:**
- Grant notification permissions in device settings
- Ensure `minSdkVersion` >= 21
- Check that `flutter_local_notifications` is properly configured

### Issue: QR code doesn't generate
**Solution:**
- Ensure `qr_flutter` package is in `pubspec.yaml`
- Run `flutter pub get`
- Rebuild the app

### Issue: Import note doesn't work
**Solution:**
- Grant storage permissions
- Ensure file is valid JSON
- Check file picker has correct permissions

### Issue: Dark mode doesn't persist
**Solution:**
- `shared_preferences` should be in dependencies
- Check if device has "Override force-dark" enabled

---

## 🚀 Production Build Checklist

Before releasing to users:

### Code Quality
- [ ] All linter warnings fixed
- [ ] No debug print statements
- [ ] No TODO comments in critical code
- [ ] All features tested thoroughly
- [ ] Error handling is robust

### Assets & Resources
- [ ] App icon set
- [ ] Splash screen configured
- [ ] All images optimized
- [ ] Unused assets removed

### Security
- [ ] Firebase rules updated for production
- [ ] No API keys hardcoded
- [ ] Sensitive data encrypted
- [ ] Input validation on all forms

### Performance
- [ ] App size < 50MB
- [ ] Launch time < 3 seconds
- [ ] Memory usage optimized
- [ ] No memory leaks detected

### Build Configuration
- [ ] Update version in `pubspec.yaml`
- [ ] Update version code in `build.gradle`
- [ ] Set `debugShowCheckedModeBanner: false`
- [ ] Configure ProGuard rules (optional)

### Release Build
- [ ] Generate signed APK:
  ```bash
  flutter build apk --release
  ```

- [ ] Test release build on physical device

- [ ] Verify APK size is reasonable

- [ ] Check that all features work in release mode

### Store Preparation
- [ ] Screenshots prepared (phone & tablet)
- [ ] App description written
- [ ] Privacy policy created (if using Firebase)
- [ ] Store listing graphics ready
- [ ] Promo video (optional)

---

## 📝 Final Verification

- [ ] All checklist items above completed
- [ ] App tested on at least 2 different devices
- [ ] No critical bugs present
- [ ] All features work as expected
- [ ] Documentation is complete
- [ ] Code is committed to repository
- [ ] README is updated with latest info

---

## 🎉 Ready to Launch!

Once all items are checked, your StudyHub app is ready for:
- Local use
- Sharing with friends
- Publishing to Google Play Store
- Showcasing in portfolio

---

## 📞 Need Help?

If stuck on any step:
1. Check `README.md` for detailed instructions
2. Review `FIREBASE_SETUP.md` for Firebase issues
3. See `CONTRIBUTING.md` for development guidelines
4. Open an issue on GitHub
5. Check Stack Overflow with tags: `flutter`, `firebase`

---

<div align="center">

**Happy Coding! 🚀**

Made with ❤️ for students worldwide

</div>
