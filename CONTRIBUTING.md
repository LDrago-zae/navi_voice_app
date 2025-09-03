# Contributing to NaviVoice

Thank you for your interest in contributing to NaviVoice! This document provides guidelines and information for contributors.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/navi_voice_app.git
   cd navi_voice_app
   ```
3. **Set up the development environment** (see README.md)
4. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📋 Development Guidelines

### Code Style
- Follow Dart's official [style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Format code with `dart format` before committing
- Run `flutter analyze` to check for issues

### Commit Messages
Use clear and descriptive commit messages:
- `feat: add voice pack selection feature`
- `fix: resolve GPS accuracy issue`
- `docs: update installation instructions`
- `refactor: improve navigation service structure`

### Pull Request Process
1. **Update documentation** if you've made changes to public APIs
2. **Add or update tests** for new functionality
3. **Ensure all tests pass**: `flutter test`
4. **Update the README** if needed
5. **Create a detailed pull request** describing your changes

### Testing
- Write unit tests for new features: `test/`
- Test on both Android and iOS platforms
- Ensure existing functionality isn't broken
- Test with different voice packs and navigation scenarios

## 🐛 Bug Reports

When reporting bugs, please include:
- **Device information** (OS, version, device model)
- **App version** and build number
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Screenshots or logs** if applicable

## 💡 Feature Requests

For new features:
- **Check existing issues** to avoid duplicates
- **Describe the use case** and why it's needed
- **Provide mockups** or detailed descriptions if possible
- **Consider the impact** on existing functionality

## 🔧 Development Setup

### Prerequisites
- Flutter SDK (3.8.1+)
- Android Studio or VS Code
- Git

### Environment Setup
1. Copy `.env.example` to `.env`
2. Add your API keys (see README.md for details)
3. Run `flutter pub get`
4. Run `flutter run` to start development

### Project Structure
- `lib/` - Main application code
- `test/` - Unit and widget tests
- `android/` - Android-specific code
- `ios/` - iOS-specific code
- `assets/` - Images, icons, and other assets

## 📞 Questions?

- Create an issue for bugs or feature requests
- Start a discussion for general questions
- Check existing documentation first

## 🙏 Thank You

Every contribution helps make NaviVoice better for everyone. Whether it's code, documentation, bug reports, or feature suggestions, we appreciate your help!