# Project 6: Gift / Souvenir Collection (Khmer Cultural Theme)

This project is a full-stack application for browsing and ordering handmade gifts, souvenirs, and cultural items from Cambodia. It features a festive, warm aesthetic with Khmer cultural motifs.

## 🏗 Architecture & Tech Stack

### Frontend (Souvenir_Collection_Frontend)
- **Framework:** Flutter 3.x / Dart 3.x
- **UI Design:** Material 3, Festive theme (Warm earth tones + Gold accents), Khmer motifs.
- **State Management:** BLoC (as evidenced by `lib/blocs` structure).
- **Navigation:** `go_router`
- **Local Storage:** `shared_preferences` (for favorites).
- **Maps:** `flutter_map` with dynamic markers fetched from the backend (no hardcoded locations).
- **Assets:** Core branding/motifs as bundled assets; dynamic content (products, artisans, reviews) via `cached_network_image` from backend URLs.

### Backend (Sovenire_Collenction_Backend)
- **Framework:** .NET 10 Web API
- **Database:** SQL Server via Entity Framework Core.
- **Real-time:** SignalR (for Chat and Notifications).
- **Mapping:** AutoMapper for DTO to Model conversions.
- **Validation:** FluentValidation.
- **Storage/Services:** Supabase integration.
- **Logging:** Serilog.

## 🎨 UI/UX Guidelines
- **Theme:** "Festive" - Warm earth tones with gold accents.
- **Cultural Identity:** Use Khmer/Cambodian motifs (e.g., Krama patterns, Angkorian ornaments) in icons, SVGs, and backgrounds.
- **Responsive:** Must work seamlessly on both phone (portrait) and tablet.
- **Interactions:** Smooth Hero transitions, page transitions, and list animations.
- **Components:** Reusable widgets in `lib/core/widgets/` (cards, buttons, rating stars, etc.).

## 🚀 Key Features & Screens
- **Story-style Home:** Instagram-story style vertical hero ("Crafted in Cambodia").
- **Product Discovery:** Categories (Textile, Silver, Wood, Jewelry), curated collections, and featured artisans.
- **Artisan Focus:** Detailed artisan profiles including their story and region.
- **Order Flow:** Item → Gift wrap selection → Personal message → Delivery date → Confirmation.
- **Engagement:** Chat with artisans, Reviews with photos, and a **Gift Finder Quiz** (4 questions).
- **Maps:** "Nearby" shops/ateliers with cultural pin icons.

## 📦 Universal Deliverables
- **App Theme:** Light and Dark modes with custom color palette (Earth tones + Gold).
- **Typography:** Consistent use of brand fonts.
- **Brand Assets:** App icon and splash screen.
- **Navigation:** Bottom navigation bar (4 primary tabs) or navigation drawer.
- **Onboarding:** 3-slide onboarding screen on first launch.
- **States:** Empty states, loading shimmers, and error placeholder widgets.
- **Animations:** Hero transitions, page transitions, and list animations.
- **Responsiveness:** Phone portrait and tablet support.

## 📱 Common Screen Specifications
- **Home:** Hero banner/carousel, categories grid, featured items, search bar, promotions strip.
- **Product Detail:** Image gallery (PageView), title, price/rating, description, specs/options, "Add to favorite", primary CTA.
- **Favorites:** Saved items list, swipe-to-remove, persisted via shared_preferences.
- **Map / Locations:** `flutter_map` with dynamic markers, bottom sheet with branch info, "Get directions".
- **Nearby:** Branch list sorted by mock distance, filter chips (open now, distance, rating).
- **Promotions & Coupons:** Coupon cards with code, expiry, "Copy code", "Use now".
- **Booking Flow:** Multi-step form (Service/Item → Date/Time → Summary/Confirmation).
- **Chat:** Chat list + thread UI, mock auto-reply after 1s (if needed for demo), typing indicators.
- **Reviews:** Star rating summary, distribution bars, review cards, "Write a review" form.
- **Photos/Videos:** Masonry grid gallery, full-screen viewer with pinch-zoom, video thumbnails.

## 🛠 Development Mandates
- **No Mock Data:** Always use the .NET backend for data fetching. Do not create static mock lists unless the backend endpoint is not yet available (and then, coordinate with backend).
- **Clean Architecture:** Maintain separation between Blocs, Services, and UI.
- **Type Safety:** Ensure strict typing in both Dart and C#.
- **Standardized Responses:** Backend must return `ApiResponse<T>` or `PagedResult<T>` as defined in `Helpers/`.
- **Validation:** Every change must be validated against existing tests or by adding new ones.

## 📂 Folder Structure Highlights
- `lib/blocs/`: State management logic.
- `lib/core/`: Constants, themes, utils, and global widgets.
- `lib/features/`: Feature-sliced UI components.
- `lib/services/`: API client and business logic services.
- `Controllers/`: .NET API endpoints.
- `DTOs/`: Data Transfer Objects for API contracts.
- `Models/`: Database entities.
- `Hubs/`: Real-time SignalR hubs.
