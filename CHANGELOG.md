# Changelog

All notable changes to TripReady are documented in this file.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Backlog]

### Sprint v1.5 — "Smart Alerts" — Next Sprint
- **App Info & Version**
  - `assets/data/app_info.json` — version, build date, author, website, license
  - Loaded at runtime via `rootBundle`; displayed in Settings → About
  - GitHub Actions auto-updates on every build
- **In-App Notification Center**
  - Bell icon in AppBar with unread badge count
  - Notification center screen — mark as read, dismiss, clear all
  - Persisted in local DB (new `notifications` table)
- **System/OS Notifications** (`flutter_local_notifications`)
  - Android — notification channels + runtime permission request
  - Windows — Win32 toast notifications
  - Linux — libnotify / freedesktop notifications
- **Notification Triggers** (all user-configurable lead time)
  - Trip departure & return reminders
  - Task due date reminders
  - Document expiry alerts
  - Packing list incomplete reminder (X days before departure)
- **Settings → Notifications**
  - Global on/off toggle; per-type toggles; per-type lead time (user-defined)
  - "Send test notification" button

### Sprint v1.6
- **Map UX/UI improvements** (deferred from v1.4/v1.5)
  - POI name fix — resolve POI name vs street address on reverse geocode
  - Unified map component — merge Addresses map and Trip Route map
- **Store prep:** Google Play Store — keystore signing, AAB build, store listing, privacy policy
- Linux app icon fix (pending Snap Store approval)
- Packing templates
- Trip export & share

### Sprint v1.7
- Calendar integration
- Home screen widget
- **Store prep:** Flathub submission

### TBD
- Budget tracking
- Google Drive integration
- Embedded document viewer
- Multi-currency budgeting enhancements

---

## [1.4.1] — 2026-03-06

### Bug Fixes & Platform Improvements

#### Flag Rendering (all platforms)
- **Replaced emoji-based flags** with the `country_flags` package — SVG vector assets render correctly on Windows, Linux and Android with no OS emoji font dependency
- **`FlagWidget`** rewritten to wrap `CountryFlag.fromCountryCode()`; platform detection removed entirely
- **Trip cards, archive cards, dashboard** — `Text(trip.routeDisplay)` replaced with new `TripRouteDisplay` widget; flags render inline as proper image widgets
- **Trip detail header** — simple destination replaced with `TripDestinationDisplay` widget
- **Route chips** — `flagInline()` helper updated; all chip flag rendering unchanged, now backed by SVG
- **Settings language selector** — dropdown flag `Text` replaced with `CountryFlag` widget
- **`countries.dart`** — `localizedDisplay()` and `display` no longer embed raw emoji into strings; country name only returned

#### Country → City Destination Picker (UX)
- **`CityPickerField`** replaces free-text destination field — bottom sheet with bundled offline city list (~640 cities, 178 countries)
- **Live Nominatim autocomplete** — 400ms debounced query fires as user types; results appear under a "Suggestions" section alongside bundled matches
- **Country first layout** — country picker (flex 2) left, city picker (flex 3) right; applied to departure, all stops, and return destination rows
- **Recent destinations** — every confirmed city selection is saved (up to 20 entries); shown at top of picker when search box is empty; filtered by selected country
- Recent destinations manageable in Settings → Recent Destinations (per-item swipe-to-delete, clear all)

#### Map Language
- **`MapLanguageService`** — new service storing map geocoding language preference
- **Geocoding `Accept-Language` header** — all Nominatim requests now pass the UI language code; place names returned in the active app language
- **Settings → Maps** — toggle: "Place names match app language" vs "always English"; persisted in `shared_preferences`

#### Android OSM Support
- Added `<uses-permission android:name="android.permission.INTERNET"/>` to `AndroidManifest.xml`
- `android:usesCleartextTraffic="false"` set on application tag
- Fixes map tiles and Nominatim geocoding not loading on Android

#### Linux App Icon
- `.deb` CI build now installs all 7 icon sizes (16 → 512px) to `/usr/share/icons/hicolor/{size}x{size}/apps/`
- Copies the real `linux/packaging/tripready.desktop` file instead of the previous inline stub
- Snap build includes the same icon install step

#### Auto Version in About
- `package_info_plus` dependency added; version read at runtime via `PackageInfo.fromPlatform()`
- Settings → About card and `showAboutDialog` both display the live version from `pubspec.yaml`

#### Snap Store Prep
- `snap/snapcraft.yaml` added — `strict` confinement, required plugs (`network`, `home`, `wayland`, `x11`, `desktop`)
- GitHub Actions `build-snap` job added to `build_all.yml` — builds `.snap` artifact on release using `snapcraft --destructive-mode` on `ubuntu-22.04`

### New Dependencies
- `country_flags: ^2.0.1` — SVG flag assets, replaces emoji font approach
- `package_info_plus: ^8.0.0` — runtime version reading

### Removed
- `NotoColorEmoji_Flags.ttf` font asset and font declaration — no longer needed
- `tools/subset_flag_font.py` subsetting script — no longer needed

---

## [1.4.0] — 2026-03-06

### Features

#### Maps Integration (Feature 1)
- **Search-first add-place flow** — inline search bar on the Add Address dialog; type ≥ 2 characters to get live Nominatim results; tapping a result pre-fills name, address, phone, website, coordinates, and category
- **Addresses map tab** — dedicated Map tab on the Addresses screen showing all saved places with coordinate pins; tap a pin to see a popup card with Navigate action
- **Long-press to add from map** — long-press anywhere on the addresses map drops a teal pin, reverse-geocodes the location, and opens the pre-filled Add Address dialog
- **Map search bar** — floating search bar on both the Addresses map and the Trip Route map; search a location to pan and drop a pin ready to confirm
- **View on Map chip** — per-address action chip that switches to the Map tab and highlights the pin
- **Map FAB** — secondary mini FAB on the Addresses screen to switch directly to the map tab, centred on the trip destination

#### Multi-Destination Route Model (Feature 2)
- **Stops model** — trips now support departure → N stops → optional return destination; drag-to-reorder stops in the edit form
- **Route chips** — trip header and detail screen display the full route as compact flag chips (e.g. 🇬🇧 → 🇫🇷 → 🇮🇹)
- **Trip Route map** — full-screen map button on the Trip Detail screen showing all route points connected by a polyline; teal = departure, amber = stops, navy = return
- **Tap-to-add stop from map** — tap the route map to reverse-geocode a city and insert it at the nearest position in the route with a confirm bottom sheet
- **Route map in edit form** — Map tab added to the Add/Edit Trip screen showing the live route as it is built; tap to add stops directly from the map

#### Archive Clone Polish (Feature 3)
- Date picker in clone dialog for choosing a new departure date
- Post-clone navigation shortcut to the newly created trip

### UX Improvements
- **Edit Trip screen** — Form / Map tabs (matching the Addresses screen layout); `HomeButton` in leading replaced with `BackButton` returning to Trip Detail
- **Address cards** — single tap to edit (was double tap)
- **Trip Route map** — back arrow returns to Trip Detail; no `HomeButton` (prevents accidental home navigation)
- **Return destination clear** — removing a return destination in the edit form now correctly saves as null (previously silently kept old value due to `copyWith` fallback)

### Bug Fixes
- Route display string interpolation — literal `${trip.destination}` rendered when no stops/return; backslash escape removed
- `_tabController` init duplicated into `_RouteSectionState` — spurious init removed
- Duplicate `options: MapOptions(` in addresses map — extra line removed
- `TapPosition` constructor called with `LatLng` instead of `Offset` — fixed to `Offset.zero`
- Duplicate `_focusAddress` field declaration in `AddressesScreen` — removed

---

## [1.3.0] — 2026-03-04

### Features

#### Packing ↔ Task Integration (Feature 5.3)
- Two-way sync between packing items and tasks — marking an item packed marks the linked task done, and vice versa
- Inline task creation on the packing item form — toggle "Track as Task", optionally select a packing action and subject
- New **Packing Actions** lookup category (Buy, Pack, Clean, Retrieve, Print, Charge, Repair, Iron, Borrow, Other) fully customisable via Settings → Customize Lists
- Source filter on the Tasks screen — filter by All / Manual Tasks / Packing-sourced tasks
- Packing-sourced tasks display a teal **PACKING** badge in the task list
- Database migrated to v4; existing data is fully preserved

#### Country Picker i18n (Feature 5.1)
- Country names displayed in the active UI language (English / Hebrew) across all 175 countries
- Country picker searches both EN and HE names simultaneously
- Bottom sheet renders RTL when Hebrew is active

#### Default Return Date (Feature 5.2)
- Return date auto-fills to departure + 7 days on first date selection
- Return date silently shifts forward if it falls before the departure date
- Inline duration badge (e.g. "8d") shown between the two date fields
- Form reset button — clears all fields with confirmation dialog

#### Customisable Lookup Tables (Feature 3)
- Four fully customisable lists: Trip Type, Trip Purpose, Packing Category, Storage Location
- Rename, reorder, disable, and add values — changes reflect immediately in all dropdowns
- 34 seeded default values; backward-compatible with existing trips

### UX Improvements
- **Universal Home button** — always accessible in the AppBar on every secondary screen
- **Dashboard redesign** — six widget cards all tappable; navigate directly to each section list
- **Trip Detail redesign** — all stat cards tappable; hamburger menu for quick section access
- **Date fields** — direct keyboard input with red highlight for invalid entries
- **Tab order** — corrected keyboard navigation in New/Edit Trip form

### App Icons
- All platform icons replaced with the new TripReady brand icon (Android, Windows, Linux)

---

## [1.2.0] — 2026-03-04

### Features
- **Branding** — Poppins / DM Sans typography, six colour themes, dark / light / auto theme modes, adjustable font size
- **Splash screen** — 3.5 s animated splash; landscape AppBar wordmark; portrait watermark
- Six SVG brand variants; platform icons for Android, Windows, and Linux

---

## [1.1.0] — 2026-03-02

### Features
- **Localisation** — full English / Hebrew ARB-based l10n (280 keys); RTL layout support
- **CI/CD** — GitHub Actions pipeline for Windows, Linux, and Android builds

---

## [1.0.0] — Initial Release

### Features
- Trip management — create, edit, archive, and clone trips with status tracking
- Packing list with categories, status filtering, and bulk actions
- Task manager with pending / in-progress / done tabs
- Address book per trip
- Receipt and expense tracker with currency support
- Document attachments
- SQLite local storage — all data stored on-device
- Windows, Linux, and Android targets
