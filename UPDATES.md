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
