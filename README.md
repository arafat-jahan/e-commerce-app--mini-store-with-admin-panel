# 🛍️ Mini Store

> A production-ready **Flutter e-commerce app** powered by Firebase — featuring a premium dark UI, smooth animations, real-time data, and a full admin dashboard.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📱 Screenshots

### Authentication
|  Register | Login |
|:-----:|:--------:|
| <img src="https://i.imgur.com/q237rNa.jpeg" width="220"/> | <img src="https://i.imgur.com/Oo37kvS.jpeg" width="220"/> |

### Shopping
| Shop | Search | Product Detail |
|:----:|:------:|:--------------:|
| <img src="screenshots/03_shop.jpg" width="180"/> | <img src="screenshots/04_search.jpg" width="180"/> | <img src="screenshots/05_product_detail.jpg" width="180"/> |

### Ordering
| Cart | Checkout | Orders |
|:----:|:--------:|:------:|
| <img src="screenshots/06_cart.jpg" width="180"/> | <img src="screenshots/07_checkout.jpg" width="180"/> | <img src="screenshots/08_orders.jpg" width="180"/> |

### Account
| Order Detail | Profile |
|:------------:|:-------:|
| <img src="screenshots/09_order_detail.jpg" width="220"/> | <img src="screenshots/10_profile.jpg" width="220"/> |

### Admin Dashboard
| Dashboard | Products | Add Product |
|:---------:|:--------:|:-----------:|
| <img src="screenshots/11_admin_dashboard.jpg" width="180"/> | <img src="screenshots/12_admin_products.jpg" width="180"/> | <img src="screenshots/13_admin_add_product.jpg" width="180"/> |

| Orders | Order Detail | Users |
|:------:|:------------:|:-----:|
| <img src="screenshots/14_admin_orders.jpg" width="180"/> | <img src="screenshots/15_admin_order_detail.jpg" width="180"/> | <img src="screenshots/16_admin_users.jpg" width="180"/> |

---

## ✨ Features

### 🛒 Customer
- Browse products with search & category filter
- Product detail with hero animation & price counter
- Shopping cart with quantity controls
- Checkout with Cash on Delivery (COD)
- Real-time order tracking with status badges
- User profile management

### 👑 Admin
- Dashboard — orders, products, revenue, pending count
- Products — add, edit, delete with image upload to Firebase Storage
- Orders — view all orders, update status (pending → confirmed → shipped → delivered)
- Users — manage roles (admin / customer)

### 🎨 UI & Animations
- Premium dark theme with blue accent
- Glassmorphism input fields
- Glow buttons with shadow effects
- Radial gradient backgrounds
- Staggered product card animations
- Hero image transitions
- Price counter animation on product detail
- Add to cart color feedback (blue → green ✅)
- Animated splash screen with pulsing logo
- Smooth page transitions throughout

---

## 🏗️ Architecture

```
lib/
├── main.dart
├── firebase_options.dart
└── src/
    ├── app.dart
    └── features/
        ├── auth/          # Login · Register · Auth Gate
        ├── catalog/       # Shop · Product Detail
        ├── cart/          # Cart screen
        ├── checkout/      # Checkout screen
        ├── orders/        # Order history & detail
        ├── profile/       # User profile
        ├── admin/         # Admin dashboard
        └── home/          # Navigation shell
```

**Pattern:** Feature-first · Provider state management · Repository pattern

---

## 🔥 Firebase Setup

### Firestore Collections

| Collection | Fields |
|------------|--------|
| `users` | `email`, `role`, `displayName`, `phone`, `city`, `defaultAddress` |
| `products` | `name`, `price`, `category`, `stock`, `imageUrl`, `description`, `isActive` |
| `orders` | `userId`, `items`, `total`, `status`, `shippingAddress`, `createdAt`, `cod` |

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /users/{userId} {
      allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId || isAdmin();
    }
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    match /orders/{orderId} {
      allow read: if isSignedIn() &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isSignedIn() &&
        request.resource.data.userId == request.auth.uid;
      allow update: if isAdmin();
    }
  }
}
```

### Required Composite Index

```
Collection : orders
Fields     : userId (Ascending), createdAt (Descending)
```

> Firebase Console → Firestore → Indexes → Add composite index

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.x`
- Firebase project with Firestore & Authentication enabled

### Installation

```bash
# Clone
git clone https://github.com/your-username/mini_store.git
cd mini_store

# Install dependencies
flutter pub get

# Run
flutter run
```

### Firebase Configuration

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `firebase_core` | Firebase init |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | Image storage |
| `cached_network_image` | Image caching |
| `image_picker` | Gallery picker |
| `intl` | Date formatting |
| `uuid` | Unique IDs |

---

## 👤 Admin Setup

1. Register an account in the app
2. Go to **Firebase Console → Firestore → users**
3. Find your document → change `role` to `"admin"`
4. Sign out → sign back in
5. **Admin tab** appears in bottom navigation ✅

---

## 🗂️ Seed Products

Populate Firestore with 30 sample products:

```bash
flutter run -t lib/seed_products.dart
```

Categories: `Electronics` · `Clothing` · `Home` · `Accessories`

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

<p align="center">Built with ❤️ using Flutter & Firebase</p>
