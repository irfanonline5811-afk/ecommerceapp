# My Store - Flutter E-Commerce Application 🛍️

A modern, responsive E-Commerce application built with **Flutter**, featuring a hybrid architecture that seamlessly blends the **FakeStore REST API** with **Google Firebase** (Cloud Firestore & Firebase Storage).

---

## 📱 Features

- **🛍️ Dynamic Product Catalog (Home Screen)**
  - Displays products in a responsive grid layout.
  - Combines items from **FakeStore API** with real-time user-added items from **Firebase Firestore**.
  - Pull-to-refresh support to sync latest data.

- **📂 Category Browsing & Filtering**
  - Explore product categories (`electronics`, `jewelery`, `men's clothing`, `women's clothing`).
  - View category-filtered products combining both FakeStore API and newly added Firestore products in real time.

- **➕ Add New Product**
  - Add products with Name, Price, Description, and Category selection.
  - Pick images directly from device **Gallery** or provide a direct **Image URL**.
  - Images are uploaded and stored with instant real-time synchronization to Firestore.

- **🔍 Product Detail View**
  - Detailed product screen with image preview, full description, category, and formatted pricing.

- **✏️ Update & 🗑️ Delete Products**
  - Update product title and price with instant UI reflection.
  - Delete products (persists deletion state across app sessions).

- **⚡ Real-time Synchronization**
  - Powered by Firestore `StreamBuilder`, new products appear instantly on Home and Category pages without needing an app restart.

---

## 🛠️ Tech Stack & Packages

| Technology / Package | Purpose |
| :--- | :--- |
| **Flutter & Dart** | Cross-platform UI toolkit (SDK `^3.8.1`, Material 3 enabled) |
| **`http`** | REST API communication with FakeStore API |
| **`cloud_firestore`** | Cloud database for real-time products & persistent deletions |
| **`firebase_storage`** | Cloud storage for uploaded product images |
| **`firebase_core`** | Firebase initialization & cross-platform configuration |
| **`image_picker`** | Image selection from mobile/desktop gallery |

---

## 📂 Project Architecture & Directory Structure

```
ecommerceapp/
├── android/                         # Android native configurations
├── ios/                             # iOS native configurations
├── web/                             # Flutter Web configurations
├── windows/                         # Windows desktop configurations
├── lib/
│   ├── firebase_options.dart        # Platform-specific Firebase credentials
│   ├── main.dart                    # App entry point, Firebase init & ThemeData
│   │
│   ├── models/
│   │   └── product_model.dart       # ProductModel with JSON deserialization
│   │
│   ├── services/
│   │   └── product_service.dart     # FakeStore API client & Firebase Firestore/Storage services
│   │
│   ├── pages/
│   │   ├── home_page.dart           # Home catalog with combined API & Firestore Stream
│   │   ├── category_page.dart       # Categories list view
│   │   ├── products_by_category_page.dart # Category-filtered products
│   │   ├── product_detail_page.dart # Product details, update & delete
│   │   └── add_product_page.dart    # Add product form with image picker
│   │
│   └── widgets/
│       └── product_card.dart        # Reusable product grid card component
└── pubspec.yaml                     # Project dependencies & metadata
```

---

## 🔄 How It Works (Data Flow)

```
[FakeStore API] ─────────┐
                         ▼
                   [Home Page] ◄──── [Firestore Stream]
                         ▲                      ▲
                         │                      │
               [Product Detail] ──── [Add Product Page]
               (Update / Delete)     (Image + Form Data)
```

1. **Initial Seed Data**: Pre-loaded catalog items and categories are fetched from `https://fakestoreapi.com`.
2. **User Additions**: When a user creates a new product in `AddProductPage`, the image is processed and the complete product document is added to Firestore's `products` collection.
3. **Real-time Streaming**: `HomePage` and `ProductsByCategoryPage` listen to Firestore streams via `StreamBuilder`, automatically merging user products at the top of the list.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.8.1`)
- [Git](https://git-scm.com/)
- An Android Device, Emulator, or Chrome Browser

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/irfanonline5811-afk/ecommerceapp.git
   cd ecommerceapp
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   - On an Android Emulator / Physical Device:
     ```bash
     flutter run
     ```
   - In Chrome browser:
     ```bash
     flutter run -d chrome
     ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
