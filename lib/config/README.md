# API Configuration Setup

## For Development:
1. Copy `api_config.dart.template` to `api_config.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual Gemini API key
3. The `api_config.dart` file is ignored by git for security

## For Production:
1. The build process embeds the API key from `api_config.dart`
2. Never commit the actual `api_config.dart` file to git
3. Use secure environment variables in production environments

## Security Note:
- The `api_config.dart` file is gitignored to prevent API key exposure
- Always use environment variables or secure config management in production
- Consider using a backend proxy for API calls in production applications
