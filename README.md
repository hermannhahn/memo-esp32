# MEMO ESP32

[![Release](https://img.shields.io/github/v/release/hermannhahn/memo-esp32?color=blue&logo=github)](https://github.com/hermannhahn/memo-esp32/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)

**MEMO ESP32** is a modular, AI-enabled voice assistant firmware built on Espressif's ESP-IDF framework. It supports real-time full-duplex voice interaction, smart device control, offline wake-word recognition, captive portal Wi-Fi provisioning, and automated Over-The-Air (OTA) updates via GitHub Releases.

---

## 🌟 Key Features

- **Real-Time Voice Streaming**: Opus audio capture and streaming via WebSocket and MQTT/UDP protocols.
- **Offline Wake-Word Engine**: Neural network wake-word detection powered by `esp-sr` (e.g. `Hi, ESP`).
- **Responsive Captive Portal**: Built-in modern web setup portal (`192.168.4.1`) for network and server credentials.
- **Automated OTA Updater**: Over-The-Air updates downloaded directly from [GitHub Releases](https://github.com/hermannhahn/memo-esp32/releases) with redirect following (`302`).
- **Battery & Power Awareness**: Intelligent power management with battery presence detection to prevent false low-battery alerts on USB power.
- **Multi-Hardware Architecture**: Modular board abstraction supporting OLED (SSD1306/SSD1315), LCD (ST7789, GC9A01, etc.), LEDs, and tactile buttons.

---

## 🛠️ Hardware Specification (Default Target)

- **Target Board**: `nologo/xingzhi-cube-0.96oled-wifi` (ESP32-S3 N16R8 OLED 0.96"/0.98")
- **MCU**: ESP32-S3 Dual-Core Xtensa LX7 @ 240 MHz
- **Memory**: 16 MB Octal Flash + 8 MB Octal PSRAM
- **Display**: 0.96" / 0.98" I2C OLED (128x64, SDA: GPIO 41, SCL: GPIO 42)
- **Audio Codec**: Simplex I2S Mic (WS: 4, SCK: 5, DIN: 6) + I2S Speaker (DOUT: 7, BCLK: 15, LRCK: 16)
- **Controls**: Boot button (GPIO 0), Vol+ (GPIO 40), Vol- (GPIO 39), Status LED (GPIO 48)

For detailed pinout and schematics, refer to [Hardware Reference](docs/hardware.md).

---

## 🚀 Quick Start

### 1. Build Firmware

```bash
# Using project CLI
memo build

# Or via batch script
build.bat
```

### 2. Flash to ESP32

Connect your ESP32 board via USB-C cable:

```bash
# Auto-detects serial port
memo flash

# Or specify port directly
memo flash COM3
```

### 3. Wi-Fi Configuration

1. Power on the device. If Wi-Fi is unconfigured, it broadcasts an AP: `MEMO-XXXX`.
2. Connect using your phone or PC and open `http://192.168.4.1`.
3. Select your Wi-Fi network, enter password, and save.

---

## 📖 Documentation

- [Hardware Reference](docs/hardware.md)
- [Build and Flash Guide](docs/build-and-flash.md)
- [WebSocket Protocol Specification](docs/websocket.md)
- [MQTT + UDP Protocol Specification](docs/mqtt-udp.md)
- [MCP Device Tools](docs/mcp-protocol.md)
- [Contributing Guidelines](CONTRIBUTIONS.md)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE.md](LICENSE.md) file for details.
