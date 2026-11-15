# Update History - MEMO ESP32

This file tracks improvements, fixes, and new features implemented in **MEMO ESP32**.

---

## [0.1.0] - 2026-11-15

### Initial Setup
- Initialized `memo-esp32` project structure based on clean upstream XiaoZhi firmware.
- Configured release build, fast development build, and flash scripts (`build.bat`, `build.ps1`, `build-dev.ps1`, `flash.bat`, `flash.ps1`).
- Implemented release and publication pipeline targeting `hermannhahn/memo-esp32` with automated OTA manifest generation.
- Added `dev-cli` tool exposing global `memo` and `memo-esp32` CLI commands (`dev-cli/bin/cli.js`, `cli.bat`).
- Configured default target for ESP32-S3 N16R8 OLED 0.96"/0.98" (`nologo/xingzhi-cube-0.96oled-wifi`) while retaining multi-board compilation support.
- Ported modern dark-themed web configuration portal (`192.168.4.1`) from `esp32-ai` into local component `components/esp-wifi-connect`.
- Removed manual OTA URL input field from the web UI to protect update settings, defaulting to `https://api.tenclass.net/xiaozhi/ota/`.
- Implemented real-time VAD RMS audio volume meter bar (`/advanced/vad_rms`) in the web interface with show/hide password visibility toggle.
- Updated `main/ota.cc` to follow HTTP redirects (allowing direct download from GitHub release assets).
- Enhanced OTA parser to handle both standard OTA server payloads and direct `manifest.json` structures.
- Verified dual binary generation and release upload: full merged binary for cable flashing and reduced app binary (`memo-esp32-app-v<version>.bin`) for OTA updates.
