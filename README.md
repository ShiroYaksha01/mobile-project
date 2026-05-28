# Project 6 — Gift / Souvenir Collection (Festive & Cultural Khmer)

A full-stack mobile application to browse and order handmade gifts, souvenirs, and cultural items from Cambodia.

## 📅 2-Week Scrum Schedule (June 1 - June 12, 2026)

### Sprint 1: Core Foundation & Product Discovery
**Goal:** Functional App with Authentication and Product Browsing.

| Date | Backend (1 Dev) | Frontend A (UI/UX) | Frontend B (Logic/Integration) |
| :--- | :--- | :--- | :--- |
| **Mon, June 1** | Database Setup, Auth Models & JWT | App Theme, Splash, Onboarding | Project Structure & API Client Setup |
| **Tue, June 2** | Product & Category APIs | Home Screen (Story Hero) | Auth BLoC & Screen Integration |
| **Wed, June 3** | Artisan & Collection APIs | Product Detail Screen | Product BLoC & List Integration |
| **Thu, June 4** | Favorites & Cart APIs | Artisan Profile UI | Category & Collection Integration |
| **Fri, June 5** | **Sprint Review:** Stable API v1 | Map & Nearby UI | Favorites & Cart BLoC Logic |

### Sprint 2: Transactions, Engagement & Polish
**Goal:** Order Flow, Chat, and Khmer Cultural Refinement.

| Date | Backend (1 Dev) | Frontend A (UI/UX + Polish) | Frontend B (Complex Logic) |
| :--- | :--- | :--- | :--- |
| **Mon, June 8** | Order & Payment Status APIs | Booking/Order Flow UI | Order BLoC & Checkout Integration |
| **Tue, June 9** | SignalR Chat & Notifications | Gift Finder Quiz UI | Chat Thread Logic & Quiz Logic |
| **Wed, June 10** | Reviews & Media Assets APIs | Review UI & Video Player | Reviews Integration & Media Gallery |
| **Thu, June 11** | Bug Fixes & API Optimization | Khmer Motif Icons/SVGs & Polish | Error Handling & Performance Tuning |
| **Fri, June 12** | **Final Demo:** Clean-up | Responsive Testing (Tablet) | Final Bug Squashing & Handover |

---

## 🏗 Architecture & Tech Stack

### Frontend (Souvenir_Collection_Frontend)
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** BLoC
- **Navigation:** go_router
- **Theme:** Festive (Warm earth tones + Gold accents) with Khmer motifs.

### Backend (Sovenire_Collenction_Backend)
- **Framework:** .NET 10 Web API
- **Database:** SQL Server (via Entity Framework Core)
- **Real-time:** SignalR (Chat & Notifications)
- **Storage:** Supabase Integration

## 🛠 Development Strategy
- **Vertical Slicing:** Complete one feature end-to-end (Backend -> Frontend) before moving to the next.
- **No Mock Data:** All data must be fetched from the .NET backend.
- **Khmer Identity:** Prioritize cultural iconography in the UI.
