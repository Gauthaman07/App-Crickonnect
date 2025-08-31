# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Crickonnect is a Flutter mobile application for cricket enthusiasts to manage teams, book grounds, and participate in tournaments. The app supports both Android and iOS platforms with Firebase integration for notifications and backend services.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run unit and widget tests
- `flutter analyze` - Run static analysis
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Platform-Specific Commands
- `flutter run -d android` - Run on Android device/emulator
- `flutter run -d ios` - Run on iOS device/simulator
- `flutter build apk --release` - Build release APK
- `flutter build appbundle` - Build Android App Bundle for Play Store

## Architecture Overview

### Core Structure
- **Main Entry Point**: `lib/main.dart` - Contains app initialization, Firebase setup, FCM configuration, and authentication flow
- **API Layer**: `lib/services/api_service.dart` - Centralized HTTP client for backend communication with authentication handling
- **Authentication**: `lib/services/token_manager.dart` - JWT token management and storage
- **Push Notifications**: `lib/push/notification_service.dart` and `lib/services/fcm_manager.dart` - Firebase messaging integration

### Key Features
1. **Team Management**: Users must create/join a team before accessing main features
2. **Ground Booking**: Book cricket grounds with time slots and payment integration
3. **Tournament System**: Create and participate in cricket tournaments
4. **Push Notifications**: Firebase-based real-time notifications
5. **Multi-platform Support**: Android, iOS, Web, Windows, macOS, and Linux

### Navigation Flow
- Authentication check → Team validation → Main app (BottomNavBar)
- If no team exists, users are redirected to team creation form
- Main navigation uses IndexedStack for performance

### State Management
- Uses Flutter's built-in setState and Provider pattern
- SharedPreferences for local data persistence
- FutureBuilder for async data loading

### Backend Integration
- REST API at `https://crikonnect-api.onrender.com/api`
- JWT authentication with Bearer token
- Multipart requests for file uploads (team logos, ground images)
- Error handling with network connectivity checks

### Key Directories
- `lib/` - Main Dart source code
- `lib/services/` - API and service layer
- `lib/myteam/` - Team management features
- `lib/push/` - Notification handling
- `assets/` - Images and fonts
- `android/` - Android-specific configuration
- `ios/` - iOS-specific configuration

### Dependencies
- **Firebase**: Core, Messaging for push notifications
- **HTTP**: API communication
- **SharedPreferences**: Local storage
- **ImagePicker**: Photo selection for team logos
- **Provider**: State management
- **Google Fonts**: Custom typography

### Testing
- Widget tests in `test/widget_test.dart`
- Current test suite needs updating (contains placeholder counter test)
- Use `flutter test` to run tests