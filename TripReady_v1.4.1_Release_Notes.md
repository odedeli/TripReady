# TripReady v1.4.1 — Release Notes

**Release date:** 06 March 2026  
**Type:** Hotfix + UX improvements  
**Platforms:** Windows · Linux · Android

---

## Overview

v1.4.1 is a targeted hotfix sprint following v1.4.0 (Maps & Routing). It resolves six confirmed issues from the v1.4 release — most critically flag emoji rendering on Windows and Linux, missing Android network permissions for OSM, and a broken Linux desktop icon — and adds three UX improvements to the new destination picker introduced in v1.4.

---

## What's New at a Glance

| # | Area | Type | Summary |
|---|---|---|---|
| 1 | Flag rendering | Bug fix | SVG flags on all platforms — no OS emoji font needed |
| 2 | Android OSM | Bug fix | Map tiles and geocoding now load on Android |
| 3 | Country → City picker | UX improvement | Live autocomplete, recent destinations, country-first layout |
| 4 | Linux app icon | Bug fix | Correct icon sizes installed in `.deb` and Snap packages |
| 5 | Auto version | Improvement | Settings → About reads version from `pubspec.yaml` at runtime |
| 6 | Snap Store prep | Infrastructure | `snapcraft.yaml` + GitHub Actions `.snap` build job |

---

## Detailed Changes

### 1 · Flag Rendering — All Platforms

**Problem:** Flag emoji rendered as yellow placeholder boxes with ISO codes (e.g. `GB`, `IL`) on Windows and Linux. The root cause was twofold: Flutter's DirectWrite text renderer on Windows does not support CBDT bitmap emoji fonts loaded as app assets, and the `Country.localizedDisplay()` method was embedding raw emoji characters directly into display strings used across trip cards, archive cards, the dashboard, and the detail header.

**Fix:**
- Replaced the emoji + font approach entirely with the [`country_flags`](https://pub.dev/packages/country_flags) package, which renders each flag as an SVG vector widget — no text renderer involved
- `FlagWidget` rewritten to wrap `CountryFlag.fromCountryCode()`; platform detection removed
- New `TripRouteDisplay` and `TripDestinationDisplay` widgets replace all `Text(trip.routeDisplay)` call sites; flags render inline as proper image widgets
- `Country.localizedDisplay()` and `Country.display` now return name-only strings; emoji stripped from model layer
- Settings language selector flag updated to use `CountryFlag` widget

**Result:** Flags render correctly and at full resolution on Windows, Linux, and Android.

---

### 2 · Android OSM Support

**Problem:** OpenStreetMap tiles and Nominatim geocoding requests failed silently on Android — the app had no `INTERNET` permission declared in the manifest.

**Fix:**
- Added `<uses-permission android:name="android.permission.INTERNET"/>` to `AndroidManifest.xml`
- Set `android:usesCleartextTraffic="false"` on the application tag (HTTPS only)

---

### 3 · Country → City Destination Picker (UX)

Building on the two-step country→city picker introduced in v1.4.1, three further improvements were made:

**Live autocomplete**
As the user types in the city search box, a debounced (400ms) Nominatim query fires automatically. Results appear under a "Suggestions" section below the bundled city list — no separate "Search online" button needed. Autocomplete results are deduplicated against the bundled list.

**Recent destinations**
Every confirmed city selection is saved (up to 20 entries, most-recent first) via `RecentDestinationsService` backed by `shared_preferences`. When the picker opens and the search box is empty, a "Recent" section appears at the top filtered to the selected country. Recents are manageable in Settings → Recent Destinations (swipe-to-delete, clear all).

**Country-first layout**
The country picker (flex 2) is now left of the city picker (flex 3) in all rows — departure, stops, and return destination — matching the expected left-to-right selection flow.

**Map language**
All Nominatim requests now include an `Accept-Language` header matching the active UI language, so geocoding results and reverse-geocoded place names are returned in the correct language. A new toggle in Settings → Maps controls whether map labels follow the UI language or always use English.

---

### 4 · Linux App Icon Fix

**Problem:** The `.deb` CI build was generating a desktop entry with an inline stub and no icon files, so the app appeared without an icon in GNOME/KDE application launchers.

**Fix:**
- The `build_all.yml` Linux job now installs all 7 icon sizes (16 → 512 px) to the standard freedesktop hicolor paths (`/usr/share/icons/hicolor/{size}x{size}/apps/tripready.png`)
- Copies `linux/packaging/tripready.desktop` (the real, fully-specified desktop entry) instead of the previous inline stub
- The Snap build includes the same icon install step

---

### 5 · Auto Version in Settings → About

**Problem:** The version string in Settings → About was hardcoded as `'1.3.0'` and required a manual code edit on every release.

**Fix:**
- Added `package_info_plus: ^8.0.0` dependency
- Settings About card wraps the version `Text` in a `FutureBuilder` that calls `PackageInfo.fromPlatform()` at runtime — version always matches `pubspec.yaml`

---

### 6 · Snap Store Prep

- `snap/snapcraft.yaml` added — `strict` confinement, Flutter build in `override-build`, all required plugs declared (`network`, `home`, `wayland`, `x11`, `desktop`, `desktop-legacy`)
- Icons installed to hicolor paths inside the snap at build time
- GitHub Actions `build-snap` job added to `build_all.yml` — builds a `.snap` artifact on every release push using `snapcraft --destructive-mode` on `ubuntu-22.04`

---

## New Dependencies

| Package | Version | Purpose |
|---|---|---|
| `country_flags` | `^2.0.1` | SVG vector flag assets — cross-platform flag rendering |
| `package_info_plus` | `^8.0.0` | Runtime version reading from `pubspec.yaml` |

---

## Removed

| Item | Reason |
|---|---|
| `assets/fonts/NotoColorEmoji_Flags.ttf` | Replaced by `country_flags` SVG package |
| `tools/subset_flag_font.py` | No longer needed |
| Font declaration in `pubspec.yaml` | No longer needed |

---

## Deferred to v1.5

These two items from the original v1.4 scope remain deferred:

| Item | Notes |
|---|---|
| Pinned location POI name resolution | Reverse geocode returns street name instead of POI name for map-pinned addresses |
| Unified map view component | Merge Addresses map and Trip Route map into a single reusable component |

---

## v1.5 Preview

v1.5 focuses on **Map completion & Intelligence**:

- POI name fix for reverse geocoded addresses
- Unified map view component
- Map tile language support (requires tile provider with language param — Stadia Maps / MapTiler)
- In-app notifications
- Document expiry alerts
- Calendar integration
