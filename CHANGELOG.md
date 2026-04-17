# Changelog

Semua perubahan penting pada proyek ini akan didokumentasikan di file ini.

Format mengacu pada [Keep a Changelog](https://keepachangelog.com/id/1.0.0/).

---

## [1.1.0] - 2026-04-17

### Ditambahkan
- Struktur folder enterprise: `configs/`, `scripts/`, `docs/`
- Script otomasi: `install_and_service.sh`, `create_ca.sh`, `setup_icap.sh`, `deploy_ca_windows.ps1`
- Script utilitas: `health_check.sh`, `backup_config.sh`, `rotate_logs.sh`
- Konfigurasi tambahan: `squid_ssl_bump.conf`, `whitelist.txt`
- Template GitHub: Issue dan Pull Request templates
- Panduan dokumentasi lengkap: client setup, verifikasi, SWG lanjutan
- `.gitignore` untuk melindungi file sensitif (CA key, password)
- File `LICENSE` (MIT)
- `CHANGELOG.md` ini

### Diubah
- Restrukturisasi total dari file-file tanpa ekstensi dan nama tidak valid
- README.md ditulis ulang dengan standar profesional
- Semua file kini menggunakan encoding UTF-8 yang konsisten

### Dihapus
- File dengan nama tidak valid (`contoh isi /etc/squid/...`)
- File duplikat (`konfigurasi ke 4` dan `konfigurasi ke 4.pdf`)

---

## [1.0.0] - 2026-02-01

### Ditambahkan
- Konfigurasi awal Squid Proxy di CentOS 7
- Catatan instalasi dan konfigurasi dasar
- Dokumen PDF hasil lab konfigurasi (bagian 1-4)
- Diagram topologi jaringan virtual
