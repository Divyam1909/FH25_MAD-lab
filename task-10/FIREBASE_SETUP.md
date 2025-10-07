# 🔥 Firebase Setup Guide for StudyHub

This guide provides detailed instructions for setting up Firebase for the **Class Whisper** feature in StudyHub.

> **Note:** Firebase is OPTIONAL. The app will work perfectly without it, except for the Class Whisper (anonymous feedback) feature.

---

## 📋 Table of Contents

1. [Create Firebase Project](#1-create-firebase-project)
2. [Add Android App](#2-add-android-app-to-firebase)
3. [Configure Firestore Database](#3-configure-firestore-database)
4. [Enable Anonymous Authentication](#4-enable-anonymous-authentication)
5. [Update Android Configuration](#5-update-android-configuration)
6. [Optional: iOS Setup](#6-optional-ios-setup)
7. [Testing](#7-testing-firebase-connection)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "**Add project**" or "**Create a project**"
   - Enter project name: `StudyHub` (or your preferred name)
   - Click "**Continue**"

3. **Google Analytics (Optional)**
   - Choose whether to enable Google Analytics
   - Select analytics account or create new one
   - Click "**Create project**"
   - Wait for project creation (1-2 minutes)

4. **Access Project**
   - Click "**Continue**" when setup is complete
   - You'll be redirected to your Firebase project dashboard

---

## 2. Add Android App to Firebase

1. **Register App**
   - On Firebase Console dashboard, click the **Android icon** (Android robot)
   - Or go to: Project Settings → Your apps → Add app → Android

2. **Enter App Details**
   - **Android package name**: `com.example.study_hub`
     - ⚠️ **IMPORTANT**: This must match your `applicationId` in `android/app/build.gradle`
     - To find it: Open `android/app/build.gradle.kts` and look for:
       ```kotlin
       android {
           defaultConfig {
               applicationId = "com.example.study_hub"  // ← This value
           }
       }
       ```
   - **App nickname** (optional): StudyHub
   - **Debug signing certificate SHA-1** (optional): Leave blank for now
   - Click "**Register app**"

3. **Download Config File**
   - Click "**Download google-services.json**"
   - This file contains your Firebase project configuration

4. **Add Config File to Project**
   - Move `google-services.json` to: `android/app/` directory
   - Path should be: `android/app/google-services.json`
   
   ```
   android/
   ├── app/
   │   ├── google-services.json  ← Place here
   │   ├── build.gradle.kts
   │   └── src/
   └── build.gradle.kts
   ```

5. **Continue Through Steps**
   - Click "**Next**" through remaining Firebase setup steps
   - We'll configure the SDK in next section

---

## 3. Configure Firestore Database

1. **Create Firestore Database**
   - In Firebase Console, navigate to "**Build**" → "**Firestore Database**"
   - Click "**Create database**"

2. **Choose Security Rules**
   - Select "**Start in test mode**" (for development)
   - This allows read/write access for 30 days
   - Click "**Next**"

3. **Select Location**
   - Choose a Cloud Firestore location near you
   - Example: `us-central` or `asia-south1`
   - ⚠️ This cannot be changed later!
   - Click "**Enable**"

4. **Wait for Database Creation**
   - Takes 30-60 seconds
   - Database will be ready when you see the empty collection screen

5. **Update Security Rules (Important!)**
   - Click "**Rules**" tab
   - Replace default rules with:
   
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Whispers collection - allow authenticated reads, authenticated writes
       match /whispers/{whisperId} {
         allow read: if true;  // Anyone can read whispers
         allow create: if request.auth != null;  // Only authenticated users can create
         allow update, delete: if request.auth != null;  // Only auth users can update/delete
       }
     }
   }
   ```
   
   - Click "**Publish**"

---

## 4. Enable Anonymous Authentication

1. **Navigate to Authentication**
   - In Firebase Console, go to "**Build**" → "**Authentication**"
   - Click "**Get started**" (if first time)

2. **Enable Anonymous Sign-in**
   - Click "**Sign-in method**" tab
   - Find "**Anonymous**" in the list
   - Click on it
   - Toggle "**Enable**" switch to ON
   - Click "**Save**"

3. **Verify Setup**
   - "Anonymous" should show "Enabled" status in the sign-in methods list

---

## 5. Update Android Configuration

### 5.1 Update Project-Level build.gradle

Open `android/build.gradle.kts` and verify:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")  // Add this line
    }
}
```

If the file is `build.gradle` (Groovy):
```groovy
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 5.2 Update App-Level build.gradle

Open `android/app/build.gradle.kts` and add at the **bottom** of the file:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

If using `build.gradle` (Groovy):
```groovy
apply plugin: 'com.google.gms.google-services'
```

### 5.3 Update minSdkVersion

In `android/app/build.gradle.kts`, ensure:

```kotlin
android {
    defaultConfig {
        minSdkVersion = 21  // Required for Firebase
        targetSdkVersion = 34
    }
}
```

### 5.4 Enable Multidex (if needed)

If you encounter "method count exceeded" error, add in `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

---

## 6. Optional: iOS Setup

If you want to run the app on iOS:

1. **Register iOS App in Firebase**
   - In Firebase Console, click "**Add app**" → Choose iOS
   - Enter iOS bundle ID: Same as Android package name
   - Download `GoogleService-Info.plist`

2. **Add Config File**
   - Open Xcode
   - Drag `GoogleService-Info.plist` into `ios/Runner/`
   - Ensure "Copy items if needed" is checked

3. **Update Info.plist**
   - Add required Firebase configurations
   - Update iOS minimum deployment target to 12.0

4. **Install Pods**
   ```bash
   cd ios
   pod install
   cd ..
   ```

---

## 7. Testing Firebase Connection

1. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

2. **Test Class Whisper Feature**
   - Open the app
   - Navigate to "**Whisper**" tab
   - Try posting an anonymous message
   - Check if message appears in the list

3. **Verify in Firebase Console**
   - Go to Firestore Database
   - You should see a `whispers` collection
   - Documents will appear when you post messages

4. **Check Authentication**
   - Go to Authentication → Users
   - You'll see anonymous users appear when using the app

---

## 8. Troubleshooting

### Error: "Default FirebaseApp is not initialized"

**Solution:**
- Ensure `google-services.json` is in `android/app/`
- Verify `apply plugin: 'com.google.gms.google-services'` is in `android/app/build.gradle`
- Run `flutter clean` and rebuild

### Error: "FirebaseOptions cannot be null"

**Solution:**
- Check that Firebase is initialized in `main.dart`:
  ```dart
  await Firebase.initializeApp();
  ```
- Verify `google-services.json` has correct package name

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution:**
- Update Firestore security rules as shown in Section 3
- Ensure Anonymous authentication is enabled

### App builds but Whisper doesn't work

**Solution:**
- Check internet connection
- Verify Firestore rules allow read/write
- Check Firebase Console → Firestore for error logs
- Ensure `firebase_core`, `firebase_auth`, and `cloud_firestore` are in `pubspec.yaml`

### Package name mismatch

**Solution:**
- Delete the app from Firebase Console
- Re-register with correct package name matching your `applicationId`
- Download new `google-services.json`

---

## 📱 Alternative: Skip Firebase Setup

If you don't want to use Firebase:

1. The app will work fine without it
2. Only Class Whisper feature won't work
3. You'll see a message: "Firebase not configured"
4. All other features (Notes, Deadlines, Split) work perfectly offline

To disable Firebase completely:
- Comment out Firebase initialization in `lib/main.dart`:
  ```dart
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization skipped');
  // }
  ```

---

## 🔒 Security Best Practices

### For Production:

1. **Update Firestore Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /whispers/{whisperId} {
         allow read: if true;
         allow create: if request.auth != null && 
                       request.resource.data.keys().hasAll(['text', 'createdAt', 'resolved']) &&
                       request.resource.data.text is string &&
                       request.resource.data.text.size() <= 500;
         allow update: if request.auth != null && 
                       request.resource.data.diff(resource.data).affectedKeys().hasOnly(['resolved']);
         allow delete: if false;  // Disable deletion in production
       }
     }
   }
   ```

2. **Add App Check** (optional):
   - Prevents abuse and bot traffic
   - Go to Firebase Console → App Check
   - Register your app

3. **Enable Authentication (Optional):**
   - Add email/password or Google sign-in
   - Replace anonymous auth for better user management

4. **Set Usage Quotas:**
   - Go to Firestore → Usage
   - Set daily read/write limits
   - Enable billing alerts

---

## 📊 Firebase Free Tier Limits

| Service | Free Tier Limit |
|---------|----------------|
| **Firestore Reads** | 50,000/day |
| **Firestore Writes** | 20,000/day |
| **Firestore Storage** | 1 GB |
| **Authentication** | Unlimited |
| **Hosting** | 10 GB/month |

For a student app, free tier is usually sufficient!

---

## 🆘 Need Help?

- **Firebase Documentation**: https://firebase.google.com/docs
- **FlutterFire Documentation**: https://firebase.flutter.dev
- **Stack Overflow**: Tag your questions with `firebase` and `flutter`
- **GitHub Issues**: Open an issue in the StudyHub repository

---

<div align="center">

**Firebase setup complete! 🎉**

Your Class Whisper feature is now ready to use!

</div>
