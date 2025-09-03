# NaviVoice - Voice-Guided Navigation App

NaviVoice is a Flutter-based mobile navigation application that provides intelligent voice-guided directions with customizable voice packs and advanced mapping capabilities powered by Mapbox.

## 🌟 Features

### Core Navigation
- **Real-time Navigation**: Turn-by-turn directions with live traffic updates
- **Voice Guidance**: Clear, natural voice instructions during navigation
- **Multi-platform Support**: Available for both Android and iOS devices
- **Offline Maps**: Continue navigation even without internet connectivity

### Voice Features
- **Custom Voice Packs**: Choose from multiple voice personalities (Bill, Lily, Drew, Molly)
- **AI-Powered Voices**: Integration with ElevenLabs for high-quality synthetic voices
- **Professional & Character Voices**: Mix of professional navigation voices and fun character options
- **Premium Voice Packs**: Access to additional high-quality voices for enhanced experience
- **Text-to-Speech**: Advanced TTS capabilities with natural pronunciation
- **Voice Ratings**: Community-rated voice packs with download statistics

### User Experience
- **User Authentication**: Secure login and signup with phone verification
- **Profile Management**: Customize preferences and save favorite locations
- **Recent Trips**: Track and revisit your navigation history
- **Search Integration**: Find places with intelligent search powered by Mapbox
- **Modern UI**: Clean, intuitive interface with Google Fonts and custom icons

### Technical Features
- **Location Services**: Precise GPS tracking and geolocation
- **Route Optimization**: Multiple routing options and traffic-aware directions
- **Map Integration**: High-quality maps with satellite and street views
- **Audio Playback**: Seamless audio experience with just_audio
- **State Management**: Efficient app state handling with Provider pattern

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **Maps & Navigation**: Mapbox Maps Flutter, Mapbox Search
- **Voice & Audio**: Flutter TTS, Just Audio, ElevenLabs API
- **Location**: Geolocator
- **State Management**: Provider
- **UI Components**: Material Design, Google Fonts, Font Awesome
- **Network**: Dio, HTTP
- **Environment**: Flutter DotEnv

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **Git**

### Development Environment Setup

1. Install Flutter: Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install)
2. Verify installation: `flutter doctor`
3. Set up your IDE with Flutter and Dart plugins

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/LDrago-zae/navi_voice_app.git
cd navi_voice_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the root directory with the following variables:

```env
MAP_BOX_ACCESS_TOKEN=your_mapbox_public_token_here
ELEVEN_LABS_API_KEY=your_eleven_labs_api_key_here
```

**Required API Keys:**
- **Mapbox Access Token**: Sign up at [Mapbox](https://www.mapbox.com/) and get your public access token
- **ElevenLabs API Key**: Create an account at [ElevenLabs](https://elevenlabs.io/) for AI voice generation

### 4. Platform-Specific Setup

#### Android
- Minimum SDK: Check `android/app/build.gradle`
- Add location permissions in `android/app/src/main/AndroidManifest.xml`
- Configure Mapbox SDK in your Android app

#### iOS
- Minimum iOS version: Check `ios/Runner.xcodeproj`
- Add location permissions in `ios/Runner/Info.plist`
- Configure Mapbox SDK for iOS

### 5. Run the Application
```bash
# For development
flutter run

# For release build
flutter build apk  # Android
flutter build ios  # iOS
```

## 📱 Usage

### Getting Started
1. **Launch the App**: Open NaviVoice on your device
2. **Create Account**: Sign up with phone verification or log in
3. **Grant Permissions**: Allow location and microphone access
4. **Choose Voice Pack**: Select your preferred navigation voice
5. **Start Navigating**: Search for destinations and begin voice-guided navigation

### Main Features
- **Search**: Tap the search button to find destinations
- **Navigate**: Get turn-by-turn directions with voice guidance
- **Profile**: Customize settings and manage your account
- **Voice Packs**: Switch between different voice personalities
- **Recent Trips**: View your navigation history

## 🏗️ Architecture

NaviVoice follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── main.dart                 # Application entry point
├── constants/               # App constants and configurations
├── controllers/            # Business logic controllers
│   ├── location_controller.dart
│   └── map_controller.dart
├── models/                 # Data models
│   ├── location_model.dart
│   ├── voice_pack.dart
│   └── ...
├── services/               # External services and APIs
│   ├── mapbox_service.dart
│   ├── navigation_tts.dart
│   ├── eleven_labs_service.dart
│   └── ...
├── views/                  # UI screens and widgets
│   ├── login_screen.dart
│   ├── map_page.dart
│   ├── home_page.dart
│   └── widgets/
└── utils/                  # Utility functions and helpers
```

### Key Components
- **Controllers**: Handle business logic and state management
- **Services**: Interface with external APIs and device features
- **Models**: Define data structures and entities
- **Views**: Implement user interface screens and widgets
- **Utils**: Provide helper functions and utilities

## 🧪 Testing

Run the test suite to ensure everything is working correctly:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `mapbox_maps_flutter`: Map rendering and navigation
- `mapbox_search`: Location search functionality
- `flutter_tts`: Text-to-speech capabilities
- `geolocator`: Location services
- `provider`: State management

### UI Dependencies
- `google_fonts`: Custom typography
- `font_awesome_flutter`: Icon library
- `google_nav_bar`: Bottom navigation
- `flutter_svg`: SVG image support

### Utility Dependencies
- `dio`: HTTP client for API requests
- `just_audio`: Audio playback
- `flutter_dotenv`: Environment variables
- `http`: Additional HTTP support

## 🤝 Contributing

We welcome contributions to NaviVoice! Please follow these steps:

### Getting Started
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following our coding standards
4. Add tests for new functionality
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style
- Follow Dart's official style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure proper formatting with `dart format`
- Run `flutter analyze` before submitting

### Testing
- Write unit tests for new features
- Ensure all existing tests pass
- Add integration tests for UI changes
- Test on both Android and iOS platforms

## 📝 Changelog

### Version 1.0.0+2 (Current)
- Initial release with core navigation features
- Mapbox integration for maps and routing
- Voice guidance with custom voice packs
- User authentication and profile management
- ElevenLabs AI voice integration

## 🐛 Known Issues

- Voice pack loading may take time on first launch
- Some voices may not be available in all regions
- GPS accuracy depends on device capabilities

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Mapbox](https://www.mapbox.com/) for excellent mapping services
- [ElevenLabs](https://elevenlabs.io/) for AI voice technology
- [Flutter Team](https://flutter.dev/) for the amazing framework
- Open source community for various packages and tools

## 📞 Support

For support, questions, or feature requests:
- Create an issue on GitHub
- Contact the development team
- Check the documentation and FAQ

---

**NaviVoice** - Making navigation more personal with intelligent voice guidance 🗺️🎙️
