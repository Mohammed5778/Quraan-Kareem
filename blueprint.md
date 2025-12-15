# Quran App Blueprint

## Overview

This document outlines the plan for building a comprehensive Quran application using Flutter. The application will provide a rich user experience with features for reading, listening, and studying the Quran, along with other Islamic utilities.

## Style, Design, and Features (v1 - Initial Setup)

### Core Architecture
- **State Management:** Provider
- **Dependency Management:** All necessary packages for UI, services, and features will be added.
- **Project Structure:** A well-organized, feature-first directory structure.
- **Services:** Foundational services for API communication, local storage, notifications, and audio will be established.

### Theming & UI
- **Material 3:** The app will use Material 3 design principles.
- **Themes:** Light, Dark, and Sepia themes will be available.
- **Typography:** `google_fonts` with 'Noto Naskh Arabic' for beautiful Arabic script rendering.
- **Localization:** The app will be set up for both Arabic (RTL) and English (LTR) languages.

## Current Plan: Initial Project Scaffolding

1.  **Add Dependencies:** Install all the required packages from `pub.dev`.
2.  **Establish Project Structure:** Create all the directories (`config`, `models`, `services`, `providers`, `screens`, `widgets`).
3.  **Implement Core Models:** Create the Dart classes for `Surah`, `Verse`, `Adhkar`, `Reciter`, and `KhatmahGoal`.
4.  **Implement Core Services:**
    *   `StorageService`: For saving user preferences and data locally.
    *   `ApiService`: For fetching data from external APIs.
    *   Create placeholder files for other services (`AudioService`, `NotificationService`, `PrayerTimesService`).
5.  **Implement Core Provider:** Create the `AppProvider` to manage application-wide state like theme and language.
6.  **Set Up Main Application:**
    *   Update `main.dart` to initialize all services.
    *   Create `app.dart` to define the `MaterialApp` and handle theme/locale switching.
7.  **Create Placeholder Screens & Widgets:** Create empty `StatelessWidget` files for all the screens and widgets outlined in the project structure. This will make the project ready for UI implementation.
