<p align="center">
  <img src="https://img.icons8.com/3d-fluency/256/headphones.png" width="120" alt="Violet Logo" />
</p>

<h1 align="center">Violet</h1>

<p align="center">
  <strong>A premium, glassmorphic music streaming & playback experience built with Flutter</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#performance-optimizations">Performance Optimizations</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#design-system">Design System</a> •
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

**Violet** is an ultra-premium, glassmorphic music player designed for modern audiophiles. It scans your local storage for audio files and delivers an immersive playback experience wrapped in an elegant bento-grid user interface. Built with Flutter, Violet compiles to high-performance native binaries for Android, iOS, Windows, macOS, Linux, and Web from a single codebase.

The interface is driven by a deep space palette utilizing premium glassmorphism, dynamic glowing shadows, smooth transitions, and high-frequency UI optimizations to maintain a locked 60/120 FPS frame budget.

---

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 🎶 **Music Library** | Automatically queries device audio with background scanning. Browse by **Songs**, **Albums**, **Artists**, or **Favorites** using a tabbed glassmorphism interface. |
| 🎛️ **10-Band Graphic Equalizer** | Professional built-in equalizer supporting presets like Flat, Rock, Pop, Jazz, and Bass Boost for tailored acoustics. |
| 🎧 **Advanced Playback Flow** | Fully configurable playback settings with support for gapless playback and customizable crossfade durations. |
| ⏱️ **Integrated Sleep Timer** | Set automated sleep shutdown timers (15m, 30m, 45m, 60m) that gently fade out and pause playback. |
| 🔀 **Smart Shuffle & Repeat** | Intelligent queues with repeat (off, all, one) and shuffle modes that prioritize user-selected tracks. |
| 🔎 **Real-time Search** | Extremely fast 300ms debounced search filtering song titles, artist profiles, and album names instantly. |
| 📱 **Adaptive Mini Player** | Persistent bottom player with sliding transition, interactive controls, and progress indication. |
| 📂 **Bento-Grid Navigation** | Modern dashboard widgets including dedicated **Folders**, **Queue**, and **Settings** layouts. |
| 🔐 **Android 13+ Permissions** | Seamless storage and audio permission negotiation with clean runtime fallback handlers. |

---

## 🏗️ Architecture

Violet follows a clean, decoupled architecture utilizing the **Provider** pattern for fine-grained state management:

```
lib/
├── main.dart                         # Entry point + App bootstrapping
│
├── core/
│   ├── constants/
│   │   └── design_tokens.dart        # Global sizing, durations, and curves
│   └── theme/
│       └── app_theme.dart            # Premium dark glass theme definition
│
├── models/
│   ├── song_model.dart               # Audio metadata structure
│   └── playlist_model.dart           # User playlists and dynamic queue models
│
├── services/
│   ├── audio_service.dart            # Wraps just_audio, managing background audio session
│   ├── music_library_service.dart    # Device music directory scans and indexing
│   └── storage_service.dart          # Local cache for settings and state persistence
│
├── providers/
│   ├── player_provider.dart          # Low-frequency playback control (track changes, state)
│   ├── progress_provider.dart        # Fine-grained high-frequency updates (seek tracking)
│   ├── library_provider.dart         # Music library caching, favorites, and history
│   └── settings_provider.dart        # Application-wide settings and sleep timer control
│
├── screens/
│   ├── home_screen.dart              # Main shell containing bottom nav & mini player
│   ├── library_screen.dart           # Tabbed lists of tracks, artists, and albums
│   ├── folders_screen.dart           # Local folder browser
│   ├── queue_screen.dart             # Live playback queue manager
│   ├── search_screen.dart            # Debounced filter interface
│   ├── settings_screen.dart          # Audio engine configuration bento card grid
│   └── now_playing_screen.dart       # Ultra-premium visualization screen with hero artwork
│
└── widgets/
    ├── album_art.dart                # Cached album covers with fallback gradients
    ├── song_tile.dart                # Animated song list items
    ├── floating_nav_bar.dart         # Premium navigation bar with glow highlights
    └── glass_card.dart               # Glassmorphic containers with real-time blurs
```

---

## ⚡ Performance Optimizations

### 1. Fine-Grained ChangeNotifier Split
To maintain a butter-smooth 60/120 FPS UI, high-frequency position ticks (~200ms) are isolated to `ProgressProvider`, while player state changes (play, pause, track changes) reside in `PlayerProvider`. Using targeted `Selector` widgets instead of monolithic `Consumer` builds, we prevent redundant rebuilds of the entire widget tree on every tick.

### 2. Search Debouncing
Text queries are throttled with a 300ms debounce window. This eliminates unnecessary list filtering operations on every keystroke, improving input responsiveness and reducing battery drain during search.

### 3. Caching & Memory Profiling
Album artwork requests are optimized using the platform’s native query buffer. Lists are rendered using viewport-aware recycler views (`ListView.builder`, `GridView.builder`) to minimize GPU memory consumption on massive library scans.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.11.0+**
- [Dart SDK](https://dart.dev/get-started) **3.11.0+**
- A connected device or emulator (Android API 21+ / iOS 12.0+ / Windows 10+)

### Installation
```bash
# 1. Clone the repository
git clone https://github.com/qxzy-24/open_player.git

# 2. Install package dependencies
flutter pub get

# 3. Compile and launch the application
flutter run
```

---

## 🎨 Premium Design System

Violet's UI is customized in [`app_theme.dart`](lib/core/theme/app_theme.dart):
- **Primary Color:** `#D0BCFF` (Soft Violet)
- **Secondary Color:** `#C4C1FB` (Sleek Cyan-Blue)
- **Background Base:** `#12121D` (Deep Space Dark)
- **Elevated Surfaces:** `#292935` (Translucent Bento Cards)

Real-time Gaussian blurs (`ImageFilter.blur`) and customizable gradients deliver premium visual feedback.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
