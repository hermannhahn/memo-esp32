# MEMO ESP32 — Build and Flash Guide

## 1. Prerequisites

- **Host OS**: Windows 11 / Linux
- **ESP-IDF**: v5.5.4 (installed at `C:\Users\herma\AppData\Local\Programs\esp\v5.5.4` on Windows)
- **Python**: 3.12 (in `.espressif/python_env/idf5.5_py3.12_env`)
- **Node.js**: v18+ (for `dev-cli`)
- **GitHub CLI**: `gh` authenticated for release management

---

## 2. CLI Usage (`memo` / `cli.bat`)

The project includes a command-line interface linked globally:

```bash
# Build release binaries for default board
memo build

# Build specific board target and variant
memo build nologo/xingzhi-cube-0.96oled-wifi xingzhi-cube-0.96oled-wifi

# Fast development build (skips packaging)
memo build-dev

# Flash to connected board (auto-detects COM port)
memo flash

# Flash to specific COM port
memo flash COM3

# Test: build-dev + flash in one command
memo test COM3

# Publish new release to GitHub (merges development -> main, tags, uploads assets)
memo publish patch
```

---

## 3. Binaries & Packaging

Each build produces two primary binaries in `releases/`:

1. **Merged Binary (Cable Flash)**:
   - File: `memo-esp32-v<version>-<hardware>.bin` (e.g. `memo-esp32-v0.0.1-n16r8-oled098.bin`)
   - Offset: `0x0`
   - Contains: Bootloader (`0x0`), Partition Table (`0x8000`), OTA Data (`0xd000`), App Executable (`0x20000`), and Assets (`0x800000`).

2. **App Binary (OTA Updates)**:
   - File: `memo-esp32-app-v<version>-<hardware>.bin` (e.g. `memo-esp32-app-v0.0.1-n16r8-oled098.bin`)
   - Size: ~2.5 MB
   - Targets the active `ota_0` or `ota_1` partition during over-the-air updates.

3. **OTA Manifest**:
   - `releases/manifest.json` tracks device targets and download URLs on GitHub Releases.
