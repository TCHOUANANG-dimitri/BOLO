# BOLO - Services Marketplace

**BOLO** is a Flutter mobile application that connects users with service providers. Find the right professional for all your needs.

## Key Features

### For Users
- **Authentication** - Sign up, login, and OTP verification
- **Home** - Personalized dashboard with recommendations
- **Search** - Advanced search for service providers by category
- **Bookings** - Service booking with integrated payment
- **Messaging** - Real-time communication with providers
- **Reviews & Ratings** - Rate and comment on services
- **Favorites** - Save preferred service providers
- **Profile** - Account management and booking history

### For Service Providers
- **Dashboard** - Overview of activities
- **Request Management** - Accept/decline bookings
- **Wallet** - Track earnings and payments
- **Contract & Verification** - Identity documents and contracts
- **Loyalty Program** - Reward management
- **Messages** - Interaction with customers
- **Registry** - Detailed service history

## Architecture

The application follows a layered architecture:

```
lib/
├── core/                    # Core business logic
│   ├── config/             # Application configuration
│   ├── constants/          # Constants (colors, strings, text styles)
│   ├── services/           # Services (Auth, Firestore, Local DB, etc.)
│   ├── theme/              # Theme and global styles
│   └── utils/              # Utilities
├── data/                    # Data layer
│   ├── models/             # Data models
│   └── repositories/       # Data access
├── presentation/            # Presentation layer
│   ├── providers/          # State management (Provider)
│   ├── screens/            # Screens/Pages
│   └── widgets/            # Reusable widgets
└── router/                 # Navigation (GoRouter)
```

### Tech Stack

- **Framework**: Flutter 3.3.0+
- **State Management**: Provider 6.1.2
- **Navigation**: GoRouter 14.2.7
- **Backend**: Firestore
- **Local Storage**: SharedPreferences + Local Database
- **HTTP Client**: Dio 5.7.0
- **Design**: Material Design + Google Fonts (Poppins)

## Installation

### Prerequisites
- Flutter SDK 3.3.0 or higher
- Dart 3.3.0 or higher
- Git

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/your-repo/bolo.git
cd bolo
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase** (if needed)
   - Download Firebase configuration files
   - Place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. **Generate localized files** (if applicable)
```bash
flutter gen-l10n
```

5. **Run the application**
```bash
flutter run
```

## File Structure

### Core Services
- **auth_service.dart** - Firebase authentication
- **firestore_service.dart** - Firestore operations
- **local_db_service.dart** - Local database
- **payment_service.dart** - Payment integration (Mobile Money)
- **storage_service.dart** - File management

### Data Models
- `user_model.dart` - User
- `provider_model.dart` - Service provider
- `booking_model.dart` - Booking
- `message_model.dart` - Message
- `review_model.dart` - Review
- `category_model.dart` - Category

### Screens
- **auth/** - Authentication (Login, Register, OTP, Welcome)
- **home/** - Home (Home, MainScaffold)
- **search/** - Search and results
- **booking/** - Bookings and payment
- **messages/** - Messaging
- **provider/** - Provider dashboard
- **profile/** - User profile
- **categories/** - Service categories

### Reusable Widgets
- `bolo_button.dart` - Custom button
- `bolo_text_field.dart` - Text field
- `provider_card.dart` - Provider card
- `star_rating.dart` - Rating system
- `category_icon.dart` - Category icon

## Theme & Styling

The application uses a consistent theme defined in `app_theme.dart`:
- **Font**: Poppins (Regular, Medium, SemiBold, Bold)
- **Colors**: Defined in `app_colors.dart`
- **Text**: Centralized styles in `app_text_styles.dart`

## State Management

The application uses **Provider** for state management:
- `AuthProvider` - Authentication and current user
- `HomeProvider` - Home data
- `SearchProvider` - Search and filters
- `BookingProvider` - Bookings
- `MessagesProvider` - Messaging
- `ReviewProvider` - Reviews and ratings

## Navigation

Uses **GoRouter** for web-like navigation:
- Centralized configuration in `app_router.dart`
- Deep linking supported
- Navigation state preservation

## Data Storage

- **Firebase Firestore** - Real-time data
- **SharedPreferences** - User preferences
- **Local Database** - Offline data

## Authentication

- SMS OTP verification
- Identity verification for providers
- Persistent sessions

## Payments

**Mobile Money** integration via Dio for secure transactions.

## Main Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| go_router | 14.2.7 | Navigation |
| provider | 6.1.2 | Global state |
| google_fonts | 6.2.1 | Fonts |
| flutter_svg | 2.0.10 | SVG images |
| dio | 5.7.0 | HTTP requests |
| cached_network_image | 3.4.1 | Image caching |
| intl | 0.19.0 | Internationalization |
| shared_preferences | 2.3.2 | Local storage |

## Useful Commands

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run linter
flutter pub run custom_lint

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

## Code Conventions

- Use **camelCase** for variables and functions
- Use **PascalCase** for classes
- Organize imports: dart, flutter, external packages, local files
- Comments in English, be consistent
- One widget = one file

## Debugging

```dart
// Use the logger
debugPrint('Debug message');

// Profile performance
DevTools.launch();
```

## Supported Orientations

The application supports portrait orientations only (portrait and reverse portrait).

## Versioning

Current version: **1.0.0+1**

## License

All rights reserved BOLO.

## Support

For any questions or issues, please contact the development team.

---

Built with dedication to connect users and service providers.
