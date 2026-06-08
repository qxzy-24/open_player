<p align="center">
  <img src="https://img.icons8.com/3d-fluency/256/headphones.png" width="120" alt="Open Player Logo" />
</p>

<h1 align="center">Open Player</h1>

<p align="center">
  <strong>A premium, cross-platform music player built with Flutter</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-8B5CF6?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge" alt="License" />
</p>

---

## ✨ Overview

**Open Player** is a beautifully designed, feature-rich music player that scans your device for audio files and delivers a premium listening experience. Built entirely with Flutter, it runs natively on Android, iOS, Windows, macOS, Linux, and Web — all from a single codebase.

The UI features a deep violet and cyan dark theme with glassmorphism effects, smooth micro-animations, and a polished Material 3 design system powered by Google Fonts (Inter).

---

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 🎶 **Music Library** | Automatically scans your device for audio files. Browse by **Songs**, **Albums**, **Artists**, or **Favorites** using tabbed navigation. |
| 🎧 **Now Playing** | Full-screen player with album artwork, animated seek bar, buffered position indicator, and glow effects. |
| ♥ **Favorites** | One-tap favorites with heart animations. Quickly access your favorite tracks in a dedicated tab. |
| 🔀 **Shuffle & Repeat** | Three repeat modes (off, all, one) and intelligent shuffle that keeps the current song first. |
| 🔎 **Search** | Debounced real-time search across song titles, artists, and album names. |
| 📱 **Mini Player** | Persistent compact player bar at the bottom with progress indicator and slide-up transition to the full player. |
| 🎨 **Premium Dark Theme** | Deep violet/cyan palette with smooth gradients, glow shadows, and Inter typography. |
| 📂 **Album & Artist Drill-down** | Tap any album or artist to explore their songs in a draggable bottom sheet. |
| ⚙️ **Settings** | Configurable playback options including gapless playback and crossfade (UI ready). |
| 🔐 **Smart Permissions** | Handles Android 13+ audio permissions with fallback to legacy storage permission. |

---

## 📸 Screenshots

> Screenshots will be added after the first production build.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.11+**
- Android Studio or VS Code with Flutter/Dart extensions
- A physical device (recommended for audio playback testing)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/qxzy-24/open_player.git
cd open_player

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device
flutter run
```

### Platform-Specific Notes

| Platform | Notes |
|----------|-------|
| **Android** | Grant storage/audio permission when prompted on first launch. Supports Android 5.0+ (API 21+). |
| **iOS** | Requires media library permission. Must be tested on a physical device. |
| **Windows / macOS / Linux** | No special permissions needed. Plays audio files from the local filesystem. |
| **Web** | Limited functionality — no filesystem access for music scanning. |

---

## 🏗️ Architecture

Open Player follows a clean, layered architecture using the **Provider** pattern for state management:

```
lib/
├── main.dart                         # App entry + provider setup
│
├── models/
│   ├── song_model.dart               # Song data model with factory from SongModel
│   └── playlist_model.dart           # Playlist with computed duration
│
├── services/
│   ├── audio_service.dart            # Audio playback engine (just_audio wrapper)
│   │                                 # Queue management, shuffle, loop, position streams
│   └── music_library_service.dart    # Device music scanning + permissions
│
├── providers/
│   ├── player_provider.dart          # Playback state (ChangeNotifier)
│   ├── library_provider.dart         # Library state, search, favorites
│   └── progress_provider.dart        # High-frequency position/duration updates
│
├── screens/
│   ├── home_screen.dart              # App shell with bottom nav + mini player
│   ├── library_screen.dart           # Tabbed library (Songs/Albums/Artists/Favs)
│   ├── now_playing_screen.dart       # Full-screen player with Hero transitions
│   └── settings_screen.dart          # App settings and about info
│
├── widgets/
│   ├── album_art.dart                # Album artwork with gradient fallback
│   ├── song_tile.dart                # Rich song list item with animations
│   └── mini_player.dart              # Persistent bottom player bar
│
└── theme/
    └── app_theme.dart                # Complete dark theme + design tokens
```

### Design Patterns

- **Provider + Selector** — Fine-grained rebuilds using `Selector` widgets to avoid unnecessary re-renders
- **Proxy Provider** — `ProgressProvider` is injected into `PlayerProvider` for efficient high-frequency updates
- **Service Layer** — Business logic separated from UI in dedicated service classes
- **Hero Transitions** — Album art animates seamlessly between mini player and now playing screen
- **Debounced Search** — 300ms debounce timer prevents excessive filtering during typing

---

## 🧰 Tech Stack

| Package | Version | Purpose |
|---------|---------|---------|
| [`just_audio`](https://pub.dev/packages/just_audio) | ^0.9.40 | High-performance audio playback engine |
| [`on_audio_query`](https://pub.dev/packages/on_audio_query) | ^2.9.0 | Device music library scanning and artwork |
| [`provider`](https://pub.dev/packages/provider) | ^6.1.2 | Reactive state management |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | ^6.2.1 | Premium typography (Inter font family) |
| [`audio_video_progress_bar`](https://pub.dev/packages/audio_video_progress_bar) | ^2.0.3 | Customizable seek bar widget |
| [`rxdart`](https://pub.dev/packages/rxdart) | ^0.28.0 | Stream combining for position data |
| [`permission_handler`](https://pub.dev/packages/permission_handler) | ^11.3.1 | Runtime permission management |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.3.3 | Local key-value storage |
| [`path_provider`](https://pub.dev/packages/path_provider) | ^2.1.4 | Platform-specific file paths |

---

## 🎨 Design System

Open Player uses a curated color palette and design tokens defined in [`app_theme.dart`](lib/theme/app_theme.dart):

| Token | Value | Usage |
|-------|-------|-------|
| `primaryColor` | `#8B5CF6` | Vivid violet — buttons, active states |
| `accentColor` | `#22D3EE` | Cyan — secondary highlights |
| `accentWarm` | `#F472B6` | Pink — favorite hearts |
| `bgDark` | `#0F0F1A` | Deep navy-black background |
| `bgCard` | `#1A1A2E` | Card surfaces |
| `bgElevated` | `#252542` | Elevated surfaces (mini player) |

Gradients, glow shadows, and glassmorphism overlays are used throughout for a premium feel.

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow the existing code architecture (services → providers → widgets)
- Use `Selector` instead of `Consumer` for performance-critical widgets
- Keep the dark theme consistent — use `AppTheme` constants, never hardcode colors
- Add doc comments to all public APIs

---

## 📋 Roadmap

- [ ] Persistent favorites with `shared_preferences`
- [ ] Playlist creation and management
- [ ] Equalizer integration
- [ ] Background audio with notification controls
- [ ] Theme customization (multiple color palettes)
- [ ] Lock screen widget
- [ ] Sleep timer

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ♥ using <a href="https://flutter.dev">Flutter</a>
</p>
