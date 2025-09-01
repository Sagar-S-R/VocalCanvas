# 🎨 VocalCanvas

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Gemini%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)

**VocalCanvas** is a voice-first Flutter application that **empowers local artisans** by transforming their spoken descriptions into engaging, social-ready posts. Voice is part of cultural identity, so we use it as the foundation for creative expression.

Artisans record their thoughts, and **Flutter's Speech-to-Text (STT)** transcribes them in real-time. Then **Google Gemini AI** generates:
✅ SEO-friendly captions  
✅ Relevant hashtags  
✅ Location tags  
✅ Multilingual content support

This enables artisans to reach a **wider audience** and grow their visibility effortlessly across digital platforms.

---

## 🌟 Key Features

### 🎤 **Voice-First Content Creation**
- **Record → Transcribe → Generate → Post** workflow
- Real-time speech-to-text transcription
- Support for English and Hindi voice input
- High-quality audio recording with web and mobile support

### 🤖 **AI-Powered Content Generation**
- **Google Gemini AI** integration for intelligent content creation
- Automatic caption generation tailored for artisans
- Smart hashtag suggestions based on artwork descriptions
- Location inference from voice descriptions

### 🌐 **Multilingual Support**
- **Three language interface**: English, Hindi, Kannada
- Automatic content translation using Gemini AI
- Culturally appropriate content generation for different languages
- Multilingual user profiles and post content

### 🖼 **Social-Like Experience**
- Like, comment, and share posts
- Listen to **original audio recordings** from artists
- User profiles with voice-recorded bios
- Follow artists and admire their work

### 🎨 **Beautiful, Responsive UI**
- **Dark mode** support with elegant theming
- **Responsive design** - works seamlessly on mobile, tablet, and web
- **Staggered grid layouts** for artistic content display
- **Firebase Authentication** with Google Sign-In

### 📱 **Complete App Ecosystem**
- **Home** - Personalized feed of artisan posts
- **Explore** - Discover artworks by category and location
- **Exhibition** - Gallery-style showcase of top-rated posts
- **Create** - Voice-powered content creation studio
- **Profile & Settings** - Customizable user experience

---

## 📱 App Flow

1. **Authentication** 
   - Sign up as an Artist or Art Admirer
   - Record voice bio during registration
   - Multilingual profile setup

2. **Home Feed**
   - Personalized content based on preferences
   - Like, comment, and share functionality
   - Audio playback of original recordings

3. **Explore & Discovery**
   - Grid view of artworks with images and descriptions
   - Filter by location, category, or artist
   - Search functionality across posts and users

4. **Exhibition Gallery**
   - Curated showcase of top-liked posts
   - Elegant, museum-like presentation
   - Rank-based display with visual indicators

5. **Content Creation**
   - Voice recording with real-time transcription
   - AI-powered content enhancement via Gemini
   - Image upload and post customization
   - Multi-platform sharing capabilities

6. **Profile Management**
   - Multilingual bio and location settings
   - Audio introduction recording
   - Dark mode and language preferences

---

## 🛠️ Tech Stack

### **Frontend**
- **Flutter 3.7.2+** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management
- **Google Fonts** - Typography
- **Easy Localization** - Internationalization

### **Backend & Services**
- **Firebase Auth** - User authentication & Google Sign-In
- **Cloud Firestore** - NoSQL database for posts and users
- **Firebase Storage** - Image and audio file storage
- **Google Gemini AI** - Content generation and translation

### **Voice & Audio**
- **Speech-to-Text** - Real-time voice transcription
- **Record** - High-quality audio recording
- **AudioPlayers** - Audio playback functionality

### **UI/UX Libraries**
- **Flutter Staggered Grid View** - Artistic layout components
- **Image Picker** - Photo selection and camera integration
- **Flutter DotEnv** - Environment variable management

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point & Firebase initialization
├── core/
│   ├── services/
│   │   ├── ai_service.dart           # Gemini AI integration (expandable)
│   │   ├── post_service.dart         # Post CRUD operations
│   │   └── marketplace_api.dart      # Future marketplace features
│   └── theme/                        # App theming and styles
├── data/
│   └── models/
│       ├── post.dart                 # Post data model with multilingual support
│       └── user_model.dart           # User profile model
├── presentation/
│   ├── auth/
│   │   └── auth_page.dart           # Login/signup with voice bio recording
│   ├── home/                        # Home feed and navigation
│   ├── explore/                     # Content discovery and search
│   ├── exhibition/                  # Gallery-style post showcase
│   ├── create/
│   │   ├── create_screen.dart       # Post creation UI
│   │   └── widgets/
│   │       └── voice_recorder_widget.dart  # Core voice recording component
│   ├── profile/                     # User profiles and settings
│   ├── settings/                    # App preferences and configuration
│   └── widgets/                     # Reusable UI components
├── utils/
│   ├── constants.dart               # App constants and configuration
│   ├── locale_provider.dart         # Language state management
│   └── theme_provider.dart          # Dark mode state management
└── l10n/                           # Generated localization files

assets/
├── lang/                           # Translation files (en, hi, kn)
├── images/                         # Art samples and UI assets
└── .env                           # Environment variables (git-ignored)
```

---

## ✅ Prerequisites

### **Development Environment**
- **Flutter SDK 3.7.2+** → [Install Guide](https://docs.flutter.dev/get-started/install)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### **Platform-Specific Requirements**
- **Windows**: Visual Studio with "Desktop development with C++" workload
- **Android**: Android Studio with SDK and emulator setup
- **iOS**: Xcode (macOS only) for iOS development
- **Web**: Chrome browser for web testing

### **Firebase Setup**
- **Firebase Project** with Authentication and Firestore enabled
- **Google Sign-In** configured for your platforms
- **Firebase Storage** for image and audio files

### **API Keys**
- **Google Gemini AI API Key** from [Google AI Studio](https://makersuite.google.com)

---

## 🔑 Environment Variables

Create a `.env` file in the project root directory:

```env
# Gemini AI Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Configuration (Auto-configured in main.dart)
# These are already set up in the code but can be overridden here
# FIREBASE_API_KEY=your_firebase_api_key
# FIREBASE_AUTH_DOMAIN=your_auth_domain
# FIREBASE_PROJECT_ID=your_project_id
# FIREBASE_STORAGE_BUCKET=your_storage_bucket
# FIREBASE_MESSAGING_SENDER_ID=your_sender_id
# FIREBASE_APP_ID=your_app_id
# FIREBASE_MEASUREMENT_ID=your_measurement_id
```

> **🔒 Security Note**: `.env` is in `.gitignore`. Never commit your API keys!

---

## ⚡ Quick Setup (Windows PowerShell)

```powershell
# 1. Clone the repository
git clone https://github.com/Sakshamyadav15/VocalCanvas.git
cd VocalCanvas

# 2. Install Flutter dependencies
flutter pub get

# 3. Create environment file
notepad .env
# Add your GEMINI_API_KEY in the file

# 4. Run code analysis
flutter analyze

# 5. Run the application
flutter run -d windows    # For desktop
flutter run -d chrome     # For web
flutter run -d android    # For Android (with emulator/device)

# Check available devices
flutter devices
```

### **Alternative Setup Commands**
```powershell
# For macOS/Linux users
nano .env  # or vim .env

# Run with specific device
flutter run -d <device-id>

# Build for release
flutter build windows     # Desktop
flutter build web         # Web deployment
flutter build apk         # Android APK
```

---

## 🎯 How to Test Key Features

### **1. Voice Recording & AI Generation**
1. Go to **Create** page → Tap the **microphone button**
2. Speak a description of your artwork → Watch real-time transcription
3. Tap microphone again → Gemini processes and generates content
4. Review generated title, caption, hashtags, and location
5. Upload an image and publish your post

### **2. Multilingual Experience**
1. Go to **Settings** → Change language to Hindi or Kannada
2. Create a new post and notice AI-generated content in selected language
3. View your profile and see multilingual fields

### **3. Social Features**
1. Browse the **Home** feed and like posts
2. Go to **Exhibition** to see top-rated content
3. Use **Explore** to discover posts by location or hashtag
4. Listen to audio recordings from artists

### **4. Dark Mode & Theming**
1. Navigate to **Settings** → Toggle **Dark Mode**
2. Experience the beautiful dark theme across all screens

---

## 🔍 Known Issues & Roadmap

### **🚨 Current Issues**
- **Testing Coverage**: No unit/widget tests implemented yet
- **Error Handling**: Need more robust error handling for API failures
- **Performance**: Large image uploads may need optimization
- **Permissions**: Microphone permissions need proper handling on mobile

### **🛠️ Planned Improvements**
- [ ] **Comprehensive Testing Suite** - Unit and widget tests
- [ ] **Advanced AI Features** - Image analysis with Gemini Vision
- [ ] **Social Features** - Comments, following, notifications
- [ ] **Marketplace Integration** - Artist commission and sales features
- [ ] **Analytics Dashboard** - Post performance insights
- [ ] **Offline Mode** - Local storage and sync capabilities

### **🎯 Short-term Fixes**
- [ ] Move API logic to dedicated `AIService` class
- [ ] Add comprehensive error handling and retry mechanisms
- [ ] Implement proper loading states and user feedback
- [ ] Add image compression for better performance

---

## 🔐 Security & Privacy

### **Data Protection**
- **Environment Variables**: All sensitive keys stored in `.env` (git-ignored)
- **Firebase Security Rules**: Configured for user data protection
- **Audio Storage**: Secure base64 encoding for voice recordings
- **User Privacy**: Multilingual privacy policy and terms of service

### **Best Practices**
- Never commit API keys or sensitive configuration
- Use Firebase Security Rules for data access control
- Implement proper user authentication flows
- Regular security updates for dependencies

---

## 🚀 Deployment

### **Web Deployment**
```powershell
flutter build web
# Deploy the build/web folder to your hosting service
```

### **Android Release**
```powershell
flutter build apk --release
flutter build appbundle --release  # For Google Play Store
```

### **Windows Desktop**
```powershell
flutter build windows --release
```

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### **Development Guidelines**
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation for API changes
- Ensure multilingual support for user-facing text

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **Google** for Gemini AI and Firebase services
- **Open Source Community** for excellent packages and libraries
- **Local Artisans** who inspire this project's mission

---

## 💡 Why VocalCanvas?

We believe **voice is an art form** and **language is culture**. By empowering artisans to express themselves in their native language, VocalCanvas helps preserve cultural authenticity while making it easier to share art globally.

**VocalCanvas bridges the gap between traditional artistry and digital storytelling, ensuring that every voice is heard and every story is told.**

---

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/Sakshamyadav15/VocalCanvas/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Sakshamyadav15/VocalCanvas/discussions)
- **Email**: [Contact the maintainer](mailto:saksham.jadav@gmail.com)

---

**Made with ❤️ for artisans worldwide**
