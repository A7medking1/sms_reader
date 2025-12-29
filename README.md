# 📱 SMS Reader - Flutter Application

A modern, feature-rich SMS reading application built with Flutter that provides an intuitive interface for viewing and searching your text messages with contact name integration.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 📬 Message Management
- **Conversations View**: See all your SMS conversations in one place
- **Chat Screen**: View complete conversation history with any contact
- **Message Types**: Distinguish between sent and received messages
- **Real-time Data**: Access your device's SMS database directly

### 🔍 Advanced Search
- **Contact Search**: Quick search for contacts by name or phone number
- **Text Highlighting**: Visual highlighting of search matches
- **No Duplicates**: Each contact appears only once in search results
- **Search History**: Remembers your last 10 searches
- **Real-time Results**: See results as you type (with intelligent debouncing)

### 🎨 Beautiful UI/UX
- **Material 3 Design**: Modern, clean interface
- **Smooth Animations**: Fade and slide transitions
- **Dark Mode Support**: Adapts to system theme
- **Interactive Elements**: Tap to open conversations, clear searches, etc.
- **Message Count Badges**: See total messages per conversation

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── src/
│   ├── core/
│   │   ├── get_it.dart              # Dependency injection
│   │   ├── helper/
│   │   │   └── helper_fun.dart      # Utility functions
│   │   └── widget/
│   │       └── SearchWidget.dart    # Reusable search widget
│   ├── models/
│   │   ├── models.dart              # SmsMessage, SmsConversation
│   │   └── search_models.dart       # Search-related models
│   ├── services/
│   │   ├── sms_platform_service.dart    # Platform channel communication
│   │   └── contacts_service.dart        # Contact name resolution
│   ├── repository/
│   │   └── sms_repository.dart      # Business logic layer
│   ├── presentation/
│   │   ├── cubit/
│   │   │   ├── conversations_cubit.dart # Conversations state management
│   │   │   ├── chat_cubit.dart          # Chat state management
│   │   │   ├── search_cubit.dart        # Search state management
│   │   │   ├── sms_state.dart           # State classes
│   │   │   └── search_state.dart        # Search state classes
│   │   ├── screen/
│   │   │   ├── sms_list_screen.dart     # Conversations screen
│   │   │   ├── chat_screen.dart         # Individual chat screen
│   │   │   └── search_screen.dart       # Search screen
│   │   └── widget/
│   │       ├── highlighted_text.dart    # Text highlighting widget
│   │       └── search_filters_sheet.dart # Search filters (future)
├── main.dart                        # App entry point
└── plan/
    └── sms_service/                 # Reusable SMS service package
```

### Design Patterns Used
- **BLoC/Cubit Pattern**: State management with flutter_bloc
- **Repository Pattern**: Data abstraction layer
- **Dependency Injection**: Service locator with get_it
- **Platform Channel**: Native Android integration
- **Observer Pattern**: Reactive state updates

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/A7medking1/sms_reader.git
   cd reading_sms
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Main Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.0
  
  # Contacts Integration
  flutter_contacts: ^1.1.9
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🔐 Permissions

The app requires the following permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### Runtime Permissions
The app requests permissions at runtime:
- **READ_SMS**: To access text messages
- **READ_CONTACTS**: To display contact names

## 📖 Usage

### Viewing Conversations
1. Open the app - you'll see a list of all SMS conversations
2. Each conversation shows:
   - Contact name (or phone number)
   - Last message preview
   - Timestamp
   - Message count badge

### Viewing a Chat
1. Tap any conversation to open the full chat
2. Messages are displayed chronologically
3. Sent messages appear on the right
4. Received messages appear on the left
5. Contact name shown in app bar

### Searching for Contacts
1. Tap the search icon in the top-right
2. Start typing a contact name or phone number
3. Results appear in real-time
4. Matching text is highlighted in yellow
5. Tap any result to open the conversation

### Search Features
- **Live Search**: Results update as you type
- **Highlighting**: Search terms highlighted in yellow
- **History**: Recent searches saved for quick access
- **No Duplicates**: Each contact shown once
- **Message Count**: See total messages per contact

## 🎯 Key Features Explained

### Contact Name Resolution
```dart
// Automatically resolves phone numbers to contact names
ContactsService → Fetches contacts from device
                → Normalizes phone numbers
                → Caches results for performance
                → Returns contact name or phone number
```

### Search Algorithm
```dart
// Efficient contact-only search
1. Fetch all conversations
2. Filter by contact name OR phone number
3. Return ONE result per contact
4. Sort by most recent
5. Highlight matches
```

### State Management Flow
```dart
User Action → Cubit Method → Repository Call → Platform Service
                  ↓
            State Updated
                  ↓
         UI Rebuilds Automatically
```

## 🔧 Configuration

### Dependency Injection Setup
Dependencies are registered in `lib/src/core/get_it.dart`:
```dart
final sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton(() => SmsPlatformService());
  sl.registerLazySingleton(() => ContactsService());
  
  // Repository
  sl.registerLazySingleton(() => SmsRepository(
    platformService: sl(),
    contactsService: sl(),
  ));
}
```

### Platform Channel
Native Android code handles SMS access via MethodChannel:
- `getConversations`: Fetch all conversations
- `getSMSByContact`: Get messages for specific contact
- `getSMS`: Get all messages

## 🎨 Customization

### Change Theme Colors
Edit colors in respective screen files:
```dart
// Primary color
Colors.blue

// Highlight color
Colors.yellow.withOpacity(0.5)

// Message bubble colors
// Sent: Colors.blue
// Received: Colors.grey
```

### Modify Search Debounce Time
In `search_screen.dart`:
```dart
_debounce = Timer(const Duration(milliseconds: 500), () {
  // Change 500ms to your preferred delay
});
```

### Adjust Contact Cache
In `contacts_service.dart`, the cache stores contact name lookups for fast retrieval.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| Android  | ✅ Yes    | Fully tested on Android 5.0+ |
| iOS      | ❌ No     | iOS doesn't allow SMS access |
| Web      | ❌ No     | Web doesn't have SMS API |
| Desktop  | ❌ No     | Desktop platforms don't support SMS |

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **flutter_bloc** - For excellent state management
- **flutter_contacts** - For simplifying contact access
- **Material Design** - For beautiful UI components

## 📞 Contact

**Ahmed** - [@A7medking1](https://github.com/A7medking1)

Project Link: [https://github.com/A7medking1/sms_reader](https://github.com/A7medking1/sms_reader)

## 🗺️ Roadmap

Future enhancements planned:

- [ ] Message compose and send functionality
- [ ] Export conversations to PDF/TXT
- [ ] Advanced search filters (date range, type)
- [ ] Conversation threading
- [ ] Message statistics and analytics
- [ ] Backup and restore functionality
- [ ] Multi-language support
- [ ] Custom themes

## ⚡ Performance

- **Fast Loading**: Conversations load in <1 second
- **Smooth Scrolling**: Optimized ListView with caching
- **Efficient Search**: Contact-only search is lightning fast
- **Smart Caching**: Contact names cached for instant lookup
- **Debounced Input**: Prevents excessive search operations

## 🐛 Known Issues

- None currently reported

## 💡 Tips

1. **First Launch**: Grant SMS and Contacts permissions when prompted
2. **Search**: Type slowly for best real-time search experience
3. **Performance**: Clear search history periodically
4. **Contacts**: Ensure contacts are saved on device, not SIM card

---

Made with ❤️ using Flutter
