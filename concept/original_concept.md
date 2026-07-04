Berikut adalah Technical Specification (Tech Spec) yang sangat detail untuk aplikasi "OpenCode Mobile Holistik". Spesifikasi ini dirancang untuk performa maksimal di Android dan iOS, serta responsif untuk perangkat Tablet.

1. Arsitektur Sistem & Desain
*   Framework: Flutter (Dart) – Pilihan terbaik untuk single codebase dengan performa native di kedua OS.
*   State Management: Riverpod atau Bloc (untuk mengelola state chat AI, status file Git, dan konfigurasi secara efisien).
*   Desain UI/UX: 
    *   Mobile: Single-pane layout dengan navigasi drawer/bottom bar.
    *   Tablet: Multi-pane layout (Split View). Kiri: File Explorer & Chat AI; Kanan: Markdown Editor & Preview.
    *   Responsiveness: Menggunakan LayoutBuilder dan MediaQuery untuk adaptasi otomatis.

2. Modul Inti (Core Modules)

A. Markdown Studio Module
Modul ini menangani pembuatan dan pengeditan konten.
*   Editor Engine: Menggunakan package flutter_quill atau super_editor karena mendukung rich text editing yang lebih stabil daripada raw text area biasa.
*   Rendering: flutter_markdown_plus untuk menampilkan hasil render Markdown yang akurat (termasuk tabel dan syntax highlighting kode).
*   Fitur: Auto-save ke local storage setiap 5 detik untuk mencegah kehilangan data.

B. OpenCode AI Agent Module
Modul ini menjadi "otak" dari aplikasi.
*   Koneksi: 
    *   Local: Mengintegrasikan OpenCode CLI melalui FFI (Foreign Function Interface) jika berjalan di Termux/iSH.
    *   Remote: WebSocket client untuk terhubung ke HTTP Server OpenCode di VPS.
*   Streaming: Menampilkan respons AI secara real-time (token-by-token) agar user tidak menunggu lama.
*   Context Awareness: Otomatis menyertakan isi file Markdown yang sedang dibuka sebagai konteks saat user meminta bantuan AI.

C. Git Manager Module
Modul ini menangani version control tanpa perlu keluar dari aplikasi.
*   Library: libgit2dart (bindings Dart untuk libgit2). Ini memungkinkan operasi Git (clone, add, commit, push) berjalan secara native di dalam aplikasi tanpa bergantung pada shell command eksternal.
*   Authentication: Integrasi aman dengan GitHub OAuth atau Personal Access Token (PAT) menggunakan flutter_secure_storage.
*   Conflict Resolution: UI khusus untuk menampilkan konflik merge jika terjadi saat pull/push.

3. Optimasi Mobile & Tablet
Aspek   Strategi Optimasi
Performa   Menggunakan Isolates untuk proses berat (seperti parsing Markdown besar atau operasi Git) agar UI tetap mulus (60fps).
Baterai   Membatasi polling status Git hanya saat aplikasi aktif. Menggunakan background fetch hanya jika diperlukan.
Layar Kecil   Menyembunyikan panel preview Markdown secara default di HP, bisa di-toggle via tombol floating.
Layar Besar (Tablet)   Memanfaatkan ruang ekstra untuk menampilkan file tree di sisi kiri dan chat AI di sisi kanan editor.

4. Struktur Folder Proyek (Flutter)

lib/
├── core/
│   ├── services/
│   │   ├── opencode_service.dart  # Koneksi ke AI Agent
│   │   ├── git_service.dart       # Operasi Git via libgit2
│   │   └── storage_service.dart   # Manajemen file lokal
│   └── utils/
│       └── markdown_parser.dart
├── features/
│   ├── editor/
│   │   ├── widgets/
│   │   │   ├── markdown_editor.dart
│   │   │   └── preview_pane.dart
│   │   └── cubit/
│   ├── ai_chat/
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   └── prompt_input.dart
│   │   └── cubit/
│   └── git_manager/
│       ├── widgets/
│       │   ├── repo_status_list.dart
│       │   └── commit_dialog.dart
│       └── cubit/
├── main.dart
└── app_router.dart

5. Tantangan Teknis & Solusi

1.  Sandbox iOS: Di iOS, Anda tidak bisa menjalankan proses CLI sembarangan. 
    *   Solusi: Gunakan libgit2dart untuk semua operasi Git agar berjalan murni di dalam memori aplikasi Dart, bukan memanggil terminal. Untuk OpenCode, gunakan mode Remote (VPS) atau integrasi terbatas via URL Scheme ke aplikasi Cosyra/iSH.
2.  Sinkronisasi Data: Memastikan file yang diedit di editor sama dengan yang dilihat oleh OpenCode.
    *   Solusi: Gunakan sistem file virtual atau pastikan path penyimpanan konsisten di Application Support Directory.
3.  Keamanan Token: 
    *   Solusi: Jangan pernah hardcode token. Gunakan biometric auth (FaceID/Fingerprint) sebelum mengizinkan fitur Push ke GitHub.

Langkah Selanjutnya
Jika Anda setuju dengan spesifikasi ini, kita bisa mulai dengan membuat Prototype UI terlebih dahulu menggunakan Flutter. Apakah Anda ingin saya buatkan contoh kode untuk bagian Markdown Editor dengan Live Preview-nya dulu?