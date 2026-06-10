# Eikon

## Purpose

**Eikon** is a modern Flutter desktop application that provides a performant, cross‑platform interface for managing sales entries, analytics, and data visualisation. It showcases integration of native Windows APIs with Flutter, leveraging Riverpod for state management and Drift (SQLite) for persistent storage.

## Use Case

- **Sales Teams** can record daily transactions, view real‑time analytics, and generate performance reports.
- **Managers** gain insights through interactive charts (via `fl_chart`) and can export data for further analysis.
- **Developers** get a reference project combining Flutter UI, native Windows window handling, and a robust data layer.

## What the App Does

- Implements a native Windows window (`WndProc`, `MessageHandler`) for seamless desktop experience.
- Provides CRUD operations for `SalesEntry` entities using Drift/SQLite (`SalesEntryDao`, `AppDatabase`).
- Displays analytics dashboards with reactive state (`AnalyticsController`, `ConsumerWidget`).
- Supports theming via `themeProvider` and custom widgets (`CustomButton`, `CustomTextField`).
- Utilises Riverpod for dependency injection and state management across the codebase.

## System Architecture

```mermaid
flowchart TB
    subgraph UI [User Interface]
        direction TB
        MainScreen[MainScreen]
        AnalyticsScreen[AnalyticsScreen]
        HistoryScreen[HistoryScreen]
        SettingsSection[SettingsSection]
    end

    subgraph StateManagement [State Management]
        direction TB
        Riverpod[Riverpod Providers]
        AnalyticsController[AnalyticsController]
        SalesEntryController[SalesEntryController]
    end

    subgraph DataLayer [Data Layer]
        direction TB
        DriftDB[Drift (SQLite) DB]
        SalesEntryDao[SalesEntryDao]
        AppDatabase[AppDatabase]
    end

    subgraph NativeIntegration [Native Integration]
        direction TB
        WndProc[WndProc]
        MessageHandler[MessageHandler]
        Create[Create]
        Destroy[Destroy]
    end

    UI -->|uses| StateManagement
    StateManagement -->|calls| DataLayer
    UI -->|triggers| NativeIntegration
    NativeIntegration -->|provides| Window APIs
    DataLayer -->|stores| SalesEntry
    StateManagement -->|updates| UI
```

## Key Components

- **`Create()` / `Destroy()`** – Entry points for window lifecycle management.
- **`MessageHandler()`** – Central dispatcher for Windows messages.
- **`themeProvider`** – Global theming system.
- **`SalesEntryDao` & `AppDatabase`** – Persistence layer using Drift.
- **`AnalyticsController`** – Business logic for analytics calculations.
- **Custom Widgets** – `CustomButton`, `CustomSuggestionField`, `CustomTextField` for consistent UI.

---

*Developed by **Mohammed Rafi H***