# Avukatım - Legal Services & Chat Platform ⚖️

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)

Welcome to the official repository for **Avukatım**, a comprehensive mobile application designed to connect users with legal professionals. This platform provides a seamless interface for user authentication, profile management, real-time chat, and case tracking.

---

## 📝 Table of Contents

- [📌 About The Project](#-about-the-project)
- [✨ Key Features](#-key-features)
- [🛠️ Technology Stack](#️-technology-stack)
- [📂 Architecture Overview](#-architecture-overview)
- [🚀 Getting Started](#-getting-started)
- [🤝 Contributing](#-contributing)

---

## 📌 About The Project

Avukatım (Turkish for "My Lawyer") was developed to bridge the gap between individuals seeking legal advice and qualified lawyers. The application offers a secure and user-friendly environment where users can sign up, create a detailed profile, find legal experts, engage in real-time conversations, and manage their legal cases. The entire system is powered by Firebase, ensuring a robust and scalable backend infrastructure.

---

## ✨ Key Features

-   **Secure Authentication:** Multiple sign-up and login options, including email/password and phone number verification, all handled by Firebase Auth.
-   **Onboarding Experience:** A smooth and informative onboarding process for new users.
-   **User Profiles:** Comprehensive user profiles where individuals can manage their personal information.
-   **Lawyer Profiles:** Dedicated views for lawyers to showcase their expertise and information.
-   **Real-Time Chat:** A secure, one-on-one chat feature allowing users to communicate directly with legal professionals.
-   **Find Users/Lawyers:** Functionality to search and connect with other users or lawyers on the platform.
-   **Case Management:** A dedicated section (`lewsuit_case_view`) for users to track the status and details of their legal cases.
-   **Push Notifications:** Integrated notifications to keep users updated on new messages and case updates.
-   **Custom UI Components:** A consistent and clean user interface built with reusable custom widgets.

---

## 🛠️ Technology Stack

This application is built with a modern, cross-platform technology stack.

-   **Core Framework:** [Flutter](https://flutter.dev/)
-   **Programming Language:** [Dart](https://dart.dev/)
-   **Backend & Services:** [Firebase](https://firebase.google.com/)
    -   **Authentication:** Firebase Auth for user management.
    -   **Database:** Cloud Firestore for real-time data storage (chats, user info, cases).
    -   **Push Notifications:** Firebase Cloud Messaging (FCM).
-   **State Management:** Standard Flutter state management (`StatefulWidget`, `Provider`).

---

## 📂 Architecture Overview

The project is structured with a focus on scalability and maintainability, separating UI, logic, and services.

```
lib/
├── assets/                 # Static assets like images and fonts
├── common/                 # Core utilities like color extensions
├── common_widget/          # Reusable custom widgets (buttons, text fields)
├── func/                   # Standalone functions (e.g., sending notifications)
├── view/                   # Main application screens (views)
│   ├── login/              # Authentication screens
│   ├── on_bording/         # Initial onboarding flow
│   ├── main_view/          # Home screen and main tab navigation
│   ├── profile/            # User and lawyer profile screens
│   ├── lewsuit/            # Legal case management screens
│   └── realchat_view/      # Real-time chat interface
├── firebase_options.dart   # Firebase project configuration
└── main.dart               # Application entry point
```

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
-   An IDE like [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter support.
-   A configured Firebase project.

### Installation & Launch

1.  **Configure Firebase:**
    -   Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    -   Set up an Android and/or iOS app within your Firebase project.
    -   Replace the contents of `lib/firebase_options.dart` with the configuration generated for your own Firebase project.

2.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/avukatim-app.git](https://github.com/your-username/avukatim-app.git)
    cd avukatim-app
    ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the application:**
    Connect a device or start an emulator and run the app:
    ```bash
    flutter run
    ```

---

## 🤝 Contributing

Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  **Fork** the Project.
2.  Create your Feature Branch (`git checkout -b feature/NewFeature`).
3.  Commit your Changes (`git commit -m 'Add some NewFeature'`).
4.  Push to the Branch (`git push origin feature/NewFeature`).
5.  Open a **Pull Request**.
