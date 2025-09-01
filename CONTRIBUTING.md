# Contributing to VocalCanvas 🎨

Thank you for your interest in contributing to VocalCanvas! We welcome contributions from developers who want to help empower local artisans through voice-first technology.

## 🚀 Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/your-username/VocalCanvas.git
   cd VocalCanvas
   ```
3. **Set up** your development environment following the README.md
4. **Create** a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🛠️ Development Setup

1. Install Flutter SDK (3.7.2+)
2. Run `flutter pub get` to install dependencies
3. Copy `.env.example` to `.env` and add your API keys
4. Run `flutter analyze` to check for issues
5. Test with `flutter run -d chrome` or your preferred platform

## 📝 Code Guidelines

### **Style & Formatting**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Run `flutter analyze` and fix all warnings

### **Naming Conventions**
- Use descriptive variable and function names
- Follow camelCase for variables and functions
- Use PascalCase for classes and widgets
- Add comments for complex logic

### **Architecture**
- Follow the existing folder structure under `lib/`
- Keep UI logic in `presentation/` layer
- Business logic goes in `core/services/`
- Data models in `data/models/`

## 🌐 Internationalization

VocalCanvas supports multiple languages (English, Hindi, Kannada):

- Add new strings to `assets/lang/en.json` first
- Use `tr('key_name')` for translatable strings in UI
- Test language switching functionality
- Ensure cultural appropriateness of content

## 🧪 Testing

- Write unit tests for new business logic
- Add widget tests for new UI components
- Test on multiple platforms (web, mobile, desktop)
- Test voice recording and AI generation features

## 🎯 Areas for Contribution

### **High Priority**
- [ ] Unit and widget test coverage
- [ ] Error handling improvements
- [ ] Performance optimizations
- [ ] Accessibility features

### **New Features**
- [ ] Advanced AI features with Gemini Vision
- [ ] Social features (comments, following)
- [ ] Analytics dashboard
- [ ] Marketplace integration
- [ ] Offline mode support

### **UI/UX Improvements**
- [ ] Animation and micro-interactions
- [ ] Better loading states
- [ ] Responsive design enhancements
- [ ] Dark mode refinements

## 🐛 Bug Reports

When reporting bugs, please include:
- Flutter version (`flutter --version`)
- Platform (Windows, Android, iOS, Web)
- Steps to reproduce
- Expected vs actual behavior
- Console logs if available

## 💡 Feature Requests

For new features:
- Check existing issues first
- Describe the problem it solves
- Consider impact on artisan users
- Suggest implementation approach

## 📱 Testing Voice Features

When working on voice-related features:
- Test with different accents and languages
- Verify microphone permissions work correctly
- Test audio quality on different devices
- Ensure AI content generation is appropriate

## 🔍 Code Review Process

1. Ensure all tests pass
2. Update documentation if needed
3. Create a pull request with clear description
4. Respond to feedback promptly
5. Squash commits before merging

## 🤝 Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Focus on solutions, not problems
- Remember we're building for artisans worldwide

## 📞 Getting Help

- **Issues**: [GitHub Issues](https://github.com/Sakshamyadav15/VocalCanvas/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Sakshamyadav15/VocalCanvas/discussions)
- **Documentation**: Check the main README.md

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special thanks for innovative features

---

**Thank you for helping make VocalCanvas better for artisans everywhere! 🎨**
