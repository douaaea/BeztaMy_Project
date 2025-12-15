# Project Overview

This is a Flutter project named "baztami". Based on the file structure and dependencies, it appears to be a mobile application with a focus on personal finance, including features for managing transactions, viewing reports, and interacting with a chatbot.

The project uses the following key technologies:

- **Framework:** Flutter (with web support)
- **Language:** Dart
- **State Management:** `flutter_riverpod`
- **Routing:** `go_router`
- **HTTP Client:** `dio`
- **JSON Serialization:** `json_serializable`
- **Fonts:** `google_fonts`
- **Local Storage:** `shared_preferences`

The project follows a feature-based architecture, with features like `auth`, `home`, `profile`, `settings`, and `transactions` clearly separated.

## Recent Updates

- **New Features Implemented:**
  - Transactions management (web and mobile versions planned)
  - **Web Add Transaction screen (3:93)** - Fully implemented with dual forms for expenses and income, form validation, date pickers, category dropdowns, and navigation. Fixed ImageCodecException by replacing Figma assets with Material Icons, and resolved RenderFlex overflow by making forms scrollable.
  - **Dashboard Screen** - Fully responsive dashboard with LayoutBuilder for mobile/tablet/desktop layouts. Includes balance card, income vs expenses chart using fl_chart, recent transactions list, and spending categories pie chart. Logo integration from local assets.
  - **Web Transactions screen** - Fully redesigned and implemented with responsive layout, sidebar navigation, search functionality, filter buttons (All Time, All Types, All Categories, All Statuses, Newest), Export button, and detailed transaction cards with icons, color-coded amounts (green for income, red for expense), and Details buttons. Uses ResponsiveHelper for responsive design and AppSidebar for consistent navigation.
  - Integration with Figma designs for UI consistency

- **UI Components:**
  - **ResponsiveHelper** - Utility class for responsive breakpoints (mobile <600px, tablet 600-1200px, desktop >1200px) with helper methods for responsive font sizes, padding, and chart flex ratios.
  - **AppSidebar** - Shared navigation sidebar widget with logo, menu items (Dashboard, Transactions, Add Entry, Chatbot, Reports), and user profile section. Uses go_router for navigation.
  - **AppHeader** - Top app bar for desktop view (currently used in previous dashboard implementation).
  - **SpendingCategoriesChart** - Pie chart widget for displaying spending categories breakdown.

- **Routing Updates:**
  - Added `/add-transaction` route for the web transaction entry screen
  - Added `/transactions` route for the transactions list screen
  - Sidebar navigation properly integrated with go_router

- **Logo Updates:**
  - Replaced text-based "B" logo with actual beztami_logo.png image asset
  - Logo size increased to 64x64 in AppBar and 80x80 in Sidebar
  - Logo displayed in both mobile AppBar and desktop Sidebar

- **Bug Fixes:**
  - Fixed ImageCodecException in web screens by replacing Image.network calls with Material Icons
  - Resolved RenderFlex overflow errors by using SingleChildScrollView in forms and responsive layouts
  - Added InkWell widgets for proper touch feedback in navigation
  - Fixed string interpolation issues with currency symbols using raw strings
  - Removed unused imports and variables for clean compilation

- **Platform Support:**
  - Web build confirmed working
  - Mobile platforms (Android, iOS) supported

## Building and Running

Here are the common commands for building and running the project:

- **Install/update dependencies:**

  ```shell
  flutter pub get
  ```

- **Run the app in debug mode:**

  ```shell
  flutter run
  ```

- **Build the app for a specific platform (e.g., Android):**

  ```shell
  flutter build apk
  ```

  or for iOS:

  ```shell
  flutter build ipa
  ```

- **Build for web:**

  ```shell
  flutter build web
  ```

- **Run tests:**

  ```shell
  flutter test
  ```

## Development Conventions

- **Code Style:** The project uses the standard `flutter_lints` package for code analysis, which enforces the recommended Flutter style guide. Custom lint rules can be added in `analysis_options.yaml`.
- **Architecture:** The code is organized by feature in the `lib/features` directory. Each feature folder contains subdirectories for `data`, `domain`, and `presentation` layers.
- **Routing:** All navigation routes are defined in `lib/routes/app_router.dart` using the `go_router` package.
- **State Management:** Application state is managed using `flutter_riverpod`.
- **Assets:** Project assets are stored in the `assets/` directory and declared in `pubspec.yaml`.
- **Design System:** UI designs are sourced from Figma and converted to Flutter Material Design components for consistency.
