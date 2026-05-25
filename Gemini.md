# Dokumen Spesifikasi Komprehensif — Aplikasi NRelazion

## 1. ARSITEKTUR UMUM

### 1.1 Stack Teknologi
- **Frontend**: Flutter (Dart)
- **Backend**: Google Spreadsheet + Google Apps Script (sebagai REST API)
- **Autentikasi**: Custom token-based (disimpan di SharedPreferences)
- **State Management**: Provider atau Riverpod
- **Gambar Menu**: Di-host di Google Drive, URL disimpan di Spreadsheet

### 1.2 Struktur Spreadsheet (Worksheet Terpisah)

| Sheet Name | Kolom |
|---|---|
| `Users` | id, nama, email, password (hash), role, telepon, foto_url, created_at |
| `Menu` | id, nama, deskripsi, harga, kategori, gambar_url, status_aktif |
| `Meja` | id, area, nomor, kapasitas, status (tersedia/terisi/reserved) |
| `Orders` | id, user_id, kasir_id, meja_id, items_json, total_harga, status, metode_bayar, catatan, created_at, updated_at |
| `Favorites` | id, user_id, menu_id |
| `Transaksi` | id, order_id, jumlah_bayar, kembalian, metode_bayar, timestamp |

### 1.3 Status Lifecycle Order
```
MENUNGGU → DIKONFIRMASI → DIPROSES → SIAP_DIAMBIL → SELESAI
                                                              ↓
                                                         DIBATALKAN (dari MENUNGGU/DIKONFIRMASI)
```

---

## 2. MODE TAMU (GUEST MODE) — Tanpa Login

### 2.1 Yang Bisa Diakses
| Fitur | Keterangan |
|---|---|
| Home Screen | Tampilan utama dengan banner promo, kategori menu, menu populer |
| Daftar Menu per Kategori | Bisa scroll dan lihat detail menu (nama, harga, deskripsi, gambar) |
| Pencarian Menu | Ketik nama menu, hasil muncul tapi tidak bisa dipesan |
| Informasi Restoran | Alamat, jam operasional, kontak |

### 2.2 Yang Diblokir (Trigger Login)
Saat user menekan fitur berikut, muncul **bottom sheet atau dialog** berisi:
- Pesan: *"Fitur ini memerlukan akun. Silakan login atau daftar terlebih dahulu."*
- Tombol **"Login"** → navigasi ke halaman login
- Tombol **"Daftar"** → navigasi ke halaman register
- Tombol **"Batal"** → tutup dialog

Fitur yang diblokir:
1. **Ikon keranjang** (jika ada di AppBar)
2. **Tombol "Tambah ke Keranjang"** di detail menu
3. **Tombol "Pesan Sekarang"** di detail menu
4. **Tab Riwayat** di bottom navigation
5. **Tab Favorit** di bottom navigation
6. **Tab Profil** di bottom navigation
7. **Ikon hati/love** di card menu

### 2.3 Alur Navigasi Tamu
```
Splash Screen → Home (BottomNav: Home aktif, lainnya disabled/trigger login)
                  ├── Tap kategori → List Menu (read-only)
                  ├── Tap card menu → Detail Menu (tombol pesan → trigger login)
                  ├── Tap tab Riwayat → trigger login
                  ├── Tap tab Keranjang → trigger login
                  ├── Tap tab Favorit → trigger login
                  └── Tap tab Profil → trigger login → Login/Register Screen
```

---

## 3. ROLE: CUSTOMER

### 3.1 Autentikasi

#### Halaman Login
- **Form**: Email (TextInput, type email), Password (TextInput, obscured)
- **Validasi**: Email format valid, password tidak kosong
- **Tombol**: "Masuk"
- **Link**: "Belum punya akun? Daftar"
- **Fungsi**: POST ke Apps Script → cek email & password hash di sheet `Users` → simpan data user ke SharedPreferences → navigasi ke Home (mode logged in)
- **Error handling**: "Email atau password salah", "Koneksi gagal"

#### Halaman Register
- **Form**: Nama Lengkap, Email, Telepon, Password, Konfirmasi Password
- **Validasi**: Semua field wajib, email format valid, password min 6 karakter, password == konfirmasi
- **Tombol**: "Daftar"
- **Link**: "Sudah punya akun? Login"
- **Fungsi**: POST ke Apps Script → cek email belum terdaftar → tulis row baru di `Users` dengan role "customer" → auto login → navigasi ke Home

### 3.2 Home Screen (Logged In)
- **Banner Slider**: Gambar promo yang bisa di-swipe (data dari sheet atau hardcode 3-5 gambar)
- **Kategori Grid**: 4 tombol/grid — Makanan Utama, Minuman, Cemilan, Coffee — dengan ikon
- **Menu Populer**: Horizontal scroll card menu berdasarkan jumlah order atau flag `is_popular`
- **Rekomendasi**: Menu yang belum pernah dipesan user (opsional)
- Setiap card menu menampilkan: gambar, nama, harga, ikon hati (untuk favorit)

### 3.3 Daftar Menu
- **Filter Kategori**: Tab/chip horizontal: Semua, Makanan Utama, Minuman, Cemilan, Coffee
- **Search Bar**: Real-time filter berdasarkan nama menu
- **Card Menu**: Gambar, nama, harga, badge kategori, ikon hati
- **Tap card** → Detail Menu
- **Sorting**: Harga terendah-tertinggi, tertinggi-terendah, nama A-Z

### 3.4 Detail Menu
- **Tampilan**: Gambar besar (Hero animation dari card), nama, kategori (chip), harga, deskripsi
- **Tombol Hati**: Toggle favorit (hanya jika sudah login)
- **Tombol "Tambah ke Keranjang"**: 
  - Muncul bottom sheet: pilih jumlah (stepper -/+), tombol "Tambah"
  - Fungsi: tambah ke keranjang lokal (state management), snackbar konfirmasi
- **Tombol "Pesan Sekarang"**:
  - Langsung masuk ke halaman keranjang/pesan

### 3.5 Keranjang (Cart)
- **Daftar Item**: Card per item — gambar kecil, nama, harga, stepper qty, tombol hapus
- **Ringkasan**: Subtotal, (opsional pajak), Total
- **Pilihan Meja**: 
  - Dropdown/picker dengan grouping:
    ```
    Lesehan  : 1, 2, 3, 4
    Garden   : 1, 2, 3, 4
    Area L   : 1, 2, 3, 4, 5, 6
    Atap     : 1, 2, 3, 4
    VIP      : 1, 2, 3
    ```
  - Meja yang statusnya "tersedia" saja yang bisa dipilih
  - Tampilkan kapasitas meja
- **Catatan**: TextInput opsional (misal: "tanpa sambal", "es sedikit")
- **Metode Pembayaran**: Pilihan — Tunai, QRIS (simulasi)
- **Tombol "Pesan"**: 
  - Validasi: keranjang tidak kosong, meja dipilih
  - Fungsi: POST ke Apps Script → tulis ke sheet `Orders` + update status meja → update keranjang lokal kosong → navigasi ke halaman "Pesanan Berhasil"
- **Halaman Pesanan Berhasil**: Nomor pesanan, estimasi waktu, status "Menunggu Konfirmasi", tombol "Lihat Pesanan" → Riwayat

### 3.6 Favorit
- **Daftar Menu Favorit**: Grid/List card menu yang di-favoritkan user
- **Sumber data**: Sheet `Favorites` join `Menu` berdasarkan user_id
- **Aksi**: Tap hati untuk unfavorit, tap card → Detail Menu
- **Empty State**: "Belum ada menu favorit. Tandai menu yang kamu suka dengan ikon hati."

### 3.7 Riwayat Pesanan
- **Tab Filter**: Semua, Menunggu, Diproses, Selesai, Dibatalkan
- **Card Pesanan**: 
  - Nomor order, tanggal, meja
  - Daftar item singkat (nama + qty)
  - Total harga
  - Status (badge berwarna)
  - Tap → Detail Pesanan
- **Detail Pesanan**:
  - Informasi: nomor order, tanggal, meja, metode bayar, catatan
  - Daftar item lengkap: nama, qty, harga satuan, subtotal
  - Total
  - Timeline status (dot timeline): Menunggu → Dikonfirmasi → Diproses → Siap → Selesai
  - Tombol "Pesan Lagi": copy semua item ke keranjang
  - Tombol "Batalkan" (hanya jika status = MENUNGGU): konfirmasi dialog → update status

### 3.8 Profil
- **Header**: Foto profil (default avatar jika kosong), nama, email
- **Menu Setting**:
  - Edit Profil → form edit nama, telepon, alamat, upload foto
  - Ubah Password → form password lama, password baru, konfirmasi
  - Tentang Aplikasi → halaman info versi, developer
  - Logout → dialog konfirmasi → hapus data lokal → navigasi ke Home (guest mode)

---

## 4. ROLE: KASIR

### 4.1 Autentikasi
- Sama dengan Customer (satu form login)
- Saat login, Apps Script return data user termasuk field `role`
- Jika role = "kasir" → navigasi ke **Kasir Dashboard** (bukan Home customer)

### 4.2 Dashboard Kasir
- **Ringkasan Hari Ini** (card atas):
  - Total pesanan hari ini
  - Total pendapatan hari ini
  - Pesanan yang menunggu konfirmasi (badge angka)
- **Daftar Pesanan Masuk** (list, filter: Menunggu, Dikonfirmasi, Diproses, Siap, Semua):
  - Card: nomor order, waktu, meja, nama customer, item ringkas, total, status badge
  - Tap → Detail & Aksi

### 4.3 Detail Pesanan (Kasir View)
- Semua informasi pesanan sama dengan customer view
- **Tambahan: Panel Aksi** sesuai status:

| Status Saat Ini | Tombol Aksi | Fungsi |
|---|---|---|
| MENUNGGU | "Konfirmasi", "Batalkan" | Update status di sheet |
| DIKONFIRMASI | "Proses" | Update status |
| DIPROSES | "Siap Diambil" | Update status |
| SIAP_DIAMBIL | "Selesaikan & Bayar" | Buka dialog pembayaran |
| SELESAI | (hanya view) | - |
| DIBATALKAN | (hanya view) | - |

### 4.4 Dialog Pembayaran
- **Tampilan**: Total yang harus dibayar (angka besar)
- **Pilihan Metode**: Tunai / QRIS
- **Jika Tunai**:
  - Input: "Uang Dibayar" (TextInput angka, dengan quick button: Uang Pas, 50rb, 100rb)
  - Auto-kalkulasi: Kembalian = Uang Dibayar - Total
  - Validasi: uang dibayar >= total
  - Tombol "Proses Pembayaran": tulis ke sheet `Transaksi`, update status order → SELESAI, update meja → TERSEDIA
- **Jika QRIS**:
  - Tampilkan QR Code (simulasi/gambar statis)
  - Tombol "Konfirmasi Sudah Dibayar": langsung proses seperti tunai tanpa kembalian

### 4.5 Manajemen Meja (Kasir)
- **Tampilan**: Grid/button grouping per area
  ```
  Lesehan: [1] [2] [3] [4]
  Garden : [1] [2] [3] [4]
  Area L : [1] [2] [3] [4] [5] [6]
  Atap   : [1] [2] [3] [4]
  VIP    : [1] [2] [3]
  ```
- **Warna Indikator**:
  - Hijau = Tersedia
  - Merah = Terisi (sedang digunakan, tampilkan nomor order)
  - Kuning = Reserved
- **Tap meja**: Popup info — siapa yang memesan, item, status, waktu
- **Fungsi manual** (opsional): Kasir bisa toggle status meja jika ada kesalahan

### 4.6 Navigasi Kasir (Bottom Nav atau Drawer)
```
[Dashboard] [Pesanan] [Meja] [Profil]
```
- **Dashboard**: Ringkasan + pesanan terbaru
- **Pesanan**: Full list semua pesanan dengan filter
- **Meja**: Grid manajemen meja
- **Profil**: Sama seperti customer (edit profil, logout)

---

## 5. ROLE: ADMIN

### 5.1 Autentikasi
- Sama, login → cek role = "admin" → navigasi ke Admin Dashboard

### 5.2 Dashboard Admin
- **Statistik Card**:
  - Total pendapatan hari ini / bulan ini / tahun ini (dapat switch periode)
  - Total pesanan hari ini
  - Total pelanggan terdaftar
  - Menu terlaris (top 5 berdasarkan jumlah terjual)
- **Grafik Sederhana**: Pendapatan 7 hari terakhir (menggunakan fl_chart package, data dari aggregation sheet)
- **Quick Action**: Tombol cepat — Tambah Menu, Lihat Pesanan, Kelola Meja

### 5.3 Manajemen Menu (CRUD)

#### Daftar Menu
- **Tampilan**: List/table view — gambar kecil, nama, kategori, harga, status toggle aktif/nonaktif
- **Filter**: Per kategori, status aktif/nonaktif
- **Search**: Berdasarkan nama
- **Aksi per item**: Edit, Hapus, Toggle status

#### Form Tambah/Edit Menu
- **Field**:
  - Nama Menu (TextInput, wajib)
  - Kategori (Dropdown: Makanan Utama, Minuman, Cemilan, Coffee, wajib)
  - Deskripsi (TextInput multiline)
  - Harga (TextInput angka, wajib, format Rupiah)
  - Gambar (upload ke Google Drive via Apps Script, return URL) — atau input URL manual
  - Status Aktif (Switch toggle)
- **Validasi**: Nama, kategori, harga wajib, harga > 0
- **Fungsi Tambah**: POST ke Apps Script → generate ID → tulis row baru di sheet `Menu`
- **Fungsi Edit**: POST ke Apps Script → update row berdasarkan ID
- **Fungsi Hapus**: Dialog konfirmasi → DELETE di Apps Script → hapus row
- **Fungsi Toggle**: Switch on/off → update kolom `status_aktif`

### 5.4 Manajemen Pesanan
- Sama dengan Kasir (full list + filter + detail + aksi)
- **Tambahan Admin**: Bisa melihat semua pesanan (tidak hanya hari ini), filter by tanggal range, filter by kasir yang menangani

### 5.5 Manajemen Meja
- Sama dengan Kasir (grid view + indikator warna)
- **Tambahan Admin**: Bisa edit kapasitas meja, bisa tambah/meja baru, hapus meja

#### Form Edit Meja
- Area (Dropdown: Lesehan, Garden, Area L, Atap, VIP)
- Nomor Meja (TextInput angka)
- Kapasitas (TextInput angka)
- Status (Dropdown: Tersedia, Terisi, Reserved)

### 5.6 Manajemen User
- **Daftar User**: Tabel — nama, email, role, tanggal daftar
- **Filter**: Per role (customer, kasir, admin)
- **Aksi**: 
  - Ubah role (customer ↔ kasir, bukan admin)
  - Nonaktifkan user (soft delete / flag)
  - Lihat detail pesanan user
- **Tambah Kasir**: Form singkat — nama, email, password default, langsung role "kasir"

### 5.7 Laporan & Analitik
- **Filter Periode**: Tanggal mulai — tanggal selesai
- **Data yang Ditampilkan**:
  - Total pendapatan periode
  - Total pesanan periode
  - Rata-rata nilai pesanan
  - Jumlah pelanggan unik
  - Top 10 menu terlaris (nama, jumlah terjual, revenue)
  - Pendapatan per kategori (pie chart)
  - Pendapatan per hari (line/bar chart)
- **Export**: Tombol export CSV (generate dari Apps Script)
- **Sumber data**: Query aggregation dari sheet `Orders` dan `Order_Items` (atau `items_json` di-parsing)

### 5.8 Pengaturan
- **Informasi Restoran**: Nama, alamat, telepon, jam buka-tutup, deskripsi singkat (disimpan di sheet `Settings`)
- **Banner Promo**: Tambah/edit/hapus gambar banner di Home (URL gambar di sheet `Settings` atau sheet `Banners`)
- **Metode Pembayaran**: Toggle aktif/nonaktif untuk Tunai, QRIS, dll (disimpan di sheet `Settings`)

### 5.9 Navigasi Admin (Drawer / Sidebar)
```
Drawer Menu:
├── Dashboard
├── Kelola Menu
├── Kelola Pesanan
├── Kelola Meja
├── Kelola User
├── Laporan
├── Pengaturan
└── Logout
```

---

## 6. GOOGLE APPS SCRIPT — ENDPOINTS YANG DIPERLUKAN

### 6.1 Autentikasi
| Endpoint | Method | Fungsi |
|---|---|---|
| `/login` | POST | Verifikasi email & password, return data user + token |
| `/register` | POST | Cek email unik, tulis user baru, return data user |
| `/updateProfile` | POST | Update nama, telepon, alamat, foto |
| `/changePassword` | POST | Verifikasi password lama, update password baru |

### 6.2 Menu
| Endpoint | Method | Fungsi |
|---|---|---|
| `/getMenu` | GET | Return semua menu aktif, support query param `?kategori=xxx` |
| `/getMenuDetail` | GET | Return detail 1 menu berdasarkan id |
| `/addMenu` | POST | Tambah menu baru (admin) |
| `/updateMenu` | POST | Update menu (admin) |
| `/deleteMenu` | POST | Hapus menu (admin) |
| `/searchMenu` | GET | Cari menu berdasarkan keyword |

### 6.3 Pesanan
| Endpoint | Method | Fungsi |
|---|---|---|
| `/createOrder` | POST | Tulis pesanan baru, update meja |
| `/getOrders` | GET | List pesanan, support filter `?status=xxx&tanggal=xxx` |
| `/getOrderDetail` | GET | Detail 1 pesanan |
| `/updateOrderStatus` | POST | Update status pesanan |
| `/getOrdersByUser` | GET | Pesanan berdasarkan user_id |

### 6.4 Favorit
| Endpoint | Method | Fungsi |
|---|---|---|
| `/getFavorites` | GET | List favorit user |
| `/addFavorite` | POST | Tambah favorit |
| `/removeFavorite` | POST | Hapus favorit |
| `/checkFavorite` | GET | Cek apakah menu sudah di-favoritkan |

### 6.5 Meja
| Endpoint | Method | Fungsi |
|---|---|---|
| `/getMeja` | GET | Semua data meja + status |
| `/updateMejaStatus` | POST | Update status meja |
| `/addMeja` | POST | Tambah meja baru (admin) |
| `/updateMeja` | POST | Edit meja (admin) |
| `/deleteMeja` | POST | Hapus meja (admin) |

### 6.6 Transaksi
| Endpoint | Method | Fungsi |
|---|---|---|
| `/createTransaction` | POST | Catat pembayaran, update order selesai, update meja tersedia |
| `/getTransactions` | GET | List transaksi, filter periode |

### 6.7 Laporan
| Endpoint | Method | Fungsi |
|---|---|---|
| `/getReport` | GET | Agregasi pendapatan, top menu, dll berdasarkan range tanggal |
| `/exportCSV` | GET | Generate dan return file CSV |

### 6.8 Pengaturan
| Endpoint | Method | Fungsi |
|---|---|---|
| `/getSettings` | GET | Ambil data pengaturan restoran |
| `/updateSettings` | POST | Update pengaturan (admin) |
| `/getBanners` | GET | Ambil daftar banner |
| `/manageBanner` | POST | Tambah/edit/hapus banner (admin) |

---

## 7. STRUKTUR FOLDER FLUTTER

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, routes, theme
├── constants/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_routes.dart
│   └── table_data.dart              # Enum/list area meja
├── models/
│   ├── user_model.dart
│   ├── menu_model.dart
│   ├── order_model.dart
│   ├── meja_model.dart
│   ├── favorite_model.dart
│   ├── transaksi_model.dart
│   └── setting_model.dart
├── services/
│   ├── auth_service.dart
│   ├── menu_service.dart
│   ├── order_service.dart
│   ├── meja_service.dart
│   ├── favorite_service.dart
│   ├── transaksi_service.dart
│   ├── report_service.dart
│   ├── setting_service.dart
│   └── spreadsheet_service.dart     # Base HTTP caller ke Apps Script
├── providers/
│   ├── auth_provider.dart           # Login state, role, user data
│   ├── menu_provider.dart           # List menu, filter, search
│   ├── cart_provider.dart           # Keranjang lokal
│   ├── order_provider.dart          # Pesanan
│   ├── favorite_provider.dart       # Favorit
│   ├── meja_provider.dart           # Status meja
│   └── theme_provider.dart          # (opsional) dark/light mode
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── customer/
│   │   ├── home_screen.dart
│   │   ├── menu_list_screen.dart
│   │   ├── menu_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── order_success_screen.dart
│   │   ├── history_screen.dart
│   │   ├── order_detail_screen.dart
│   │   ├── favorite_screen.dart
│   │   └── profile_screen.dart
│   ├── kasir/
│   │   ├── kasir_dashboard_screen.dart
│   │   ├── kasir_order_list_screen.dart
│   │   ├── kasir_order_detail_screen.dart
│   │   ├── kasir_payment_dialog.dart
│   │   ├── kasir_meja_screen.dart
│   │   └── kasir_profile_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart
│       ├── admin_menu_screen.dart
│       ├── admin_menu_form_screen.dart
│       ├── admin_order_screen.dart
│       ├── admin_meja_screen.dart
│       ├── admin_meja_form_screen.dart
│       ├── admin_user_screen.dart
│       ├── admin_report_screen.dart
│       └── admin_setting_screen.dart
├── widgets/
│   ├── menu_card.dart
│   ├── category_chip.dart
│   ├── order_card.dart
│   ├── status_badge.dart
│   ├── quantity_stepper.dart
│   ├── meja_grid.dart
│   ├── stat_card.dart
│   ├── loading_indicator.dart
│   ├── empty_state.dart
│   ├── login_prompt_dialog.dart      # Dialog yang muncul di guest mode
│   └── custom_app_bar.dart
└── utils/
    ├── currency_formatter.dart       # Format ke Rupiah
    ├── date_formatter.dart
    ├── validators.dart               # Validasi form
    └── hash_utils.dart               # Hash password (bcrypt alternative di Dart)
```

---

## 8. DATA MEJA — DEFINISI LENGKAP

```dart
// Definisi statis di table_data.dart
final List<MejaArea> mejaAreas = [
  MejaArea(nama: "Lesehan", prefix: "LS", nomorRange: [1,2,3,4], kapasitas: 4),
  MejaArea(nama: "Garden",  prefix: "G", nomorRange: [1,2,3,4], kapasitas: 4),
  MejaArea(nama: "Area L",  prefix: "L", nomorRange: [1,2,3,4,5,6], kapasitas: 6),
  MejaArea(nama: "Atap",    prefix: "AT", nomorRange: [1,2,3,4], kapasitas: 4),
  MejaArea(nama: "VIP",     prefix: "VP", nomorRange: [1,2,3], kapasitas: 8),
];
// Total: 4+4+6+4+3 = 21 meja
```

Setiap meja memiliki ID unik yang dibentuk dari prefix + nomor, misal: `LS1`, `G3`, `L6`, `AT2`, `VP1`. Status disimpan di sheet `Meja` dan di-update saat order dibuat (→ terisi) dan saat order selesai/dibatalkan (→ tersedia).

---

## 9. ALUR NAVIGASI LENGKAP

### 9.1 Berdasarkan Role (Setelah Login)

```
Login
 ├── role = "customer"  → CustomerHome (BottomNav: Home|Favorit|Riwayat|Profil)
 ├── role = "kasir"     → KasirDashboard (BottomNav: Dashboard|Pesanan|Meja|Profil)
 └── role = "admin"     → AdminDashboard (Drawer: Dashboard|Menu|Pesanan|Meja|User|Laporan|Setting)
```

### 9.2 Alur Pemesanan Customer
```
Home → Tap Kategori → List Menu → Tap Menu → Detail Menu
    → Tap "Tambah ke Keranjang" → (Bottom Sheet qty) → Snackbar "Ditambahkan"
    → Tap Tab Keranjang → Cart Screen
        → Atur qty / hapus item
        → Pilih meja (picker)
        → Isi catatan (opsional)
        → Pilih metode bayar
        → Tap "Pesan"
        → Validasi → POST createOrder
        → Order Success Screen
        → Tap "Lihat Pesanan" → Riwayat → Tap pesanan → Detail
```

### 9.3 Alur Proses Kasir
```
Dashboard → Tap pesanan "Menunggu" → Detail Pesanan
    → Tap "Konfirmasi" → Status → DIKONFIRMASI
    → (Dapur proses) → Kasir tap "Proses" → Status → DIPROSES
    → (Makanan siap) → Kasir tap "Siap Diambil" → Status → SIAP_DIAMBIL
    → (Customer mengambil) → Kasir tap "Selesaikan & Bayar"
        → Dialog Pembayaran
        → Pilih metode → Input uang / konfirmasi QRIS
        → Tap "Proses Pembayaran"
        → POST createTransaction → update order SELESAI → update meja TERSEDIA
```

---

## 10. PACKAGE FLUTTER YANG DIPERLUKAN

| Package | Fungsi |
|---|---|
| `http` | HTTP request ke Apps Script |
| `shared_preferences` | Simpan token, data user, keranjang lokal |
| `provider` (atau `riverpod`) | State management |
| `google_fonts` | Custom font |
| `cached_network_image` | Cache gambar menu dari URL |
| `image_picker` | Upload foto profil |
| `intl` | Format mata uang dan tanggal |
| `fl_chart` | Grafik laporan di admin |
| `shimmer` | Loading skeleton effect |
| `snackbar_plus` / flushbar | Notifikasi yang lebih baik |
| `slide_to_confirm` | (Opsional) slide untuk konfirmasi aksi penting |

---

## 11. CATATAN PENTING UNTUK IMPLEMENTASI

### 11.1 Keamanan
- Password **tidak boleh disimpan plain text** di Spreadsheet. Gunakan hashing sederhana (SHA-256 minimal) karena Spreadsheet bukan database yang aman
- Token bisa berupa random string yang disimpan di sheet `Sessions` atau cukup encode user_id + timestamp
- Validasi role di **setiap endpoint** Apps Script, bukan hanya di Flutter (karena API bisa diakses langsung)

### 11.2 Keterbatasan Spreadsheet
- **Concurrency issue**: Google Spreadsheet memiliki limit write per menit (~100 request/15 detik). Untuk projek matakuliah ini cukup, tapi perlu diantisipasi dengan loading indicator dan retry
- **Tidak ada real-time**: Untuk update status pesanan, kasir/customer perlu melakukan refresh/pull-to-refresh. Tidak bisa push notification secara native (bisa pakai polling interval 5-10 detik di screen pesanan aktif)
- **Batasi data**: Riwayat pesanan jangan load semua sekaligus, gunakan pagination (limit + offset di query Apps Script)

### 11.3 Keranjang Lokal
- Keranjang disimpan di memori (Provider) + SharedPreferences (persisten)
- Struktur: `List<CartItem>` dimana CartItem = `{menu_id, nama, harga, gambar_url, qty}`
- Tidak perlu ada sheet khusus keranjang di Spreadsheet

### 11.4 Handling Gambar
- Opsi paling mudah: Upload gambar manual ke Google Drive, dapatkan public URL, masukkan ke sheet `Menu`
- Opsi lebih advanced: Apps Script menerima base64 dari Flutter, tulis sebagai blob ke Google Drive, return URL — tapi ini berat dan lambat
- **Rekomendasi untuk projek matakuliah**: Gunakan URL gambar dari penyedia gambar gratis (unsplash, dll) atau upload manual ke Google Drive

### 11.5 Deploy Apps Script
- Deploy sebagai **Web App** dengan access "Anyone" (karena tidak ada OAuth)
- URL endpoint tetap: `https://script.google.com/macros/s/{DEPLOYMENT_ID}/exec?action=login`
- Semua routing endpoint menggunakan query param `?action=xxx`

---

## 12. RINGKASAN FITUR PER ROLE

| Fitur | Tamu | Customer | Kasir | Admin |
|---|:---:|:---:|:---:|:---:|
| Lihat Home & Menu | ✅ | ✅ | ❌ | ❌ |
| Cari Menu | ✅ | ✅ | ❌ | ❌ |
| Login/Register | ✅ | ✅ | ✅ | ✅ |
| Tambah Keranjang | ❌ | ✅ | ❌ | ❌ |
| Pesan Menu | ❌ | ✅ | ❌ | ❌ |
| Pilih Meja | ❌ | ✅ | ❌ | ❌ |
| Favorit | ❌ | ✅ | ❌ | ❌ |
| Riwayat Pesanan | ❌ | ✅ (miliknya) | ✅ (semua) | ✅ (semua) |
| Konfirmasi Pesanan | ❌ | ❌ | ✅ | ✅ |
| Proses Pembayaran | ❌ | ❌ | ✅ | ✅ |
| Lihat Status Meja | ❌ | ❌ | ✅ | ✅ |
| CRUD Menu | ❌ | ❌ | ❌ | ✅ |
| CRUD Meja | ❌ | ❌ | ❌ | ✅ |
| Kelola User | ❌ | ❌ | ❌ | ✅ |
| Laporan & Statistik | ❌ | ❌ | ❌ | ✅ |
| Pengaturan Restoran | ❌ | ❌ | ❌ | ✅ |
| Edit Profil | ❌ | ✅ | ✅ | ✅ |

---

Dokumen ini mencakup seluruh kebutuhan fungsional aplikasi NRelazion. Langkah implementasi selanjutnya adalah: (1) buat Google Spreadsheet dengan struktur sheet, (2) tulis Apps Script untuk semua endpoints, (3) buat project Flutter dan ikuti struktur folder, (4) kerjakan per layer dimulai dari model → service → provider → screen.