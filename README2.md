
# 🎨 VocalCanvas

**VocalCanvas** is a voice-first Flutter app built to **empower local artisans** by transforming their spoken descriptions into engaging, social-ready posts. Voice is part of cultural identity, so we use it as the foundation.

Artisans record their thoughts, and **Flutter’s Speech-to-Text (STT)** transcribes them. Then **Google Gemini** generates:
✅ SEO-friendly captions  
✅ Hashtags  
✅ Location tags  

This enables artisans to reach a **wider audience** and grow their visibility effortlessly.

---

## 🌟 Key Features

- 🎤 **Voice-first content creation** – Record → Transcribe → Generate → Post  
- 🤖 **Gemini-powered content generation** (captions, hashtags, location tags)  
- 🌐 **Multilingual interface** – English, Hindi, Kannada  
- 🖼 **Social-like experience**:  
  - Like, comment, share posts  
  - Listen to **original audio recordings**  
- 🖤 **Beautiful UI** with **dark mode**  
- 📱 **Responsive design** – Works on mobile & web  
- 🏛 **Exhibition Page** – Highlights top posts in an artistic layout  
- 🔍 **Explore & Search** – Discover artworks by title, category, or location  
- 👤 **Profile & Settings** – Dark mode toggle, language settings, profile customization  

---

## 📱 App Flow

1. **Home** – Personalized feed of artisan posts  
2. **Explore** – Grid of artworks with image, title, location  
3. **Exhibition** – Showcase of top-rated posts in an elegant gallery-style UI  
4. **Create** –  
   - Record voice (English/Hindi supported for now)  
   - Real-time STT transcription  
   - Gemini processes transcription → generates SEO-friendly content  
5. **Profile & Settings** – Dark mode toggle, language settings, profile customization  

---

## 🛠️ Tech Stack

- **Flutter** – Cross-platform UI  
- **Firebase** – Auth, Firestore (DB), Storage, Hosting  
- **Google Gemini API** – AI-powered text generation  
- **Flutter Speech-to-Text** – Real-time voice transcription  
- **Packages used**:  
  - `flutter_dotenv`  
  - `speech_to_text`  
  - `record`  
  - `http`  
  - `google_fonts`  
  - `flutter_staggered_grid_view`  

---

## 📂 Repo Layout

- `lib/main.dart` → Entry point, loads `.env` and initializes app  
- `lib/presentation/create/widgets/voice_recorder_widget.dart` → Voice recording + transcription + Gemini API integration  
- `lib/presentation/create/create_screen.dart` → UI for Create feature  
- `lib/core/services/ai_service.dart` → Handles Gemini API calls  
- `pubspec.yaml` → Dependencies & assets  

---

## ✅ Prerequisites

- **Flutter SDK** → [Install Guide](https://docs.flutter.dev/get-started/install)  
- **Android Studio** or **VS Code**  
- **Firebase Project** (Enable Authentication & Firestore)  
- **Gemini API Key** from Google AI Studio  

---

## 🔑 Environment Variables

Create a `.env` file in the root directory:

```
GEMINI_API_KEY=your_api_key_here
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

> **Note**: `.env` is in `.gitignore`. Never commit your secrets!  

---

## ▶️ Quick Setup (Windows PowerShell)

```powershell
# Clone repo
git clone <your-repo-url>
cd VocalCanvas

# Install dependencies
flutter pub get

# Create .env and add keys
notepad .env

# Run app
flutter run -d windows    # for desktop
flutter run -d chrome     # for web
flutter run -d <device-id> # for Android/iOS
```

---

## 🎨 How to Test the Create Flow

1. Go to **Create** page → Tap **mic button**  
2. Speak a description → Real-time transcription  
3. Tap mic again → Gemini processes it → Generates post content + hashtags  
4. Copy, edit, or post directly in the app  

---

## 🔍 Known Issues

- ❗ **Recorder API mismatch** – Fix by using latest `record` package  
- ❗ **Error handling** – Add robust parsing for Gemini responses  
- ❗ **Testing** – No widget/unit tests yet  
- ❗ **Permissions** – Add microphone permissions in `AndroidManifest.xml` and `Info.plist`  

---

## 🔐 Security & Secrets

- `.env` is ignored by git  
- Use environment-specific secrets for production deployment  

---

## ✅ Suggested Next Steps

- [ ] Move API calls to `AIService`  
- [ ] Add proper error handling & retry logic  
- [ ] Build Exhibition page with **staggered grid layout**  
- [ ] Add widget tests for the Create flow  
- [ ] Optimize multilingual translations for better UX  

---

## 💡 Why VocalCanvas?

We believe **voice is an art form** and **language is culture**. By empowering artisans to express themselves in their own language, VocalCanvas helps preserve cultural authenticity while making it easier to share art globally.

---

### License  
MIT
