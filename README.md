# 🖥️ Panel LufyaCBT - Desktop Proktor (.exe)

Aplikasi Desktop Windows (.exe) untuk Proktor & Pengawas Ujian **Lufya CBT**.

Aplikasi ini dirancang dengan antarmuka modern yang terinspirasi dari standar resmi **ANBK CBT Proktor**, dilengkapi fitur **Smart Server Resolver**, **Sinkronisasi Otomatis**, dan **Enkripsi Handshake Aman**.

---

## ✨ Fitur Utama

- 🎨 **ANBK Modern UI Layout**: Tampilan presisi dengan form Sign-In terapung (Floating Card) dan dynamic branding lembaga/sekolah.
- 🔄 **Sinkronisasi Data Otomatis**: Menyesuaikan logo, nama sekolah, tema warna, dan kode server secara real-time dari server CBT.
- 🔐 **Enkripsi Handshake HMAC-SHA256**: Mengunci panel agar hanya dapat terhubung ke server resmi Lufya CBT.
- 🌐 **Embedded WebView2 Engine**: Mengoperasikan dashboard admin CBT langsung di dalam jendela `.exe` tanpa perlu membuka browser luar terpisah.
- 🪟 **Jendela Desktop Standar (Non-Kiosk)**: Dapat di-minimize, maximize, resize, atau dipindah layar dengan leluasa tanpa mengunci sistem operasi.
- 💾 **Penyimpanan Lokal**: Mengingat URL server terakhir dan ID proktor yang tersimpan.

---

## 🚀 Panduan Upload ke GitHub (`ariesabd/Panel-Lufyacbt`)

Untuk membuat repositori baru di GitHub Anda dan memicu pembuatan file `.exe` otomatis:

1. Buat repositori baru di [GitHub Ariesabd](https://github.com/new) dengan nama:
   ```text
   Panel-Lufyacbt
   ```
2. Buka terminal (PowerShell) di folder `panel`:
   ```powershell
   cd d:\xampp82\htdocs\lufyacbt\panel
   git init
   git add .
   git commit -m "feat: Initial commit Panel LufyaCBT Flutter Desktop"
   git branch -M main
   git remote add origin https://github.com/ariesabd/Panel-Lufyacbt.git
   git push -u origin main
   ```
3. Buka tab **Actions** di repositori GitHub Anda:
   - Workflow `Build Panel LufyaCBT Windows (.exe)` akan otomatis berjalan.
   - Setelah selesai (sekitar 3-5 menit), unduh file zip **`Panel-LufyaCBT-Windows-x64.zip`** pada bagian **Artifacts** atau **Releases**.

---

## 💻 Panduan Compile Lokal (Jika Memiliki Flutter SDK)

Jika komputer Anda sudah terpasang Flutter SDK dan Visual Studio C++:

```powershell
cd d:\xampp82\htdocs\lufyacbt\panel
flutter pub get
flutter build windows --release
```

Hasil file `.exe` berada di folder:
`build\windows\x64\runner\Release\Panel-LufyaCBT.exe`
