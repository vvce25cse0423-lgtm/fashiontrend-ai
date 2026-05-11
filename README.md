# 🌟 FashionTrend AI

> **AI-Powered Personal Fashion, Grooming & Lifestyle Assistant**
> Built with Flutter + Supabase · Free & Open Source

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-2.x-3ECF8E?logo=supabase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 App Overview

FashionTrend AI is a complete AI-powered personal styling assistant that helps users look their best every day. Upload a selfie or full-body photo and get instant AI analysis and personalized recommendations.

### ✨ Key Features

| Feature | Description |
|---|---|
| 🤳 AI Selfie Analysis | Detects face shape, skin tone, body type |
| 👗 Outfit Generator | Personalized outfits by occasion & weather |
| 👟 Shoe Recommendations | AI-matched footwear for every look |
| ⌚ Watch Suggestions | From casual to luxury watch pairing |
| 🌸 Perfume Guide | Scent recommendations by mood & occasion |
| 💇 Hairstyle AI | Face-shape based hair suggestions |
| 🏆 Fashion Score | Rate and improve your style out of 100 |
| 👔 Virtual Closet | Manage and organize your wardrobe |
| 💬 AI Stylist Chat | Real-time fashion advice chatbot |
| ❤️ Saved Looks | Save and share your favourite outfits |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── errors/         # Error handling
│   ├── router/         # GoRouter navigation
│   └── utils/          # Utility functions
├── features/
│   ├── auth/           # Login, Register, Onboarding
│   ├── home/           # Dashboard + Shell
│   ├── analysis/       # Photo upload + AI analysis
│   ├── recommendations/# Outfits, Accessories, Score
│   ├── closet/         # Virtual Closet + Saved Looks
│   ├── chatbot/        # AI Stylist Chat
│   ├── profile/        # User Profile
│   └── settings/       # App Settings
├── shared/
│   └── widgets/        # Reusable UI components
└── themes/             # Dark luxury theme
```

**State Management:** Flutter Riverpod
**Navigation:** GoRouter
**Backend:** Supabase (Auth + PostgreSQL + Storage)
**AI Chat:** OpenRouter (free Llama 3.1 model)

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ≥ 3.0.0 (stable channel)
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- A Supabase account (free tier works!)

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/fashiontrend-ai.git
cd fashiontrend-ai
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

1. Go to [supabase.com](https://supabase.com) → Create New Project
2. Open **SQL Editor** → paste contents of `supabase_schema.sql` → Run
3. Copy your **Project URL** and **anon key** from Settings → API

### 4. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env`:
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
WEATHER_API_KEY=your-openweathermap-key
OPENROUTER_API_KEY=your-openrouter-key
```

#### Getting Free API Keys:
- **OpenWeatherMap**: [openweathermap.org/api](https://openweathermap.org/api) → Free tier
- **OpenRouter** (AI Chat): [openrouter.ai](https://openrouter.ai) → Free Llama 3.1 model

### 5. Run the App

```bash
# Development
flutter run

# Specific device
flutter run -d android
flutter run -d ios
```

---

## 📦 Build APK (Android)

### Debug APK (for testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for distribution)
```bash
# First, create a keystore if you don't have one:
keytool -genkey -v -keystore ~/fashiontrend.keystore \
  -alias fashiontrend -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
flutter build apk --release

# Or build a universal APK (single file for all architectures)
flutter build apk --release --split-per-abi
# Outputs:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (32-bit)
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (64-bit)
# build/app/outputs/flutter-apk/app-x86_64-release.apk       (x86)
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🐙 GitHub Push Instructions

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "🚀 Initial commit: FashionTrend AI"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/fashiontrend-ai.git
git branch -M main
git push -u origin main
```

### Create `.gitignore`
Make sure `.env` is in `.gitignore` (never push API keys!):
```
.env
*.keystore
*.jks
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
```

---

## 🗄️ Supabase Setup Details

### Tables Created
| Table | Purpose |
|---|---|
| `profiles` | User profile data and style preferences |
| `ai_analyses` | Photo analysis results |
| `recommendations` | AI outfit and style recommendations |
| `closet_items` | Virtual wardrobe items |
| `saved_looks` | User's saved outfit combinations |
| `chat_messages` | AI stylist chat history |
| `notifications` | In-app notifications |

### Storage Buckets
| Bucket | Access | Purpose |
|---|---|---|
| `avatars` | Public | Profile pictures |
| `analysis-images` | Private | Uploaded photos |
| `closet-images` | Private | Wardrobe photos |
| `saved-looks` | Private | Saved look cards |

---

## 📱 Screens

1. **Splash Screen** — Animated logo with gold gradient
2. **Onboarding** — 3-page feature showcase
3. **Login / Register** — Glassmorphism auth forms
4. **Forgot Password** — Email reset flow
5. **Home Dashboard** — Style score, quick actions, trends
6. **Upload Photo** — Camera/gallery with tips
7. **AI Analysis** — Step-by-step scanning animation + results
8. **Outfit Recommendations** — Tabbed: For You / Trending / Celebrity
9. **Accessories** — Tabbed: Shoes / Watches / Perfume
10. **Fashion Score** — Circular score + category breakdown
11. **Virtual Closet** — Grid wardrobe management
12. **Saved Looks** — Swipe-to-delete saved outfits
13. **AI Chatbot** — Real-time AI fashion assistant
14. **Profile** — Stats, preferences, account settings
15. **Settings** — Notifications, location, app preferences

---

## 🎨 Design System

- **Theme**: Dark luxury with gold (#D4A843) accents
- **Typography**: Playfair Display (headings) + DM Sans (body)
- **Style**: Glassmorphism cards, gradient buttons
- **Animations**: flutter_animate with slide, fade, scale effects
- **Color Palette**:
  - Background: `#0A0A0F`
  - Cards: `#141420`
  - Gold: `#D4A843`
  - Purple: `#8B5CF6`
  - Pink: `#EC4899`

---

## 🔧 Key Packages

```yaml
supabase_flutter: ^2.3.4     # Backend
flutter_riverpod: ^2.5.1     # State management
go_router: ^13.2.0           # Navigation
google_fonts: ^6.2.1         # Typography
flutter_animate: ^4.5.0      # Animations
image_picker: ^1.0.7         # Photo selection
shimmer: ^3.0.0              # Loading states
flutter_dotenv: ^5.1.0       # Environment variables
cached_network_image: ^3.3.1 # Image caching
http: ^1.2.1                 # HTTP requests
```

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — free for personal and commercial use.

---

## 👨‍💻 Built with ❤️ by a student developer

> This is a free, open-source project. If you find it useful, ⭐ star the repo!

**Tech Stack**: Flutter · Dart · Supabase · OpenRouter AI · OpenWeatherMap
