# Open Player 🎵

A premium, feature-rich music player built with Flutter. Beautiful dark UI with smooth animations and full playback controls.

## Features

- 🎶 **Music Library** — Scans your device for audio files with Songs, Albums, Artists, and Favorites tabs
- 🎧 **Now Playing** — Full-screen player with album art, seek bar, and glow effects
- ♥ **Favorites** — One-tap favorites for quick access to your best tracks
- 🔀 **Shuffle & Repeat** — Shuffle queue, repeat one, or repeat all modes
- 🔎 **Search** — Instantly filter songs by title, artist, or album
- 🎨 **Premium Dark Theme** — Deep violet/cyan palette with glassmorphism and micro-animations
- 📱 **Mini Player** — Persistent compact player bar with slide-up transition

## Screenshots

_Coming soon_

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11+)
- Android Studio / VS Code with Flutter extensions

### Installation

```bash
# Clone the repo
git clone <your-repo-url>
cd open_player

# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### Android Setup
The app requires storage permission to access music files. Grant it when prompted on first launch.

### Platforms
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web (limited — no file system access)

## Architecture

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── song_model.dart          # Song data model
│   └── playlist_model.dart      # Playlist data model
├── services/
│   ├── audio_service.dart       # Audio playback engine
│   └── music_library_service.dart # Device music scanning
├── providers/
│   ├── player_provider.dart     # Playback state management
│   └── library_provider.dart    # Library state management
├── screens/
│   ├── home_screen.dart         # Main shell + bottom nav
│   ├── library_screen.dart      # Music library with tabs
│   ├── now_playing_screen.dart  # Full-screen player
│   └── settings_screen.dart     # App settings
├── widgets/
│   ├── album_art.dart           # Album artwork display
│   ├── song_tile.dart           # Song list item
│   └── mini_player.dart         # Compact player bar
└── theme/
    └── app_theme.dart           # Dark theme & design tokens
```

## Tech Stack

| Package | Purpose |
|---------|---------|
| `just_audio` | Audio playback engine |
| `on_audio_query` | Device music library scanning |
| `provider` | State management |
| `google_fonts` | Premium typography (Inter) |
| `audio_video_progress_bar` | Seek bar widget |
| `rxdart` | Stream combining |
| `permission_handler` | Runtime permissions |

## License

Open source — feel free to use and modify.
