# Changelog

All notable changes to TripReady are documented in this file.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Backlog]

### Sprint v1.5 — Recommended Next Sprint
- **Map UX/UI improvements (deferred from v1.4)**
  - Pinned location identification fix — resolve POI name vs street name on reverse geocode
  - Unified map view — merge Addresses map and Trip Route map into a single shared component
- In-app & system notifications
- Document expiry alerts
- Calendar integration
- **Store prep:** Snap Store packaging (`snapcraft.yaml`, CI integration)
- **Store prep:** Google Play Store — Android keystore signing, AAB build, store listing assets, privacy policy

### Sprint v1.6
- Packing templates
- Trip export & share
- Multi-currency budgeting enhancements

### Sprint v1.7
- Home screen widget
- **Store prep:** Flathub submission — manifest, open source review, Flathub PR

### TBD
- Budget tracking
- Google Drive integration
- Embedded document viewer

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
