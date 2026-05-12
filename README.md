# Folio

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A beautiful, minimalist cross-platform document reader for Android and iOS — built with Flutter.

Open PDF, Word (DOCX), PowerPoint (PPTX), and Excel (XLSX) files with a clean, distraction-free experience designed around scientific design principles.

---

## Tech Stack

### Core Framework

| Layer | Choice | Reason |
|---|---|---|
| Framework | **Flutter 3.41** (stable) | Impeller renderer gives pixel-perfect, identical UI on Android and iOS |
| Language | **Dart 3.11** | Null-safe, strong-typed, fast compile |
| Project scaffold | **Very Good CLI** | Enforces structure, includes CI/lint, multi-flavor setup |

### State & Navigation

| Layer | Package | Why |
|---|---|---|
| State | **BLoC / Cubit** (`flutter_bloc`) | Predictable, testable, event-driven — matches VGC scaffold conventions |
| Navigation | **go_router** | Declarative, deep-link ready, URL-based routing |

### Document Rendering

| Format | Package | Notes |
|---|---|---|
| PDF | **syncfusion_flutter_pdfviewer** | Best-in-class rendering, free community license, text selection, bookmarks |
| PPTX / DOCX / XLSX | **open_filex** | Delegates to the system viewer on-device — no server required |
| File picking | **file_picker** | Cross-platform, multi-format support |

### Storage

| Layer | Package |
|---|---|
| Recent files + metadata | **shared_preferences** (JSON-serialised) |
| File paths | **path_provider** |

### Design System

| Layer | Package | Principle |
|---|---|---|
| Theme engine | **flex_color_scheme** (Material 3) | Adaptive themes, dynamic color seeding |
| Typography | **google_fonts** (Inter) | Proven readability, humanist sans-serif |
| Animations | **flutter_animate** | Physics-based micro-interactions |
| Utilities | **equatable**, **uuid** | Value equality, unique IDs |

---

## Design Principles

Every design decision in Folio is grounded in cognitive science and visual design research.

### Color & Contrast
- **60-30-10 rule**: 60% background, 30% surface, 10% accent (indigo `#6366F1`)
- **WCAG AA compliance**: all text meets 4.5:1 contrast ratio minimum
- **OLED-first dark mode**: true near-black (`#0A0A0B`) backgrounds save battery and reduce eye strain

### Typography
- **Inter** — a humanist sans-serif designed for screen readability at small sizes
- **Perfect fourth scale (×1.333)** anchored at 16px: 12 → 14 → 16 → 18 → 20 → 24 → 30 → 36 → 48
- Tight letter-spacing (−0.3 to −1.5) on display sizes reduces visual noise
- Line height 1.6 on body text — the scientifically optimal range for reading comprehension

### Spacing
- **8px base grid** throughout: every spacing value is a multiple of 8 (or 4 for micro-adjustments)
- **Golden ratio inflection points** at 24px → 40px → 64px create natural visual rhythm
- Generous whitespace around cards and sections reduces cognitive load (Miller's Law)

### Interaction
- **Fitts's Law**: all primary actions have a minimum 48dp touch target
- **Hick's Law**: the main screen presents ≤ 2 primary actions to minimise decision time
- **Progressive disclosure**: metadata (file size, date) is secondary; document name dominates
- **Gestalt proximity**: related controls are tightly grouped; unrelated elements have generous gaps

### Motion
- Enter animations: `easeOutCubic` at 300ms — fast start, graceful finish
- Exit animations: `easeInCubic` at 200ms — responsive, not lingering
- Staggered list items (40ms delay per card) guide the eye down the list naturally
- Toolbar slide uses `easeOutCubic` / `easeInCubic` to feel physical, not mechanical

---

## Project Structure

```
lib/
├── app/
│   └── view/app.dart              # Root widget — theme + router wiring
├── core/
│   ├── models/
│   │   └── document.dart          # Document model + DocumentType enum
│   ├── router/
│   │   └── app_router.dart        # go_router config + navigation helpers
│   ├── services/
│   │   └── document_service.dart  # File picking + recent-files persistence
│   └── theme/
│       ├── app_colors.dart        # Full color palette (dark + light)
│       ├── app_spacing.dart       # Spacing scale + radii constants
│       ├── app_theme.dart         # ThemeData for dark + light modes
│       └── app_typography.dart    # Inter type scale
├── features/
│   ├── home/
│   │   ├── cubit/                 # HomeCubit — recent files, search, pick
│   │   ├── view/                  # HomePage + HomeView
│   │   └── widgets/               # DocumentCard, EmptyState
│   ├── reader/
│   │   ├── cubit/                 # ReaderCubit — page, toolbar, zoom
│   │   ├── view/                  # ReaderPage + ReaderView
│   │   └── widgets/               # ReaderToolbar, ReaderProgressBar
│   └── settings/
│       ├── cubit/                 # SettingsCubit — theme mode persistence
│       └── view/                  # SettingsPage
└── l10n/                          # Localisation strings (en, es)
```

---

## Getting Started

### Prerequisites

- Flutter 3.41+ (`flutter --version`)
- Dart 3.11+
- Android SDK (for Android) / Xcode (for iOS)

### Install

```sh
git clone https://github.com/thor1033/folio.git
cd folio
flutter pub get
```

### Run

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

### Test

```sh
# Unit + widget tests with randomised ordering
very_good test --coverage --test-randomize-ordering-seed random

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/

# BLoC lint
dart run bloc_tools:bloc lint .
```

### Build

```sh
# Android APK
flutter build apk --flavor production --target lib/main_production.dart

# iOS (requires macOS + Xcode)
flutter build ios --flavor production --target lib/main_production.dart
```

---

## Localisation

This project uses Flutter's official ARB-based i18n. Supported locales: **English**, **Spanish**.

```sh
# Regenerate after editing .arb files
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

---

## Roadmap

- [ ] Inline PPTX / DOCX rendering (no external viewer)
- [ ] Bookmarks and annotations on PDFs
- [ ] Isar database for advanced recent-file metadata
- [ ] Full-text search within PDFs
- [ ] iCloud / Google Drive integration
- [ ] Tablet / iPad split-view layout

---

## License

MIT © Thor Simonsen

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
