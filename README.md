VocalCanvas is a Flutter voice-first application that helps artists turn spoken descriptions of their work into short social posts (Instagram-ready) using speech transcription + a large language model (LLM) generation step.

This README explains how to set up the project locally (Windows PowerShell), which environment variables are required, how to run the app, and where known issues live.

## What this project does

- Desktop-friendly UI with a collapsible left sidebar and screens: Home, Explore, Search, Exhibition, Create.
- Core flow (Create): record voice → real-time transcription → send transcription to an LLM endpoint (Groq) → receive generated social copy + hashtags → display result for user to copy/use.
- Uses these Flutter packages: `flutter_dotenv`, `record`, `speech_to_text`, `http`, `google_fonts`, `flutter_staggered_grid_view`.

## Repo layout (important files)

- `lib/main.dart` — app entry; loads `.env` and shows `VocalCanvasHomePage`.
- `lib/presentation/create/widgets/voice_recorder_widget.dart` — recorder + transcription + network call to Groq API.
- `lib/presentation/create/create_screen.dart` — Create screen & generated post UI.
- `lib/core/services/ai_service.dart` — currently a stub (recommended: move network logic here).
- `pubspec.yaml` — dependencies and assets list.
- `.gitignore` — already ignores `.env` (keep your API keys private).

## Prerequisites

1. Flutter SDK (stable channel). Follow: https://docs.flutter.dev/get-started/install/windows
2. For Windows desktop builds: Visual Studio with "Desktop development with C++" workload.
3. If targeting Android/iOS: Android Studio / Xcode respectively and the platform-specific setup.
4. (Optional) Python + pip — only needed if you plan to run `lib/speech_to_text.py` standalone.

## Required environment variables

Create a file named `.env` in the project root (this file is ignored by git). Minimal required keys:

```
GROQ_API_KEY=sk_your_groq_key_here
```

- `GROQ_API_KEY` — used by `voice_recorder_widget.dart` to authorize calls to the Groq API endpoint.

I recommend creating `.env.example` with the same key but placeholder value so collaborators know what to add.

## Quick setup (Windows PowerShell)

1. Open PowerShell in the project root (where `pubspec.yaml` is).
2. Install dependencies and analyze code:

```powershell
flutter pub get
flutter analyze
```

3. Create a `.env` file in the project root with your `GROQ_API_KEY` (example above).

4. Run the app (desktop):

```powershell
flutter run -d windows
```

Or run in Chrome/web if you prefer:

```powershell
flutter run -d chrome
```

To run on Android (emulator or device):

```powershell
flutter devices # check devices
flutter run -d <device-id>
```

## How to test the Create flow

1. Open the app and click Create (plus icon in the sidebar).
2. Tap the circular microphone button to start recording (it will transcribe live).
3. Tap again to stop. The app sends the transcription to the configured GROQ API and shows the generated post.

If nothing appears, check the console for logs — the app prints API/network errors to the debug console.

## Known issues & recommended fixes

1. Recorder API mismatch
	- `voice_recorder_widget.dart` currently creates `AudioRecorder _audioRecorder = AudioRecorder();` but the `record` package exposes a `Record` class with `Record().start()` / `Record().stop()` API. This will raise runtime errors. Recommended fix: replace with the `Record` usage per package docs.

2. Network call & parsing
	- The code posts JSON to `https://api.groq.com/openai/v1/chat/completions` and attempts to parse `responseBody['choices'][0]['message']['content']`. Verify Groq's API schema and handle non-200 responses and unexpected JSON shapes robustly.

3. Missing services
	- `lib/core/services/ai_service.dart` and `marketplace_api.dart` are stubs. Move network logic into `AIService` for testability and to centralize retries/error handling.

4. Tests & CI
	- There are no unit/widget tests for the Create flow. Add a widget test that mocks the network call and verifies UI state transitions.

5. Mobile permissions
	- If you run on Android/iOS, add proper microphone permission messages in `AndroidManifest.xml` / `Info.plist`.

## Troubleshooting tips

- Microphone permissions (Windows): enable microphone access in Windows Settings → Privacy → Microphone.
- If `flutter run` fails because desktop support isn't enabled: enable desktop on your Flutter installation: `flutter config --enable-windows-desktop` and ensure Visual Studio is installed.
- If transcription isn't working, ensure `speech_to_text` initializes successfully — check debug console for initialization errors.

## Security & secrets

- `.env` is intentionally listed in `.gitignore`. Never commit your API keys. Use environment-specific secrets management for production.

## Suggested next actions (I can implement)

1. Fix the recorder usage in `voice_recorder_widget.dart` to use the `record` package correctly and guard permission checks.
2. Implement `AIService` in `lib/core/services/ai_service.dart` and move the Groq call there with robust parsing and retries.
3. Add `.env.example` and update this README with a short `CONTRIBUTING.md` snippet.
4. Add widget tests for the Create flow that mock HTTP responses.

If you want, I can implement items (1) and (2) now and run `flutter analyze` to verify — tell me which to start with.

---

Credits: scaffolded from a Flutter project; images and assets are declared in `pubspec.yaml` under `flutter.assets`.

License: none declared.

Enjoy working on VocalCanvas — tell me which fix you'd like me to make next and I will apply it.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
