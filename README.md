# LinguaSync

LinguaSync adalah aplikasi mobile berbasis **Flutter** yang dirancang sebagai platform pembelajaran bahasa asing interaktif. Aplikasi ini menyediakan materi belajar terstruktur, kuis interaktif, riwayat nilai, leaderboard, serta panel admin untuk mengelola konten pembelajaran.

Proyek ini dibuat untuk memenuhi Project Akhir mata kuliah **Pengembangan Aplikasi Mobile Lanjut (PAML) 2026**.

## Identitas Pengembang

| Keterangan | Detail |
|---|---|
| Nama | Nisrina Salsabila Hikmawan |
| NIM | 20230140054 |
| Mata Kuliah | Pengembangan Aplikasi Mobile Lanjut (PAML) |
| Tahun | 2026 |

---

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Arsitektur dan Teknologi](#arsitektur-dan-teknologi)
- [Struktur Direktori](#struktur-direktori)
- [Panduan Menjalankan Proyek](#panduan-menjalankan-proyek)
- [Product Requirement Document](#product-requirement-document-prd)
- [Log Progress Mingguan](#log-progress-mingguan)

---

## Fitur Utama

### 1. Fitur Pengguna

- **Autentikasi dan Registrasi**  
  Pengguna dapat membuat akun baru dan masuk ke aplikasi menggunakan sistem autentikasi berbasis JWT.

- **Eksplorasi Bahasa**  
  Pengguna dapat melihat daftar bahasa asing yang tersedia untuk dipelajari.

- **My Study**  
  Pengguna dapat memantau bahasa dan modul pembelajaran yang sedang diikuti.

- **Materi Interaktif**  
  Pengguna dapat membaca konten materi dari setiap modul pembelajaran bahasa.

- **Kuis dan Riwayat Nilai**  
  Pengguna dapat mengerjakan kuis interaktif dan meninjau riwayat skor kuis sebelumnya.

- **Global Leaderboard**  
  Pengguna dapat melihat peringkat skor secara global untuk meningkatkan motivasi belajar.

- **Manajemen Profil**  
  Pengguna dapat mengubah data akun, memperbarui kata sandi, dan mengganti foto profil.

### 2. Fitur Admin

- **Dashboard Admin**  
  Admin dapat melihat ringkasan data aplikasi melalui halaman dashboard.

- **Manajemen Pengguna**  
  Admin dapat menambah, mengubah, mencari, dan menghapus data pengguna.

- **Manajemen Bahasa**  
  Admin dapat mengelola katalog bahasa yang tersedia di aplikasi.

- **Manajemen Materi**  
  Admin dapat membuat dan memperbarui modul materi pembelajaran.

- **Manajemen Kuis**  
  Admin dapat mengelola bank soal kuis beserta kunci jawabannya.

- **Manajemen Riwayat Nilai**  
  Admin dapat memantau dan mengelola riwayat aktivitas kuis pengguna.

---

## Arsitektur dan Teknologi

### Frontend Mobile

| Komponen | Teknologi |
|---|---|
| Framework | Flutter |
| Bahasa | Dart |
| State Management | BLoC Pattern |
| Arsitektur | Layered Architecture |
| UI Theme | Japandi Theme |
| Penyimpanan Token | Secure Storage |
| File Upload | File Picker / Image Picker |

Frontend menerapkan arsitektur berlapis yang memisahkan kode menjadi tiga bagian utama:

- **Data Layer**: models, providers, repositories
- **Logic Layer**: events, states, blocs
- **UI Layer**: pages, widgets, theme

### Backend API

| Komponen | Teknologi |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| Database | MySQL |
| ORM | Sequelize |
| Autentikasi | JSON Web Token (JWT) |
| Upload File | Multer |
| Keamanan | Password hashing dan middleware proteksi rute |

Backend menyediakan REST API untuk autentikasi, manajemen bahasa, materi, kuis, riwayat nilai, profil pengguna, dan kebutuhan dashboard admin.

---

## Struktur Direktori

Berikut struktur direktori utama proyek LinguaSync:

```text
linguasync/
├── backend/                         # Backend API server
│   ├── config/                      # Konfigurasi database Sequelize
│   ├── controllers/                 # Logika bisnis API
│   ├── middleware/                  # Middleware validasi dan autentikasi JWT
│   ├── migrations/                  # File migrasi database
│   ├── models/                      # Model database Sequelize
│   ├── routes/                      # Definisi endpoint REST API
│   ├── seeders/                     # Data awal atau data dummy
│   └── server.js                    # Entry point server Node.js
│
├── lib/                             # Source code aplikasi Flutter
│   ├── data/                        # Models, providers, repositories
│   ├── logic/                       # BLoC, events, states
│   └── ui/                          # Tampilan aplikasi
│       ├── pages/                   # Halaman aplikasi
│       ├── theme/                   # Konfigurasi tema visual
│       └── widgets/                 # Komponen UI reusable
│
└── pubspec.yaml                     # Konfigurasi dependency Flutter
```

---

## Panduan Menjalankan Proyek

### Prasyarat

Pastikan perangkat sudah memiliki beberapa kebutuhan berikut:

- Flutter SDK
- Dart SDK
- Node.js dan npm
- MySQL Server
- Sequelize CLI
- Android Studio atau emulator Android
- Perangkat fisik dengan USB Debugging aktif, jika menjalankan aplikasi melalui device langsung

---

### 1. Setup Backend

Masuk ke direktori backend:

```bash
cd backend
```

Install seluruh dependency backend:

```bash
npm install
```

Sesuaikan konfigurasi database pada file berikut:

```text
backend/config/config.js
```

Jalankan migrasi database:

```bash
npx sequelize-cli db:migrate
```

Masukkan data awal atau data demo:

```bash
npx sequelize-cli db:seed:all
```

Jalankan server backend:

```bash
npm start
```

Server backend akan berjalan sesuai konfigurasi port pada file server.

---

### 2. Setup Aplikasi Mobile Flutter

Kembali ke direktori utama proyek:

```bash
cd ..
```

Install seluruh dependency Flutter:

```bash
flutter pub get
```

Pastikan emulator atau perangkat fisik sudah aktif, lalu jalankan aplikasi:

```bash
flutter run
```

---

## Product Requirement Document (PRD)

### 1. Problem Statement

- **Kurangnya struktur belajar mandiri**  
  Banyak pelajar bahasa pemula kesulitan menemukan alur pembelajaran yang terarah, runtut, dan mudah diikuti.

- **Rendahnya motivasi belajar**  
  Materi pembelajaran berbasis teks yang monoton dapat membuat pengguna cepat bosan karena minim evaluasi interaktif dan elemen kompetitif.

- **Keterbatasan pengelolaan konten**  
  Platform pembelajaran yang kaku menyulitkan admin dalam memperbarui materi, bank soal, dan data pengguna secara cepat.

### 2. Proposed Solution

- **Platform LMS bahasa asing berbasis mobile**  
  LinguaSync menyediakan modul materi, kuis, riwayat nilai, dan leaderboard dalam satu aplikasi mobile.

- **Gamifikasi pembelajaran**  
  Fitur leaderboard dan riwayat kuis membantu pengguna memantau perkembangan sekaligus meningkatkan motivasi belajar.

- **Panel admin terpusat**  
  Admin dapat mengelola data bahasa, materi, kuis, pengguna, dan riwayat nilai melalui fitur CRUD yang tersedia di aplikasi.

### 3. Feature List

#### Sisi Pengguna

- **Authentication & Auto-Login**  
  Sistem registrasi dan login berbasis JWT, dilengkapi auto-login pada Splash Page.

- **Explore Languages**  
  Menampilkan daftar bahasa asing yang tersedia dengan fitur pencarian dinamis.

- **Enrollment & My Study Hub**  
  Pengguna dapat mendaftar ke bahasa tertentu dan mengakses ruang belajar melalui menu My Study.

- **Interactive Quiz with Timer**  
  Pengguna dapat mengerjakan kuis pilihan ganda dengan timer otomatis 5 detik per soal.

- **Global Leaderboard**  
  Menampilkan peringkat skor tertinggi berdasarkan hasil kuis pengguna.

- **Quiz History & Progress Tracking**  
  Menampilkan riwayat nilai kuis yang telah dikerjakan secara kronologis.

- **User Profile Management**  
  Pengguna dapat memperbarui data diri, kata sandi, dan foto profil.

#### Sisi Admin

- **Admin Dashboard Hub**  
  Halaman utama admin untuk memantau ringkasan data aplikasi.

- **CRUDS Kelola Bahasa**  
  Admin dapat membuat, membaca, memperbarui, menghapus, dan mencari data bahasa.

- **CRUDS Kelola Materi**  
  Admin dapat mengelola urutan bab dan isi konten materi pembelajaran.

- **CRUDS Kelola Kuis**  
  Admin dapat mengelola bank soal pilihan ganda dan kunci jawaban.

- **CRUDS Kelola Data Siswa**  
  Admin dapat mengelola akun pengguna yang terdaftar di aplikasi.

- **CRUDS Kelola Log Nilai**  
  Admin dapat memantau dan mengelola rekam jejak nilai kuis pengguna.

---

## Log Progress Mingguan

### Minggu 1

- Inisialisasi struktur proyek Flutter.
- Pembuatan struktur awal backend menggunakan Node.js dan Express.js.
- Konfigurasi awal database menggunakan Sequelize ORM.

### Minggu 2

- Pembuatan skema database relasional untuk entitas utama.
- Pembuatan file `package.json` untuk manajemen dependency backend.
- Implementasi middleware autentikasi dan validasi untuk register dan login.
- Pembuatan `StorageProvider` dan `BaseRepository` di Flutter untuk request HTTP.
- Integrasi secure storage untuk penyimpanan token JWT.

### Minggu 3

- Implementasi `AuthBloc`, `AuthEvent`, dan `AuthState` untuk manajemen sesi pengguna.
- Pembuatan repository untuk modul Auth, History, Language, Leaderboard, Material, dan Quiz.
- Pembuatan data models untuk seluruh entitas utama.
- Pembuatan halaman Explore Languages Page dan My Study Page untuk pengguna.

### Minggu 4

- Implementasi `LanguageBloc`, `MaterialBloc`, `QuizBloc`, `LeaderboardBloc`, dan `HistoryBloc`.
- Integrasi `AppBlocObserver` untuk memantau log event BLoC secara real-time.
- Pembuatan halaman admin: `AdminManageLanguagePage`, `AdminManageMaterialPage`, dan `AdminManageQuizPage`.
- Pembuatan halaman form: `LanguageFormPage` dan `MaterialFormPage`.
- Pembuatan halaman pengguna: `DetailLanguagePage` dan `MaterialContentPage`.
- Pembuatan widget reusable: `CustomButton`, `CustomTextField`, `LanguageCard`, `LeaderboardTile`, `QuizOptionButton`, dan `ShimmerLoading`.

### Minggu 5

- Pembuatan halaman `QuizFormPage` dan `QuizPlayPage`.
- Penghapusan field `duration` dari model Quiz dan penyesuaian controller backend.
- Pembuatan halaman `QuizHistoryDetailPage` dan integrasi navigasi dari `UserHistoryPage`.
- Implementasi dialog konfirmasi logout pada halaman admin dan halaman eksplorasi bahasa.
- Pengisian data awal melalui database seeder.
- Penerapan warna dan tipografi Japandi Theme secara konsisten.

### Minggu 6

- Implementasi fitur pencarian berbasis server menggunakan operator `Op.like` pada materi dan kuis.
- Pembuatan halaman admin baru: `AdminManageHistoryPage` dan `AdminManageUserPage`.
- Pembuatan form baru: `HistoryFormPage` dan `UserFormPage`.
- Pembuatan halaman `ProfilePage` untuk pengelolaan data pengguna.
- Integrasi `file_picker` di Flutter dan middleware Multer di backend untuk fitur unggah foto profil.
- Pembaruan gaya UI pada halaman admin dan detail bahasa.

