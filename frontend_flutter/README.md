# 🍈 Melon Detector - Flutter App

Aplikasi Flutter untuk mendeteksi buah melon menggunakan YOLOv8 Object Detection dengan tampilan bounding box.

## 📱 Fitur

- **Deteksi Melon**: Upload foto dari galeri atau kamera, lalu deteksi otomatis
- **Bounding Box**: Visualisasi hasil deteksi dengan kotak dan label di atas gambar
- **Profil Mahasiswa**: Halaman profil dengan foto, NIM, dan nama
- **Dark/Light Theme**: Dukungan tema gelap dan terang dengan toggle
- **Optimasi Android**: Performa optimal untuk perangkat Android

## 🏗️ Struktur Proyek

```
lib/
├── core/
│   ├── constants/       # Konstanta aplikasi
│   └── theme/           # Tema & warna
├── data/
│   ├── models/          # Model data (Prediction, BoundingBox, dll)
│   └── services/        # API service (Dio)
└── presentation/
    ├── providers/        # State management (Provider)
    ├── screens/          # Halaman UI
    └── widgets/          # Widget reusable
```

## ⚙️ Setup

### 1. Install Dependencies
```bash
flutter pub get

flutter pub run flutter_launcher_icons

dart run launcher_name:main
```

### 2. Tambah Foto Profil
Letakkan foto profil Anda di: `assets/images/profile.jpg`

### 3. Konfigurasi API Endpoint
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5000';
```