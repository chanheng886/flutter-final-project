# Khmer OCR — Frontend Documentation

## Overview
This is the Flutter mobile frontend for the **Khmer OCR** application. It implements a clean, modern Material 3 UI with a feature-first folder architecture, custom bottom navigation shell, and the complete **Home Screen** experience for managing folders, uploading files/images, and viewing recently processed documents.

---

## Tech Stack & Dependencies
- **Framework:** Flutter (Dart SDK `^3.13.5`, Material 3 enabled)
- **Typography:** [`google_fonts`](https://pub.dev/packages/google_fonts) (`^9.0.0`) — **DM Sans** font family used across the app
- **Icons:** [`font_awesome_flutter`](https://pub.dev/packages/font_awesome_flutter) (`^11.0.0`), Material Icons, & [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) (`^1.0.8`)
- **Networking / Images:** [`cached_network_image`](https://pub.dev/packages/cached_network_image) (`^4.0.4`)

---

## Project Structure

```text
lib/
├── main.dart                                  # App entry point & root MaterialApp setup
├── app.dart                                   # Reserved app configuration file
├── core/
│   └── theme/
│       ├── app_color.dart                     # Centralized color palette (AppColor)
│       └── app_theme.dart                     # Light theme configuration (AppTheme)
├── shell/
│   ├── main_shell.dart                        # Root Scaffold with IndexedStack & bottom nav
│   └── widgets/
│       ├── app_bottom_nav.dart                # Floating rounded bottom navigation bar
│       ├── nav_item.dart                      # Animated navigation item widget
│       └── place_holder_page.dart             # Placeholder view for unimplemented tabs
└── features/
    └── home/
        ├── models/
        │   └── mock_data.dart                 # Static mock data for recent PDF files
        └── views/
            ├── home_page.dart                 # Main Home screen layout
            └── widgets/
                ├── home_header.dart           # Top greeting banner with user avatar & actions
                ├── circle_icon_button.dart    # Circular icon button used in header
                ├── my_folder_section.dart     # 2x2 grid card displaying user folders
                ├── folder_card.dart           # Individual gradient folder card item
                ├── new_folder_card.dart       # Action card to create a new folder
                ├── upload_button.dart         # Side-by-side upload action row
                ├── upload_action_card.dart    # Reusable card for file/image upload triggers
                ├── recent_file_container.dart # "Recently added" section container & list
                └── recent_file_tile.dart      # Individual file row with icon, metadata & menu
```

---

## What Has Been Implemented

### 1. Core Theme & Styling (`lib/core/theme/`)
- **`AppColor` (`app_color.dart`):** Defines the brand color palette:
  - `primary`: `#A2D2FF` (Soft sky blue)
  - `primaryDark`: `#BDE0FE` (Light pastel blue for gradients)
  - `background`: `#F5F5F5` (Light grey surface background)
  - `textDark`: `#1A1A1A` (Primary typography color)
  - `textGrey`: `#6B6B6B` (Secondary/subtitle typography color)
  - `link`: `#1E88E5` (Interactive link accent)
- **`AppTheme` (`app_theme.dart`) & `MyApp` (`main.dart`):** Configures Material 3, sets `GoogleFonts.dmSans()` as the global font family, and disables the debug banner.

### 2. Application Shell & Navigation (`lib/shell/`)
- **`MainShell` (`main_shell.dart`):** Manages top-level tab switching using an `IndexedStack` to preserve page state across 4 tabs:
  1. **Home** (`HomePage`) — *Implemented*
  2. **Folders** (`PlaceHolderPage`) — *Placeholder*
  3. **Recent** (`PlaceHolderPage`) — *Placeholder*
  4. **Settings** (`PlaceHolderPage`) — *Placeholder*
- **`AppBottomNav` (`app_bottom_nav.dart`) & `NavItem` (`nav_item.dart`):**
  - Custom floating rounded pill bar (`BorderRadius.circular(28)`) with soft drop shadow and center spacing (`SizedBox(width: 56)`) reserved for a future central Scan FAB/button.
  - Smooth 200ms `AnimatedContainer` transitions highlighting the active tab with `AppColor.primary`.

### 3. Home Feature (`lib/features/home/`)
The `HomePage` is a vertically scrollable screen composed of four main sections:

1. **Header Banner (`HomeHeader` & `CircleIconButton`):**
   - Full-width gradient header (`AppColor.primary` to `AppColor.primaryDark`) with rounded bottom corners.
   - Displays user avatar, greeting (`"Hello, Chanheng"`), current date (`"Today 18 Sep"`), and quick-action circular buttons for **Notifications** and **Search**.
2. **My Folders Section (`MyFolderSection`, `FolderCard`, `NewFolderCard`):**
   - Overlaps the header slightly (`Transform.translate` with `-24px` Y-offset) inside an elevated white rounded container.
   - Header row with `"My Folders"` title and `"View all >"` link.
   - Non-scrollable 2-column `GridView` displaying 3 dummy folders (`My Folders` - 16 items, `Reports` - 8 items, `Notes` - 4 items) with soft top-to-bottom blue-to-white gradients, plus a **`NewFolderCard`** (`+ New Folder`) in the 4th slot.
3. **Upload Actions (`UploadButton` & `UploadActionCard`):**
   - Two side-by-side action cards for initiating OCR/document imports:
     - **Upload file:** `"Upload form device"` (Yellow cloud icon)
     - **Upload image:** `"From gallary or camera"` (Green image icon)
4. **Recently Added Files (`RecentFileContainer`, `RecentFileTile`, `MockData`):**
   - Card container showing up to 3 recent files from `MockData.mockData` (including Khmer script support, e.g., `Project Report.pdf`, `Receipt Photo.pdf`, `ឯកសារដ្ឋបាល.pdf`).
   - Each `RecentFileTile` renders a leading blue file icon badge, file name, date + file size subtitle, and a trailing `more_vert` options button.

---

## Next Steps / Pending Work
- [ ] Add central **Scan / Camera FAB** button inside `AppBottomNav` and wire up `onScan`.
- [ ] Implement the **Folders**, **Recent**, and **Settings** screens (currently using `PlaceHolderPage`).
- [ ] Connect action callbacks (`onTap` on folders, upload cards, search, notifications, and file menu actions).
- [ ] Integrate file picker, camera/gallery image picker, and backend Khmer OCR API service.