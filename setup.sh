#!/bin/bash
# ============================================================
# FashionTrend AI - Setup, Build & Push Script
# ============================================================

set -e

echo "🌟 FashionTrend AI - Setup Guide"
echo "================================="
echo ""

# ============================================================
# STEP 1: PREREQUISITES
# ============================================================
echo "📋 Prerequisites:"
echo "  1. Flutter SDK >= 3.0.0  →  https://flutter.dev/docs/get-started/install"
echo "  2. Android Studio with SDK 34"
echo "  3. Git installed"
echo "  4. Supabase account  →  https://supabase.com (free)"
echo "  5. OpenWeatherMap API key  →  https://openweathermap.org/api (free)"
echo "  6. OpenRouter API key  →  https://openrouter.ai (has free models)"
echo ""

# ============================================================
# STEP 2: INITIAL SETUP
# ============================================================
echo "⚙️  Running Flutter pub get..."
flutter pub get

echo ""
echo "📦 Running build_runner for code generation..."
dart run build_runner build --delete-conflicting-outputs

# ============================================================
# STEP 3: ENVIRONMENT SETUP
# ============================================================
echo ""
echo "🔐 Setting up environment variables..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "  ✅ .env file created from .env.example"
    echo "  ⚠️  IMPORTANT: Edit .env and fill in your actual keys!"
    echo "     nano .env"
else
    echo "  ✅ .env file already exists"
fi

# ============================================================
# STEP 4: SUPABASE SETUP
# ============================================================
echo ""
echo "🗄️  Supabase Setup:"
echo "  1. Go to https://supabase.com and create a new project"
echo "  2. Go to SQL Editor → New Query"
echo "  3. Paste contents of supabase_schema.sql and run it"
echo "  4. Go to Settings → API → Copy your URL and anon key"
echo "  5. Paste them in your .env file"
echo ""
echo "  Storage Buckets (auto-created by SQL schema):"
echo "    - avatars (public)"
echo "    - analysis-images (private)"
echo "    - closet-images (private)"
echo "    - saved-looks (public)"

# ============================================================
# STEP 5: RUN THE APP
# ============================================================
echo ""
echo "▶️  Running the app..."
echo "  Connect a device or start an emulator, then run:"
echo "  flutter run"
echo ""
echo "  Or run on specific device:"
echo "  flutter devices"
echo "  flutter run -d <device_id>"

# ============================================================
# STEP 6: BUILD APK
# ============================================================
echo ""
echo "📱 Building APK..."

build_apk() {
    echo ""
    echo "Building debug APK..."
    flutter build apk --debug
    echo "✅ Debug APK: build/app/outputs/flutter-apk/app-debug.apk"

    echo ""
    echo "Building release APK (universal)..."
    flutter build apk --release --target-platform android-arm,android-arm64,android-x64
    echo "✅ Release APK: build/app/outputs/flutter-apk/app-release.apk"

    echo ""
    echo "Building split APKs by ABI (smaller size)..."
    flutter build apk --split-per-abi --release
    echo "✅ Split APKs in: build/app/outputs/flutter-apk/"
}

# Uncomment to auto-build:
# build_apk

# ============================================================
# STEP 7: GITHUB SETUP
# ============================================================
echo ""
echo "🐙 GitHub Push Instructions:"
echo "================================="
echo ""
echo "1. Create a new GitHub repository:"
echo "   → https://github.com/new"
echo "   → Name: fashiontrend-ai"
echo "   → Visibility: Public or Private"
echo "   → Do NOT initialize with README (we have one)"
echo ""
echo "2. Initialize and push:"
echo "   git init"
echo "   git add ."
echo "   git commit -m '🚀 Initial commit: FashionTrend AI Flutter app'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/YOUR_USERNAME/fashiontrend-ai.git"
echo "   git push -u origin main"
echo ""
echo "3. Verify .env is in .gitignore (it should be!):"
echo "   cat .gitignore | grep .env"
echo ""
echo "✅ Done! Your FashionTrend AI app is ready."
