# BeztaMy Project Overview

This document provides a comprehensive overview of the BeztaMy Flutter project, a personal finance management application designed for both web and mobile platforms.

## 1. Core Technologies

The project is built on a modern Flutter stack, leveraging powerful packages for a robust and scalable architecture.

- **Framework:** Flutter (cross-platform UI)
- **Language:** Dart
- **State Management:** `flutter_riverpod` for declarative, scalable, and testable state management.
- **Routing:** `go_router` for declarative, URL-based navigation and deep linking.
- **UI & Charting:**
    - `fl_chart` for creating rich and interactive charts (bar, pie, line).
    - `flutter_map` with `latlong2` for interactive map features.
    - `flutter_slidable` for intuitive list item actions (edit, delete).
    - `google_fonts` for a consistent and modern typography.
- **Backend Integration:**
    - `dio` for efficient and powerful HTTP requests.
    - `json_serializable` and `build_runner` for boilerplate-free JSON parsing.
- **Local Storage:**
    - `shared_preferences` & `flutter_secure_storage` for persisting simple data and sensitive authentication tokens.

## 2. Application Architecture

The codebase is organized following a clean, feature-based architecture that promotes separation of concerns and maintainability.

- **Feature-Driven Structure:** The `lib/features` directory contains self-contained modules for each major part of the app (`auth`, `transactions`, `dashboard`, etc.). Each feature is further divided into:
    - `data`: Contains data models (`.g.dart` files for JSON serialization) and service API definitions.
    - `domain`: Holds the business logic, state management providers (Riverpod), and repository interfaces.
    - `presentation`: Includes all the UI components (screens, widgets).
- **State Management with Riverpod:** The application state is managed by a series of `Providers`. This allows widgets to "watch" for state changes and automatically rebuild, while business logic is decoupled from the UI. Key providers are explained in the **State Management** section.
- **Declarative Routing with GoRouter:** All navigation logic is centralized in `lib/routes/app_router.dart`. It defines all available routes and implements an authentication-based redirect system, ensuring that unauthenticated users cannot access protected screens.

---

## 3. Chatbot Backend (`simpleRag`)

The chatbot feature is powered by a separate Python-based backend service located in the `simpleRag` directory. This service is a Retrieval-Augmented Generation (RAG) system built to answer questions about personal finance.

-   **Technology Stack:**
    -   **Web Framework:** `FastAPI`
    -   **LLM Orchestration:** `LangChain` and `LangGraph` for creating agentic workflows with memory.
    -   **LLM:** `Groq` API with the Llama 3.1 8B Instant model for fast inference.
    -   **Embeddings:** `Ollama` with `embeddinggemma` for local text embeddings.
    -   **Vector Database:** `ChromaDB` for storing and retrieving document embeddings.

-   **Knowledge Base:** The RAG's knowledge is sourced from markdown files located in the `simpleRag/data/` directory, which cover topics like budgeting, saving, and debt management.

-   **API Endpoints:** The service runs on `http://localhost:8000` and exposes a REST API:
    -   `POST /chat`: The main endpoint for sending user questions. It accepts a `question` and a `session_id` to maintain conversation history.
    -   `GET /chat/history/{session_id}`: Retrieves the conversation history for a given session.
    -   `DELETE /chat/history/{session_id}`: Clears the history for a session.
    -   `GET /health`: A health check endpoint.

-   **Frontend Integration:** The Flutter application's `ChatbotScreen` will interact with this backend by making HTTP requests to the `/chat` endpoint. The `session_id` will be managed within the Flutter app to handle multi-turn conversations.

---

## 4. Core Components & Features

### 4.1. Responsiveness (`ResponsiveHelper` & `LayoutBuilder`)

The application is designed to be fully responsive, adapting its layout for mobile, tablet, and desktop screens.

- **`ResponsiveHelper`:** A utility class in `lib/core/utils/responsive_helper.dart` defines the breakpoints:
    - **Mobile:** `< 600px`
    - **Tablet:** `600px` to `1200px`
    - **Desktop:** `>= 1200px`
- **Dynamic Layouts:** Widgets like `LayoutBuilder` are used throughout the app (e.g., `DashboardScreen`, `TransactionsScreen`) to conditionally render different UI structures based on the available screen width. For example, the `AppSidebar` is a full-width drawer on mobile but a fixed sidebar on desktop.

### 4.2. Navigation (`AppSidebar` and `go_router`)

Navigation is handled by a combination of `go_router` and a custom `AppSidebar` widget.

- **`AppSidebar` (`lib/shared/widgets/app_sidebar.dart`):**
    - This widget serves as the primary navigation hub.
    - On desktop, it's a persistent, expanded sidebar.
    - On smaller screens (`< 900px`), it collapses into a compact, icon-only bar.
    - It uses `context.go()` to navigate between the main screens: Dashboard, Transactions, Add Entry, Chatbot, and Profile.
    - It also contains the **Log Out** logic, which clears the user's session data and redirects to the `/login` screen.

### 4.3. Screens

#### Dashboard Screen (`lib/dashboard_screen.dart`)

This is the main landing page after login, providing a comprehensive, at-a-glance overview of the user's finances.

- **Responsive Layout:** Uses `LayoutBuilder` to rearrange its components for different screen sizes.
- **Data-Driven Widgets:** The dashboard is composed of several widgets, each powered by a dedicated Riverpod provider:
    - **Balance Card:** Displays the current total balance, total income, and total expenses (`dashboardBalanceProvider`). Includes "Add Income" and "Add Expense" buttons that navigate to the `/add-transaction` route.
    - **Income vs. Expenses Chart:** A `BarChart` (`fl_chart`) showing a monthly summary (`dashboardMonthlySummaryProvider`).
    - **Recent Transactions:** A list of the latest transactions (`dashboardRecentTransactionsProvider`).
    - **Spending Categories:** A `PieChart` (`fl_chart`) visualizing spending distribution by category (`dashboardSpendingCategoriesProvider`).
    - **Financial Trends:** A `LineChart` (`fl_chart`) showing the balance trend over time (`dashboardTrendsProvider`).

#### Transactions Screen (`lib/features/transactions/presentation/screens/transactions_screen.dart`)

A powerful screen for viewing, searching, and managing all transactions.

- **Filtering and Search:**
    - A search bar allows filtering transactions by description, category, or other fields.
    - Filter buttons allow users to narrow down the list by type (Income/Expense), category, and sort order (Newest/Oldest). The state of these filters is managed by the `transactionFilterProvider`.
- **Transaction List:**
    - The main list is powered by the `filteredTransactionsProvider`, which reacts to changes in the search and filter settings.
    - Each item is wrapped in a `Slidable` widget, revealing **Edit** and **Delete** actions on swipe.
- **Actions:**
    - **Edit:** Navigates to the `/add-transaction` screen, passing the selected transaction object to pre-fill the form.
    - **Delete:** Shows a confirmation dialog, then calls the `transactionServiceProvider` to delete the item and invalidates all relevant providers to trigger a UI refresh across the app.
    - **Details:** Tapping an item opens a detailed dialog with more information.

#### Chatbot Screen (`lib/features/chatbot/presentation/screens/chatbot_screen.dart`)

This screen provides an interactive interface for users to engage with a financial chatbot.

-   **User Interface:** Features a chat-like UI where users can type messages or record voice messages using the `record` package. Quick action buttons offer common queries.
-   **Current State:** The UI for the chatbot is implemented, including sending user messages and simulating bot responses. However, **the backend integration for the chatbot is pending**.
-   **Planned Integration:** It is anticipated that the chatbot will integrate with a backend endpoint (e.g., `/chatbot`) via the `ApiService` and `dio` client to process natural language queries and provide personalized financial insights and assistance.

- **Dual-Purpose Form:** The screen's title and behavior change depending on whether a `transactionToEdit` object is passed to it.
- **Comprehensive Fields:**
    - **Type Toggle:** Switches between "Expense" and "Income", which also dynamically filters the category list.
    - **Date Picker:** A themed, user-friendly date picker.
    - **Category Dropdown:** Fetches categories from `categoriesProvider`. Includes a "+" button to open a dialog for creating new categories on the fly.
    - **Location with Map:** Users can enter a location manually or tap on an interactive map (`flutter_map`) to select a precise location.
    - **Recurring Transactions:** A switch reveals options for setting a transaction's frequency (`DAILY`, `WEEKLY`, etc.), next execution date, and an optional end date.
- **Submission Logic:**
    - Performs validation on all required fields.
    - On success, it calls the `transactionServiceProvider`'s `createTransaction` or `updateTransaction` method.
    - Finally, it invalidates all dashboard and transaction providers to ensure the entire app state is refreshed, and navigates the user away from the form.

---

## 5. State Management with Riverpod

Riverpod is central to the app's architecture. Below are some of the key providers:

- **Authentication Providers (`lib/features/auth/domain/providers/auth_provider.dart`):**
    - `authTokenProvider`: Manages the user's authentication token.
    - `currentUserProvider`: Holds the currently logged-in user's data.
    - `authStateProvider`: A boolean provider that simply reflects if a user is authenticated, used by `go_router` for redirects.

- **Dashboard Providers (`lib/features/transactions/domain/providers/dashboard_provider.dart`):**
    - `dashboardBalanceProvider`: Fetches the main balance card data (current balance, total income/expense).
    - `dashboardMonthlySummaryProvider`: Provides data for the "Income vs. Expenses" bar chart.
    - `dashboardRecentTransactionsProvider`: Fetches the list of recent transactions for the dashboard.
    - `dashboardSpendingCategoriesProvider`: Provides data for the spending pie chart.
    - `dashboardTrendsProvider`: Fetches data for the financial trends line chart.

- **Transaction & Category Providers (`lib/features/transactions/domain/providers/`):**
    - `categoriesProvider`: Fetches all available income and expense categories.
    - `transactionServiceProvider`: Provides the service class responsible for all CRUD (Create, Read, Update, Delete) operations for transactions.
    - `transactionFilterProvider`: A `StateNotifierProvider` that holds the current state of the filters on the `TransactionsScreen`.
    - `filteredTransactionsProvider`: A provider that watches the main transaction list and the `transactionFilterProvider` to return the final, filtered list of transactions to be displayed.

---

## 6. Building and Running

Standard Flutter commands can be used to run and build the project.

- **Install/update dependencies:**
  ```shell
  flutter pub get
  ```
- **Run the app (web or mobile):**
  ```shell
  flutter run
  ```
- **Build for web:**
  ```shell
  flutter build web
  ```
- **Run tests:**
  ```shell
  flutter test
  ```