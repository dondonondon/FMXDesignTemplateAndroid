# FMX Starter Kit

![Delphi](https://img.shields.io/badge/Delphi-12.x%20FMX-E62431?style=flat-square&logo=embarcadero&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Android%20%7C%20iOS-1F6FEB?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Form%20Shell%20%2B%20Frame%20Router-0E8A16?style=flat-square)
![Status](https://img.shields.io/badge/Status-Starter%20Template-F59E0B?style=flat-square)

[English](README.md) | Bahasa Indonesia

Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)

Bangun aplikasi Delphi FireMonkey di atas struktur proyek yang sudah disiapkan untuk kebutuhan produk nyata.

FMX Starter Kit adalah template lintas platform untuk Windows, Android, dan iOS yang menggunakan satu form sebagai shell aplikasi, halaman berbasis `TFrame`, router terpusat untuk navigasi, serta service dan helper terfokus untuk perilaku bersama. Daripada memulai dari proyek FMX kosong, Anda memulai dari fondasi yang lebih mudah dikembangkan, diuji, dan dirawat.

## Ringkasan

Template ini ditujukan untuk tim dan developer yang ingin bergerak cepat tanpa membuat struktur proyek berantakan saat fitur bertambah. Yang sudah tersedia di dalamnya:

- Form utama sebagai container shell aplikasi.
- Navigasi halaman berbasis frame dengan route history dan back handling.
- Service container bersama untuk dependency tingkat aplikasi.
- Helper class untuk kebutuhan UI dan platform yang umum.
- Hook lintas platform untuk push notification dan Storage Access Framework (SAF).
- Contoh screen untuk alur loading, login, dan detail.

## Kenapa Memakai Template Ini

- Memulai dari fondasi FMX yang terstruktur, bukan proyek kosong.
- Menjaga concern navigasi tetap terpusat, tidak tersebar di banyak form dan frame.
- Memudahkan reuse helper dan service saat codebase tumbuh.
- Menjaga jalur pengembangan tetap terbuka untuk Windows, Android, dan iOS dari satu codebase.

## Sorotan Fitur

| Area | Tersedia di Template | Manfaat |
| --- | --- | --- |
| Arsitektur UI | Shell `TForm` dengan halaman `TFrame` | Membuat layar lebih modular dan mudah dirawat |
| Navigasi | `TFrameRouter` terpusat dengan riwayat route | Menghindari logika perpindahan halaman yang tercecer |
| Bootstrap Aplikasi | Container `TAppServices` bersama | Menyediakan satu titik inisialisasi service aplikasi |
| UX Mobile | Back-key handling, dukungan keyboard, toast/loading helper | Menutup kebutuhan interaksi FMX yang umum lebih awal |
| Akses Platform | Hook SAF dan push notification | Mempermudah integrasi Android dan iOS yang bisa dipakai ulang |
| Layer Helper | Helper API, dataset, bitmap, URL, dan file | Mengurangi boilerplate berulang di banyak fitur |

## Fitur Utama

- `TForm` sebagai shell aplikasi dan `TFrame` untuk setiap halaman.
- Navigasi terpusat melalui `BFA.Control.Frame`.
- Penanganan tombol kembali untuk hardware back Android dan tombol escape desktop.
- Bootstrap `TAppServices` untuk router, keyboard handling, toast/loading UI, push notification, dan SAF.
- Helper utilitas untuk API request, dataset, bitmap, URL, dan akses file.
- Pelaporan memory leak aktif saat aplikasi ditutup untuk membantu debugging.

## Galeri

Repository ini sudah siap untuk dokumentasi visual, tetapi asset gambar screenshot belum ditambahkan.

Saat screenshot sudah tersedia, letakkan file gambar di folder seperti `docs/images/` lalu ganti entri di bawah dengan gambar yang di-embed.

| Screen | Asset yang Disarankan | Status |
| --- | --- | --- |
| Loading | `docs/images/loading.png` | Menunggu asset gambar |
| Login | `docs/images/login.png` | Menunggu asset gambar |
| Detail | `docs/images/detail.png` | Menunggu asset gambar |

Sumber yang disarankan: build Windows desktop, emulator Android, atau screenshot dari perangkat fisik.

## Arsitektur

Proyek ini mengikuti pemisahan concern yang jelas:

- `frMain.pas` adalah shell aplikasi dan menginisialisasi app context.
- `frames/*` berisi halaman UI yang diimplementasikan sebagai frame.
- `sources/app/*` berisi app context, types, dan inisialisasi service.
- `sources/controls/*` berisi controller UI reusable seperti frame routing, keyboard handling, message, permission, dan notification.
- `sources/helpers/*` berisi helper reusable untuk kebutuhan aplikasi dan platform.
- `sources/resources/*` dan `sources/exceptions/*` berisi message bersama dan custom exception.

Contoh flow yang saat ini didaftarkan di router adalah:

- `LOADING`
- `LOGIN`
- `DETAIL`

## Struktur Proyek

```text
FMXDesignTemplateAndroid/
|-- FMXStarterKit.dpr
|-- FMXStarterKit.dproj
|-- compile.bat
|-- frMain.pas
|-- frames/
|   |-- frLoading.pas
|   |-- frLogin.pas
|   |-- frDetail.pas
|   `-- ...
`-- sources/
	|-- app/
	|-- controls/
	|-- exceptions/
	|-- helpers/
	`-- resources/
```

## Cara Kerja Navigasi

Navigasi dikelola oleh `TFrameRouter` di `sources/controls/BFA.Control.Frame.pas`.

- Frame didaftarkan satu kali dengan alias.
- Navigasi menggunakan alias seperti `LOGIN` atau `DETAIL`.
- Setiap frame dapat menyediakan method `ShowFrame` dan `BackFrame` bila diperlukan.
- Router menyimpan riwayat route dan bisa kembali ke halaman sebelumnya secara otomatis.
- Form utama meneruskan perilaku tombol back ke frame aktif melalui router.

Pendekatan ini menjaga perpindahan halaman tetap keluar dari form individual sehingga alur UI lebih mudah dirawat.

## Service yang Sudah Tersedia

`TAppServices` merangkai blok utama yang dipakai oleh template ini:

- `Router`: registrasi frame dan navigasi.
- `Keyboard`: visibilitas keyboard dan penanganan input berbasis scroll.
- `MainHelper`: toast message, loading state, dan popup helper.
- `PushNotification`: integrasi notifikasi mobile untuk Android dan iOS.
- `SAF`: helper lintas platform untuk file picking dan document access.

## Kebutuhan Dasar

Untuk memakai proyek ini, Anda sebaiknya memiliki:

- Embarcadero RAD Studio / Delphi dengan dukungan FireMonkey.
- Mesin Windows untuk kompilasi lokal.
- Setup Android SDK/NDK jika ingin menarget Android.
- Tooling Apple di macOS jika ingin menarget iOS.

`compile.bat` yang disertakan saat ini dikonfigurasi untuk environment RAD Studio lokal yang menggunakan:

- `rsvars.bat` dari `C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat`
- Path repository lokal di `D:\Github\FMXDesignTemplateAndroid`

Sesuaikan path tersebut sebelum memakai batch file ini di mesin lain.

## Memulai

### Opsi 1: Buka di RAD Studio

1. Buka `FMXStarterKit.dproj` di RAD Studio.
2. Pilih target platform yang ingin dijalankan.
3. Build dan run proyek.

### Opsi 2: Build dari command line

1. Perbarui path di `compile.bat` sesuai lokasi instalasi Delphi dan path repository lokal Anda.
2. Jalankan:

```bat
compile.bat
```

Script tersebut membangun proyek pada konfigurasi `Debug` / `Win32` menggunakan `msbuild`.

## Kustomisasi Awal yang Disarankan

- Ganti sample frame dengan halaman aplikasi Anda sendiri.
- Tambahkan alias route baru di `TAppServices.InitFrame`.
- Perluas layer helper untuk API, storage, dan integrasi platform yang spesifik ke aplikasi Anda.
- Standarkan label dan message bila produk Anda ingin full English.

## Perilaku Startup Default

Saat aplikasi dijalankan:

1. Form utama membuat application context.
2. `TAppServices` diinisialisasi.
3. Service inti seperti router, keyboard handling, toast/loading support, SAF, dan push notification disiapkan.
4. Router membuka frame `LOADING`.

Dari sample screen tersebut, Anda bisa melanjutkan ke halaman login dan detail untuk mengembangkan flow aplikasi Anda sendiri.

## Cara Mengembangkan Template Ini

Untuk menambahkan halaman baru:

1. Buat unit `TFrame` baru di folder `frames`.
2. Implementasikan method `ShowFrame` dan `BackFrame` bila diperlukan.
3. Tambahkan alias view baru di `sources/app/BFA.App.Types.pas` pada konstanta `TView`.
4. Daftarkan alias frame di `sources/app/BFA.App.Services.pas` pada class `TAppServices.InitFrame`.
5. Navigasikan ke halaman itu melalui `TAppHelper.NavigateTo('YOUR_ALIAS')`.

Untuk menambahkan business logic atau perilaku platform bersama:

- Tempatkan UI logic di frame.
- Tempatkan application wiring di `sources/app`.
- Tempatkan reusable navigation atau interaction control di `sources/controls`.
- Tempatkan reusable non-UI logic di `sources/helpers`.

## Kenapa Cocok Sebagai Titik Awal

Proyek ini cocok sebagai starting point jika Anda ingin codebase Delphi FMX yang sudah tertata di sekitar:

- navigasi berbasis frame,
- service yang reusable,
- helper untuk perilaku lintas platform,
- dan struktur yang tetap maintainable saat proyek tumbuh melampaui demo sederhana.

## Catatan

- Repository ini saat ini berisi sample frame dan infrastruktur helper yang memang dimaksudkan untuk diperluas.
- Beberapa label dan toast message di sample code masih memakai Bahasa Indonesia, jadi ini penting jika Anda ingin menstandarkan bahasa aplikasi.
- Script build yang tersedia bersifat spesifik ke environment lokal dan sebaiknya diperlakukan sebagai convenience script.

## Lisensi

Proyek ini menggunakan Apache License 2.0. Lihat [LICENSE](LICENSE) untuk teks lisensi lengkap dan [NOTICE](NOTICE) untuk informasi atribusi.