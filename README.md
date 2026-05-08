# Flutter Chat App

A modern, real-time chat application built with Flutter and Firebase, featuring user authentication, messaging, image sharing, and push notifications.

## 🚀 Features

- **User Authentication**: Secure login and registration using Firebase Authentication
- **Real-time Messaging**: Instant messaging with Cloud Firestore for real-time updates
- **Image Sharing**: Send and receive images using Firebase Storage
- **Push Notifications**: Receive notifications for new messages using Firebase Cloud Messaging
- **Local Notifications**: In-app notifications for better user experience
- **Profile Management**: Edit user profiles with avatars
- **Dark/Light Mode**: Theme switching with Provider for state management
- **Onboarding Experience**: Smooth introduction for new users
- **Settings Page**: Customize app preferences

## 📸 Screenshots

### Login Screen
![Login Screen](screenshots/login_screen.jpg)
*Placeholder: Add a screenshot of the login page here*

### Chat Interface
![Chat Interface](screenshots/chat_interface.jpg)
*Placeholder: Add a screenshot of the main chat screen here*

### Profile Page
![Profile Page](screenshots/profile_page.jpg)
*Placeholder: Add a screenshot of the user profile page here*

### Settings
![Settings](screenshots/settings_page.jpg)
*Placeholder: Add a screenshot of the settings page here*

*Note: Place your screenshots in a `screenshots/` folder in the root directory of the project.*

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile app development framework
- **Dart**: Programming language for Flutter
- **Firebase**:
  - Firebase Core: Core Firebase functionality
  - Firebase Auth: User authentication
  - Cloud Firestore: NoSQL database for real-time data
  - Firebase Storage: File storage for images
  - Firebase Messaging: Push notifications
- **Provider**: State management solution
- **Image Picker**: For selecting images from gallery/camera
- **Shared Preferences**: Local data storage
- **HTTP**: For network requests
- **Flutter Local Notifications**: In-app notifications

## 📚 Concepts Learned

Throughout the development of this Flutter chat app, we explored and implemented several key concepts:

### Flutter Fundamentals
- **Widget Tree**: Understanding the declarative UI structure
- **State Management**: Using Provider for app-wide state (theme, user data)
- **Navigation**: Implementing routes and navigator keys
- **Lifecycle Management**: Handling app initialization and background messages

### Firebase Integration
- **Authentication Flow**: Implementing login, registration, and user sessions
- **Real-time Database**: Using Firestore for live chat updates
- **File Storage**: Uploading and downloading images with Firebase Storage
- **Push Notifications**: Setting up FCM for cross-platform notifications

### Advanced Flutter Features
- **Asynchronous Programming**: Using async/await for Firebase operations
- **Streams**: Listening to real-time data changes
- **Platform Channels**: Integrating native features (notifications, image picker)
- **Dependency Injection**: Managing services and providers

### UI/UX Design
- **Material Design**: Following Google's design guidelines
- **Responsive Layout**: Adapting to different screen sizes
- **Theme Management**: Implementing dark/light mode switching
- **User Onboarding**: Creating smooth first-time user experiences

### Best Practices
- **Code Organization**: Structuring code into models, services, pages, and components
- **Error Handling**: Managing Firebase errors and network issues
- **Security**: Implementing proper authentication and data validation
- **Performance**: Optimizing for smooth real-time chat experience

## 🏃‍♂️ Getting Started

### Prerequisites
- Flutter SDK (version 3.11.4 or higher)
- Dart SDK (version 3.11.4 or higher)
- Firebase project with enabled services (Auth, Firestore, Storage, Messaging)
- Android Studio or VS Code for development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/flutter_chat_app.git
   cd flutter_chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` for Android and place it in `android/app/`
   - For iOS, configure the Firebase project accordingly
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Usage

1. **Onboarding**: New users will see an introduction screen
2. **Authentication**: Register or login with email/password
3. **Home Screen**: View available chat rooms or start new conversations
4. **Chat Screen**: Send text messages and images in real-time
5. **Profile**: Edit your profile information and avatar
6. **Settings**: Toggle themes and manage app preferences

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Open source community for inspiration and tools

---

*Built with ❤️ using Flutter and Firebase*
