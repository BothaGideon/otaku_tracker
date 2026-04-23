# Otaku Tracker

A modern Flutter application that provides a revamped user interface for MyAnimeList (MAL), allowing users to track their anime watching progress, browse seasonal anime, and manage their personal anime lists.

## Features

- **Anime Tracking**: View and manage your personal anime list with status updates (watching, completed, on-hold, etc.)
- **Seasonal Browse**: Discover anime from current and previous seasons with detailed information
- **User Authentication**: Secure OAuth2 login with MyAnimeList accounts
- **Responsive Design**: Material Design 3 UI with dark theme support
- **Deep Linking**: Support for external links to anime details
- **Horizontal Carousels**: Intuitive browsing of anime collections

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.4.3 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- A MyAnimeList account

## Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/otaku-tracker.git
   cd otaku-tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Get MyAnimeList API Credentials:**

   - Visit [MyAnimeList API](https://myanimelist.net/apiconfig)
   - Create a new application
   - Note down your Client ID

4. **Configure API Key:**

   The app requires a MyAnimeList API key to be set as an environment variable during build time. Use the `--dart-define` flag when running or building the app:

   ```bash
   flutter run --dart-define=MALAPI=your_mal_client_id_here
   ```

   Or for building:

   ```bash
   flutter build apk --dart-define=MALAPI=your_mal_client_id_here
   flutter build ios --dart-define=MALAPI=your_mal_client_id_here
   ```

   **Security Note:** Never commit your API key to version control. Consider using a `.env` file with a tool like `flutter_dotenv` for local development if preferred, but the app currently uses `String.fromEnvironment()` for build-time configuration.

5. **Run the app:**

   For Android:
   ```bash
   flutter run --dart-define=MALAPI=your_mal_client_id_here
   ```

   For iOS:
   ```bash
   flutter run --dart-define=MALAPI=your_mal_client_id_here
   ```

   For web (limited functionality):
   ```bash
   flutter run -d chrome --dart-define=MALAPI=your_mal_client_id_here
   ```

## Project Structure

```
lib/
├── constants/          # App constants and routes
├── models/            # Data models (Anime DTOs)
├── pages/             # Main app pages (Landing, My List, Seasonal)
├── providers/         # Riverpod state providers
├── services/          # API services (OAuth, Anime List, Seasonal)
└── widgets/           # Reusable UI components
```

## Key Dependencies

- **flutter_riverpod**: State management
- **jikan_api**: MyAnimeList API wrapper
- **oauth2**: OAuth2 authentication
- **http**: HTTP requests
- **flutter_web_auth_2**: Web-based authentication
- **carousel_slider**: Horizontal scrolling carousels
- **flutter_animate**: Animations

## API Usage

The app integrates with the official MyAnimeList API v2:

- **Authentication**: OAuth2 flow for user login
- **Anime Data**: Fetching seasonal anime lists and user lists
- **Rate Limits**: Respects MAL API rate limits (typically 60 requests/minute)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is private and not intended for public distribution.

## Support

For issues or questions, please create an issue in the repository.
