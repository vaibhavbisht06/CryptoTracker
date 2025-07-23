# 📈 CryptoTracker

A lightweight SwiftUI-based cryptocurrency tracking app that lists real-time prices of top 20 coins, with watchlist support and dark mode toggle.

![SwiftUI](https://img.shields.io/badge/SwiftUI-compatible-blue.svg)
![iOS](https://img.shields.io/badge/iOS-18%2B-blue.svg)

---

## 🎬 Demo

🔗 [Watch App Demo](https://drive.google.com/file/d/1Z64UqtXTYVbAqAzXEWuapKWTzUC3OWRV/view?usp=sharing)

---

## 🚀 Features

### 🪙 1. Crypto Listing
- Lists 20 cryptocurrencies.
- Pull-to-refresh support.
- Live search functionality (filter by name).
- Auto-refresh coin prices every 60 seconds in the background.
- Swipe actions:
  - Add coin to **Watchlist**
  - Remove coin from **Watchlist**

### ⭐ 2. Watchlist
- Displays only selected (favorited) cryptocurrencies.
- Swipe to delete individual coins.
- Auto-refreshes prices every 60 seconds.

### ⚙️ 3. Settings
- Toggle between Light / Dark Mode.
- Clear entire watchlist with one tap.

---

## 📲 Setup Instructions

1. **Download or clone** the repository.
2. **Open the `.xcodeproj`** file using Xcode.
3. Build & run the app using **Xcode 15+**.
4. Ensure your development target is **iOS 18 or higher**.

---

## 🛠 Platform & Tech

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Networking:** `URLSession` via a reusable `APIHelper` class
  - ⚠️ The `APIHelper` is a custom utility used across my projects for making native network calls easily.

---

## 🧠 Design Inspiration

The app’s UI and UX are inspired by a mix of:
- Previous projects I’ve worked on.
- My own imagination and experience using MF and equity tracking tools.

The goal was to keep the design clean, simple, and functional with minimal distractions.

---

## 🗒 Notes

- Coin data is fetched from [CoinGecko API](https://www.coingecko.com/en/api/documentation).
- Watchlist is persisted locally using `UserDefaults`.
- The coin price refresh is efficient — it uses a separate endpoint that updates only the price without blocking the UI or fetching redundant data.
