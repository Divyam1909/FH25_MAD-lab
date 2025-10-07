# ⚡ StudyHub - Quick Start Guide

Get StudyHub running in 5 minutes! ⏱️

---

## 🎯 Fastest Path to Running App

### Step 1: Prerequisites (2 min)

Make sure you have:
```bash
# Check Flutter is installed
flutter --version

# Should show 3.0.0 or higher
```

If not installed: [Get Flutter](https://docs.flutter.dev/get-started/install)

### Step 2: Get the Code (30 sec)

```bash
git clone <your-repo-url>
cd studyhub
```

### Step 3: Install & Run (2 min)

```bash
# Install dependencies
flutter pub get

# Connect Android device or start emulator
flutter devices

# Run the app
flutter run
```

**That's it! 🎉** The app should now be running on your device.

---

## 🚀 What Works Out of the Box

Without any configuration, you can immediately use:

✅ **Peer Notes** - Create, edit, delete, tag, and share notes  
✅ **Deadline Radar** - Track assignments with visual radar  
✅ **ClassSplit** - Manage group expenses  
✅ **Settings** - Dark/light mode toggle  

❌ **Class Whisper** - Requires Firebase setup (optional)

---

## 🔥 Optional: Enable Class Whisper (10 min)

Want anonymous feedback feature? Follow these steps:

### 1. Create Firebase Project
- Go to [console.firebase.google.com](https://console.firebase.google.com/)
- Click "Add project"
- Name it "StudyHub"

### 2. Add Android App
- Click Android icon
- Package name: `com.example.study_hub`
- Download `google-services.json`
- Put in: `android/app/google-services.json`

### 3. Enable Firestore & Auth
- In Firebase Console:
  - Click "Firestore Database" → "Create database" → Test mode
  - Click "Authentication" → "Sign-in method" → Enable "Anonymous"

### 4. Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

**Done!** Class Whisper now works. 🎊

For detailed Firebase setup: See `FIREBASE_SETUP.md`

---

## 📱 First-Time User Guide

### Create Your First Note
1. Tap "Notes" tab at bottom
2. Tap **+** button
3. Fill in:
   - Title: "My First Note"
   - Subject: "Study"
   - Content: "StudyHub is awesome!"
4. Add tags: "test", "important"
5. Tap Save icon

### Share a Note
1. Long-press the note card
2. Choose sharing method:
   - **As Text** - Share via WhatsApp, Email, etc.
   - **As JSON** - Backup or share with StudyHub users
   - **QR Code** - Generate scannable code

### Set Up a Deadline
1. Tap "Deadlines" tab
2. Tap **+** button
3. Fill in:
   - Title: "Math Assignment"
   - Subject: "Mathematics"
   - Due: Tomorrow at 5 PM
   - Priority: High
4. Save

You'll get notifications 24h and 1h before!

### Track Group Expenses
1. Tap "Split" tab
2. Tap "New Group"
3. Name: "Weekend Trip"
4. Members: "Alice, Bob, Charlie"
5. Add expense:
   - Description: "Hotel"
   - Amount: 300
   - Paid by: Alice
6. View "Settlement Summary" to see who owes whom

---

## 🎨 Customize Your Experience

### Enable Dark Mode
1. Tap Settings icon (gear) on Home tab
2. Toggle "Dark Mode" switch
3. Enjoy your eyes! 👀

### Organize Notes
- Use **tags** to categorize notes
- Filter by **subject**
- Search by **keywords**

---

## 🐛 Quick Troubleshooting

### App won't build?
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### Notifications don't work?
- Settings → Apps → StudyHub → Permissions → Enable Notifications

### Firebase error?
- It's okay! App works without Firebase
- Only Class Whisper needs it
- Other features work perfectly offline

### Can't import note?
- Settings → Apps → StudyHub → Permissions → Enable Storage

---

## 📚 Learn More

- **Full Setup**: `README.md`
- **Firebase Guide**: `FIREBASE_SETUP.md`
- **Contributing**: `CONTRIBUTING.md`
- **Checklist**: `SETUP_CHECKLIST.md`

---

## ⚙️ Build for Release

When ready to share with friends:

```bash
# Build APK
flutter build apk --release

# Find APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

Share this APK file with anyone!

---

## 🎯 Next Steps

Now that you're up and running:

1. ⭐ **Star the repo** if you like it
2. 📝 **Create your first note**
3. 📅 **Add some deadlines**
4. 💸 **Track expenses with friends**
5. 🔥 **Set up Firebase** for Class Whisper (optional)
6. 🎨 **Customize** the theme
7. 📤 **Share** with classmates

---

## 💡 Pro Tips

- **Backup your notes**: Share all notes as JSON, save the file
- **Use tags wisely**: Tags like "exam", "important", "revision" help organization
- **Set realistic deadlines**: Add buffer time to avoid stress
- **Review radar daily**: Check the Home screen radar to stay on track
- **Split expenses immediately**: Add expenses right after they happen

---

## 🆘 Need Help?

- **Quick issues**: Check `SETUP_CHECKLIST.md`
- **Firebase problems**: See `FIREBASE_SETUP.md`
- **Code questions**: Open a GitHub issue
- **General help**: Email or create discussion

---

<div align="center">

**🎉 Enjoy StudyHub! 🎉**

Built with ❤️ for students

[Report Bug](link) · [Request Feature](link) · [Documentation](README.md)

</div>
