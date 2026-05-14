# 🚗 Car Rental Application

Aplikasi Car Rental adalah sebuah aplikasi mobile Flutter yang dirancang untuk memudahkan pengguna dalam melakukan pemesanan kendaraan dengan antarmuka yang user-friendly dan fitur-fitur modern.

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Requirements](#-requirements)
- [Instalasi](#-instalasi)
- [Cara Penggunaan](#-cara-penggunaan)
- [Struktur Project](#-struktur-project)
- [Dependencies](#-dependencies)

## ✨ Fitur Utama

- ✅ Search daftar kendaraan
- ✅ Refresh Token
- ✅ Penyimpanan data lokal dengan SharedPreferences
- ✅ Integrasi API untuk data real-time

## 📦 Requirements

Pastikan Anda telah menginstal:

- **Flutter SDK** v3.8.1 atau lebih tinggi
- **Dart** v3.8.1 atau lebih tinggi
- **Android Studio** atau **Xcode** (untuk development)
- **Git**

### Cek Instalasi Flutter:
```bash
flutter --version
dart --version
```

## 🚀 Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/HarsaIlham/modul_6_car_rental.git
cd modul_6_car_rental
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
```bash
# Run di emulator/device yang sudah tersedia
flutter run

# Untuk mempeprcepat run projek bisa menggunakan
flutter run -d web-server
# Nanti bakal muncul URL tinggal buka di browser

# Atau untuk platform tertentu
flutter run -d chrome          # Web
flutter run -d emulator-id     # Android Emulator
flutter run -d simulator       # iOS Simulator
```

## 📱 Cara Penggunaan

1. **Membuka Aplikasi**: Jalankan aplikasi menggunakan perintah `flutter run`
2. **Browse Kendaraan**: Lihat daftar kendaraan yang tersedia
3. **Kelola Kendaraan**: Pilih kendaraan dan isi form booking
4. **Role Based Access Control**: Perbedaan hak akses fitur setiap role
5. **Penyimpanan Data**: Data disimpan secara lokal di device menggunakan SharedPreferences

## 📁 Struktur Project

```
modul_6_car_rental/
├── lib/                        # Folder utama source code
│   ├── main.dart              # Entry point aplikasi
│   ├── screens/               # UI screens/pages
│   ├── models/                # Data models
│   ├── services/              # API dan business logic
│   └── widgets/               # Reusable widgets
├── test/                       # Unit dan widget tests
├── android/                    # Konfigurasi Android
├── ios/                        # Konfigurasi iOS
├── web/                        # Konfigurasi Web
├── pubspec.yaml                # Dependencies dan konfigurasi
└── README.md                   # File ini
```

## 📚 Dependencies

Project ini menggunakan dependencies berikut:

```yaml
- cupertino_icons: ^1.0.8      # Icons untuk iOS style
- shared_preferences: ^2.5.5   # Local storage/caching
- http: ^1.3.0                 # HTTP client untuk API
- flutter_lints: ^5.0.0        # Lint rules
```

Untuk melihat semua dependencies, cek file `pubspec.yaml`.



**Dibuat oleh:** [HarsaIlham](https://github.com/HarsaIlham)  
**Dibuat pada:** 2026  
**Status:** Active Development

⭐ Jika project ini membantu, jangan lupa untuk memberikan star! ⭐
