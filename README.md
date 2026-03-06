# TripReady

A personal travel planner for Windows, Linux, and Android — built with Flutter 3.41.2 and Dart 3.11.0. All data is stored locally on-device using SQLite. No accounts, no cloud, no ads.

---

## Features

- **Trips** — Create and manage trips with status tracking (Active / Planned / Archived). Multi-destination routes with departure, stops, and optional return destination.
- **Packing Lists** — Per-trip packing with categories, storage places, quantities, and progress tracking. Import/export via Excel. Save and load reusable templates.
- **Tasks** — Per-trip task manager with Pending / In Progress / Done workflow and due dates
- **Expenses** — Receipt tracking with multi-currency support and category breakdowns
- **Documents** — Attach and organise trip-related files (tickets, visas, vouchers, etc.)
- **Addresses** — Save hotels, restaurants, landmarks and other locations per trip. Search and pin places on an interactive map. View all saved places on a map tab.
- **Maps** — Interactive OSM-based maps across the app: address search and pin-drop, trip route overview, tap-to-add stops directly from the map.
- **Dashboard** — At-a-glance overview of the active trip: packing progress, task progress, expenses summary
- **Archive** — Clone past trips (optionally carrying over packing lists, tasks, and addresses)
- **Backup & Restore** — Export and import a full local database backup
- **Localisation** — Full Hebrew (RTL) and English support, with a simple path for adding more languages

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.2 / Dart 3.11.0 |
| Database | SQLite via `sqflite` + `sqflite_common_ffi` |
| Maps | `flutter_map` + OpenStreetMap tiles + Nominatim geocoding |
| Localisation | Custom standalone `AppLocalizations` (no code generation) |
| Fonts | Google Fonts — DM Sans + Playfair Display |
| State | `ChangeNotifier` + `ValueNotifier` |
| Platforms | Windows, Linux, Android |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, MaterialApp, bottom nav
├── theme/
│   └── app_theme.dart               # Colour palette, typography, shared theme
├── models/
│   ├── trip.dart                    # Trip, TripType, TripPurpose, TripStatus, TripStop
│   ├── trip_details.dart            # TripTask, TripAddress, TripDocument, TaskStatus
│   ├── packing.dart                 # PackingItem, PackingTask
│   └── receipt.dart                 # Receipt, ReceiptType
├── database/
│   ├── database_helper.dart         # Main SQLite helper — trips, tasks, addresses (DB v7)
│   ├── packing_database.dart        # Packing items and templates
│   ├── receipt_database.dart        # Receipts and currency
│   ├── trip_details_database.dart   # Documents
│   └── backup_service.dart          # Export / import database backup
├── services/
│   ├── geocoding_service.dart       # Nominatim forward/reverse geocoding
│   ├── app_notifier.dart            # Global state change notifications
│   ├── language_service.dart        # Locale state, persistence via shared_preferences
│   └── localization_ext.dart        # BuildContext.l shorthand + re-export
├── l10n/
│   ├── app_en.arb                   # English strings (source of truth)
│   ├── app_he.arb                   # Hebrew strings
│   ├── app_localizations.dart       # Generated localisation class (see below)
│   └── generate_localizations.py   # Generator script — run after adding a language
├── widgets/
│   ├── shared_widgets.dart          # StatusBadge, EmptyState, StatCard, SectionHeader, etc.
│   └── map_search_bar.dart          # Shared floating map search bar widget
└── screens/
    ├── dashboard_screen.dart
    ├── trips_screen.dart
    ├── trip_detail_screen.dart      # Includes _TripRouteMapScreen, _RouteChips
    ├── add_edit_trip_screen.dart    # Form + Map tabs; _EditTripMapTab
    ├── settings_screen.dart
    ├── archive/archive_screen.dart
    ├── tasks/tasks_screen.dart
    ├── addresses/
    │   ├── addresses_screen.dart    # List + Map tabs; _AddressesMapView
    │   └── map_picker_screen.dart   # Full-screen pin picker (standalone)
    ├── documents/documents_screen.dart
    ├── receipts/receipts_screen.dart
    └── packing/
        ├── packing_list_screen.dart
        ├── add_edit_packing_item_screen.dart
        └── template_dialogs.dart
```

---

## Getting Started

### Prerequisites

- Flutter 3.41.2 or later
- Dart 3.11.0 or later
- Python 3 (only needed when adding new languages)

### Run

```powershell
flutter pub get
flutter run -d windows
```

---

## Maps

TripReady uses [flutter_map](https://pub.dev/packages/flutter_map) with OpenStreetMap tiles and the [Nominatim](https://nominatim.org/) geocoding API. No API key is required.

### Map features

| Feature | Location |
|---|---|
| Search for a place and save it with auto-filled details | Addresses → Add Address dialog |
| View all saved places on a map | Addresses → Map tab |
| Long-press map to drop a pin and add an address | Addresses → Map tab |
| Search bar to pan the map | Addresses map tab, Trip Route map |
| Trip route overview with polyline | Trip Detail → map button (🗺) |
| Tap map to add a stop to the route | Trip Detail → map button → tap |
| Map view while editing route | Add/Edit Trip → Map tab |

### Network requirement

Map tiles and geocoding require an internet connection. The rest of the app is fully offline.

---

## Localisation

### How it works

TripReady uses a custom, standalone localisation system — no `flutter gen-l10n`, no `generate: true` in `pubspec.yaml`, no external code generation tools. All strings are compiled directly into `lib/l10n/app_localizations.dart` by a Python script.

All UI strings are defined in two ARB files:

- `lib/l10n/app_en.arb` — English (source of truth, 280+ keys)
- `lib/l10n/app_he.arb` — Hebrew

In screens, strings are accessed via:

```dart
import '../../services/localization_ext.dart';

final l = context.l;
Text(l.tripsNewTrip)
```

---

### Adding a New Language

#### Step 1 — Translator (no coding needed)

1. Copy `lib/l10n/app_en.arb` and rename it to `lib/l10n/app_XX.arb` where `XX` is the [ISO 639-1 language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) (e.g. `app_fr.arb` for French)
2. Open the file in any text editor
3. Translate every **value** — do not change the **keys**

Example — only the right side changes:
```json
"tripsNewTrip": "New Trip"       ← English original
"tripsNewTrip": "Nouveau voyage" ← French translation
```

4. Send the completed `.arb` file back to the developer

#### Step 2 — Run the generator

```powershell
python lib/l10n/generate_localizations.py
```

This reads all `app_XX.arb` files in `lib/l10n/` and rewrites `app_localizations.dart` with a new implementation class for the added language. No other changes to the file are needed.

#### Step 3 — Add to LanguageService

In `lib/services/language_service.dart`, add the new locale:

```dart
static const supportedLocales = [
  Locale('en'),
  Locale('he'),
  Locale('fr'),  // ← add this
];
```

#### Step 4 — Add to the Settings dropdown

In `lib/screens/settings_screen.dart`, inside `_LanguageTileState.build()`:

```dart
final options = [
  _LangOption(code: 'en', label: l.langEnglish, flag: '🇬🇧'),
  _LangOption(code: 'he', label: l.langHebrew,  flag: '🇮🇱'),
  _LangOption(code: 'fr', label: 'Français',    flag: '🇫🇷'), // ← add this
];
```

#### Step 5 — Run the app

```powershell
flutter run -d windows
```

---

### ARB File Format

ARB (Application Resource Bundle) is a plain JSON file. Keys map to UI string identifiers; values are the translated text. Placeholders use `{name}` syntax and are declared in a sibling `@key` metadata entry.

```json
{
  "tripsNewTrip": "New Trip",
  "tasksDoneCount": "{done} / {total} completed",
  "@tasksDoneCount": {
    "placeholders": {
      "done": { "type": "int" },
      "total": { "type": "int" }
    }
  }
}
```

---

## Backup & Restore

Use the **Settings → Export Backup** option to save a copy of the SQLite database file. Use **Settings → Restore Backup** to load it back. The backup contains all trips, packing lists, tasks, receipts, addresses, and documents.

---

## Version History

| Version | Notes |
|---|---|
| 1.4.0 | Maps integration (OSM/Nominatim), multi-destination route model, archive clone polish, Form/Map tabs in edit screens |
| 1.3.0 | Packing ↔ Task integration, country picker i18n, customisable lookup tables, UX refinements |
| 1.2.0 | Branding, colour themes, dark/light/auto mode, font size control |
| 1.1.0 | Hebrew localisation, language selector, RTL support |
| 1.0.0 | Initial release — all core modules |
