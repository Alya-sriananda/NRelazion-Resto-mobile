# NRelazion Resto 🍽️

NRelazion Resto adalah aplikasi manajemen restoran modern berbasis mobile yang dibangun menggunakan **Flutter**. Aplikasi ini dirancang untuk memudahkan proses pemesanan bagi pelanggan, manajemen pesanan bagi kasir, hingga pemantauan laporan bisnis bagi pemilik restoran (Admin).

Aplikasi ini menggunakan **Google Spreadsheet** sebagai database dan **Google Apps Script** sebagai backend REST API, menjadikannya solusi yang ringan dan efisien untuk manajemen operasional restoran.

---

## ✨ Fitur Utama

### 👨‍👩‍👧‍👦 Role: Customer
- **Menu Digital**: Telusuri berbagai kategori menu (Makanan Utama, Minuman, Cemilan, Coffee).
- **Pemesanan Mandiri**: Masukkan menu ke keranjang dan pilih nomor meja langsung dari aplikasi.
- **Riwayat Pesanan**: Pantau status pesanan (Menunggu, Diproses, Selesai) secara real-time.
- **Profil & Favorit**: Simpan menu favorit dan kelola informasi profil pengguna.

### 💰 Role: Kasir
- **Dashboard Pesanan**: Lihat semua pesanan masuk secara real-time.
- **Manajemen Status**: Perbarui status pesanan dari "Dikonfirmasi" hingga "Siap Diambil".
- **Sistem Kasir**: Proses pembayaran (Tunai/QRIS) dan selesaikan pesanan.
- **Manajemen Meja**: Pantau ketersediaan meja di berbagai area restoran.

### 🛡️ Role: Admin
- **Statistik Bisnis**: Dashboard grafik pendapatan dan jumlah pesanan.
- **Manajemen Menu (CRUD)**: Tambah, edit, atau hapus menu restoran dengan mudah.
- **Manajemen Meja & User**: Kelola kapasitas meja dan hak akses pengguna (Kasir/Customer).
- **Laporan Lengkap**: Lihat laporan pendapatan harian dan bulanan.

---

## 🚀 Teknologi yang Digunakan

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Google Apps Script (Javascript)
- **Database**: Google Spreadsheet
- **Lainnya**: Google Fonts, HTTP, Shared Preferences, FL Chart.

---

## 🛠️ Langkah Instalasi

### Metode 1: Melalui GitHub (Clone)
1. **Clone Repositori**:
   ```bash
   git clone https://github.com/Alya-sriananda/NRelazion-Resto-mobile.git
   ```
2. **Masuk ke Direktori**:
   ```bash
   cd nrelazion_resto
   ```
3. **Instal Dependensi**:
   ```bash
   flutter pub get
   ```
4. **Jalankan Aplikasi**:
   Pastikan emulator atau perangkat fisik sudah terhubung, lalu jalankan:
   ```bash
   flutter run
   ```

### Metode 2: Import Folder Manual
1. **Download & Ekstrak**: Download source code dan ekstrak folder `nrelazion_resto`.
2. **Buka di IDE**: Buka VS Code atau Android Studio, lalu pilih **Open Folder** dan arahkan ke folder project.
3. **Ambil Paket**: Buka terminal di IDE tersebut dan jalankan:
   ```bash
   flutter pub get
   ```
4. **Running**: Tekan `F5` (di VS Code) atau klik tombol **Run** (di Android Studio).

---

## ⚙️ Konfigurasi Backend (Opsional)

Jika Anda ingin menggunakan database sendiri:
1. Siapkan Google Spreadsheet dengan struktur yang sesuai.
2. Deploy script di Google Apps Script sebagai **Web App**.
3. Buka file `lib/services/api_service.dart`.
4. Ganti `baseUrl` dengan URL Web App Anda:
   ```dart
   static const String baseUrl = 'URL_WEB_APP_ANDA_DISINI';
   ```

---

## 📱 Cuplikan Aplikasi
*(Anda dapat menambahkan screenshot aplikasi di sini untuk mempercantik README)*

---

**Developed with ❤️ by NRelazion Team**