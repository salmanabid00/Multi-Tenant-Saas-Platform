# Nexus SaaS Platform 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.27-%2302569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-green)](#architecture)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **A production-grade Multi-Tenant SaaS application built with Flutter & Firebase.**  
> Designed to demonstrate enterprise scalability, strict data isolation, and role-based access control (RBAC).

---

## 📱 Project Overview

**Nexus SaaS** is a robust boilerplate for building Scalable Software-as-a-Service platforms. It solves the complex challenges of multi-tenancy—allowing users to create organizations, manage memberships, and access isolated data environments—all within a single codebase.

It serves as a reference implementation for **Staff/Principal-level Flutter architecture**, focusing on maintainability, security, and developer experience.

---

## ✨ Key Features

### 🏢 Multi-Tenancy & Isolation
- **Logical Isolation**: All data is strictly scoped to `tenantId`. A user in "Org A" cannot access "Org B" data.
- **Context Switching**: Seamlessly switch between organizations with real-time state updates.
- **Dynamic Context**: The entire app adapts (UI, Permissions, Queries) based on the active tenant.

### 🔐 Authentication & Security
- **Firebase Auth**: Secure Email/Password registration and login.
- **RBAC (Role-Based Access Control)**: Granular permissions for `Owner`, `Admin`, `Member`, and `Viewer`.
- **Zero-Trust Security Rules**: Firestore security rules that enforce tenant ownership on every read/write.
- **Splash Screen**: Secure initialization flow that verifies auth state and routes users appropriately.

### 💳 Subscription Management
- **Tiered Plans**: Support for `Free`, `Pro`, and `Enterprise` tiers.
- **Feature Gating**: Logic to lock/unlock features (e.g., Export Data, Audit Logs) based on the active plan.
- **Usage Limits**: Enforce storage and member limits per plan.

### 🎨 UI/UX Excellence
- **Modern Design System**: Custom `ThemeData` with professional typography and color palettes (Royal Blue & Slate).
- **Responsive Layouts**: Optimized for Mobile and Web.
- **Polished Animations**: Smooth transitions and loading states.
- **Interactive Dashboard**: Real-time stats and "Quick Actions" for better usability.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Mobile, Web, Desktop)
- **Backend**: [Firebase](https://firebase.google.com) (Auth, Firestore, Cloud Functions)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Dependency Injection**: GetX Bindings
- **Functional Programming**: [dartz](https://pub.dev/packages/dartz) (Either type for error handling)
- **Routing**: GetX Named Routes
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)

---

## 🏗️ Architecture

The project follows a **Feature-First Clean Architecture** structure, ensuring separation of concerns and scalability:

```
lib/
├── core/                   # Global utilities, errors, services
│   ├── di/                 # Dependency Injection setup
│   ├── services/           # Global services (TenantService, SubscriptionService)
│   └── error/              # Failure definitions
├── features/               # Feature modules
│   ├── splash/             # Startup logic & animation
│   ├── auth/               # Authentication (Login, Register)
│   ├── tenant/             # Organization management
│   ├── dashboard/          # Main UI shell
│   └── projects/           # Domain feature (demonstrates isolation)
│       ├── data/           # Repositories & Models
│       ├── domain/         # Entities & UseCases
│       └── presentation/   # Controllers & UI
└── main.dart               # Entry point
```

---


## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x+)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Installation

1. **Clone the repository**
   ```bash
   https://github.com/salmanabid00/Multi-Tenant-Saas-Platform

   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a project in the Firebase Console.
   - Enable **Authentication** (Email/Password).
   - Enable **Firestore Database**.
   - Run `flutterfire configure` to generate `firebase_options.dart`.

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🗄️ Database Schema (Firestore)

The database is designed to minimize read costs while ensuring security.

- **`tenants/{tenantId}`**
  - Stores org metadata, subscription plan, and settings.
- **`tenant_users/{tenantId_uid}`**
  - **Composite Key**: Enables fast lookup of "My Role in this Tenant".
  - Stores `role` (admin/member/viewer).
- **`projects/{projectId}`**
  - **Tenant Scoped**: Contains `tenantId` field.
  - Queries are always filtered by `where('tenantId', isEqualTo: activeTenantId)`.

---

## 🔮 Future Roadmap

- [ ] **Stripe Integration**: Connect Cloud Functions to Stripe Webhooks for real billing.
- [ ] **User Invites**: SendGrid integration to invite members via email.
- [ ] **Team Chat**: Real-time messaging within tenants.
- [ ] **Mobile & Desktop Support**: Fully responsive layout adjustments for Tablet/Desktop.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) to learn how to propose changes.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
