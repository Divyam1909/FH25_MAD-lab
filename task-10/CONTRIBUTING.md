# 🤝 Contributing to StudyHub

First off, thank you for considering contributing to StudyHub! It's people like you that make StudyHub such a great tool for students worldwide.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)

---

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- ✅ Be respectful and inclusive
- ✅ Welcome newcomers and help them learn
- ✅ Focus on what is best for the community
- ✅ Show empathy towards other community members
- ❌ No harassment, trolling, or derogatory comments
- ❌ No political or unrelated discussions

---

## Getting Started

### Issues

- **Bug Reports**: If you find a bug, please create an issue with:
  - Clear description of the problem
  - Steps to reproduce
  - Expected vs actual behavior
  - Screenshots if applicable
  - Your environment (Flutter version, device, OS)

- **Feature Requests**: We love new ideas! Please include:
  - Clear description of the feature
  - Why it would be useful
  - Possible implementation approach

### Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to docs
- `good first issue` - Great for newcomers
- `help wanted` - Extra attention needed

---

## How Can I Contribute?

### 1. Report Bugs

Found a bug? Please create an issue with:

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - Device: [e.g. Pixel 6]
 - OS: [e.g. Android 13]
 - Flutter version: [e.g. 3.16.0]
 - App version: [e.g. 1.0.0]
```

### 2. Suggest Enhancements

Have an idea? Create a feature request:

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other context or screenshots.
```

### 3. Improve Documentation

- Fix typos
- Add examples
- Clarify instructions
- Add translations

### 4. Write Code

- Fix bugs
- Add features
- Improve performance
- Refactor code

---

## Development Setup

### Prerequisites

```bash
# Check Flutter version
flutter --version

# Should be 3.0.0 or higher
```

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/studyhub.git
cd studyhub

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/studyhub.git
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
# Connect a device or start emulator
flutter devices

# Run in debug mode
flutter run

# Run with hot reload
flutter run --hot
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/note_model_test.dart
```

---

## Pull Request Process

### 1. Create a Branch

```bash
# Update your fork
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Changes

- Write clear, readable code
- Follow the coding standards below
- Add comments for complex logic
- Update documentation if needed

### 3. Test Your Changes

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build to check for errors
flutter build apk --debug
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add user profile feature"
```

See [Commit Messages](#commit-messages) for format.

### 5. Push to GitHub

```bash
git push origin feature/your-feature-name
```

### 6. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Added tests
- [ ] All tests pass

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed my code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
```

5. Click "Create Pull Request"

### 7. Code Review

- Maintainers will review your PR
- Address any feedback
- Make requested changes
- Push updates to the same branch

---

## Coding Standards

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style).

#### Naming Conventions

```dart
// Classes, enums, typedefs - PascalCase
class NoteModel { }
enum Priority { low, medium, high }

// Libraries, packages, directories - snake_case
import 'note_model.dart';

// Variables, functions, parameters - camelCase
String userName;
void loadNotes() { }

// Constants - lowerCamelCase
const defaultTimeout = 30;
```

#### File Organization

```dart
// 1. Imports (grouped and sorted)
import 'dart:io';              // Dart SDK
import 'dart:async';

import 'package:flutter/material.dart';  // Flutter SDK
import 'package:provider/provider.dart';  // External packages

import '../models/note.dart';  // Relative imports

// 2. Constants

// 3. Class definition

// 4. Constructor

// 5. Fields

// 6. Overrides

// 7. Public methods

// 8. Private methods
```

### Widget Best Practices

```dart
// ✅ Good - Extract reusable widgets
class _CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  
  const _CustomButton({
    required this.onPressed,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ❌ Bad - Repeating code
ElevatedButton(onPressed: () {}, child: Text('Save'))
ElevatedButton(onPressed: () {}, child: Text('Cancel'))
```

### State Management

```dart
// Use Provider for state management
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Text('Current theme: ${theme.isDarkMode}');
  }
}
```

### Error Handling

```dart
// ✅ Good - Handle errors gracefully
try {
  await saveNote(note);
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

// ❌ Bad - Silent failures
try {
  await saveNote(note);
} catch (e) {
  // Nothing
}
```

### Comments

```dart
// ✅ Good - Explain why, not what
// Using debounce to prevent excessive API calls
Timer? _debounce;

// ❌ Bad - Stating the obvious
// This is a string
String name;
```

---

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(notes): add tag filtering"

# Bug fix
git commit -m "fix(deadlines): correct date calculation"

# Documentation
git commit -m "docs(readme): update setup instructions"

# Breaking change
git commit -m "feat(auth)!: change authentication flow

BREAKING CHANGE: Users need to re-login after update"
```

---

## Testing

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Note Model', () {
    test('should create note with defaults', () {
      final note = Note(
        title: 'Test',
        body: 'Content',
        subject: 'Math',
      );
      
      expect(note.title, 'Test');
      expect(note.tags, []);
    });
    
    test('should convert to/from JSON', () {
      final note = Note(
        title: 'Test',
        body: 'Content',
        subject: 'Math',
      );
      
      final json = note.toJson();
      final restored = Note.fromJson(json);
      
      expect(restored.title, note.title);
    });
  });
}
```

### Widget Tests

```dart
testWidgets('NoteCard displays title', (WidgetTester tester) async {
  final note = Note(
    title: 'Test Note',
    body: 'Test Content',
    subject: 'Math',
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: NoteCard(
        note: note,
        onTap: () {},
        onDelete: () {},
        onShare: () {},
      ),
    ),
  );
  
  expect(find.text('Test Note'), findsOneWidget);
});
```

---

## Documentation

### Code Documentation

```dart
/// Creates a new note with the given parameters.
///
/// The [title], [body], and [subject] are required.
/// [tags] defaults to an empty list if not provided.
///
/// Example:
/// ```dart
/// final note = Note(
///   title: 'Chapter 1',
///   body: 'Introduction to...',
///   subject: 'Physics',
///   tags: ['important', 'exam'],
/// );
/// ```
class Note {
  // ...
}
```

### Update README

If your changes affect usage:
- Update code examples
- Add new features to feature list
- Update screenshots if UI changed

---

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase Documentation](https://firebase.google.com/docs)

---

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community (if available)
- Reach out to maintainers

---

<div align="center">

**Thank you for contributing! 🎉**

Every contribution, no matter how small, makes StudyHub better for everyone.

</div>
