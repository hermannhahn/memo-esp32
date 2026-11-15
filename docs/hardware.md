# MEMO ESP32 — Hardware Reference

## Default Target: ESP32-S3 N16R8 OLED 0.96"/0.98"

- **Board Identifier**: `nologo/xingzhi-cube-0.96oled-wifi` (or legacy `aidlite-esp32s3n16r8-096oled-wifi`)
- **MCU**: Espressif ESP32-S3 (Xtensa Dual-Core 32-bit LX7 up to 240 MHz)
- **Flash**: 16 MB Octal SPI Flash
- **PSRAM**: 8 MB Octal SPI PSRAM
- **Networking**: Wi-Fi 802.11 b/g/n + Bluetooth 5 (LE)

---

## Pinout & Peripherals

| Function | Pin | Notes |
|---|---|---|
| **I2S Mic WS** | `GPIO_NUM_4` | Audio capture Word Select (LRCLK) |
| **I2S Mic SCK** | `GPIO_NUM_5` | Audio capture Bit Clock (BCLK) |
| **I2S Mic DIN** | `GPIO_NUM_6` | Audio capture Data In |
| **I2S Spk DOUT** | `GPIO_NUM_7` | Audio playback Data Out |
| **I2S Spk BCLK** | `GPIO_NUM_15` | Audio playback Bit Clock |
| **I2S Spk LRCK** | `GPIO_NUM_16` | Audio playback Left/Right Clock |
| **Display SDA** | `GPIO_NUM_41` | I2C Data line for SSD1306/SSD1315 OLED |
| **Display SCL** | `GPIO_NUM_42` | I2C Clock line for SSD1306/SSD1315 OLED |
| **Built-in LED** | `GPIO_NUM_48` | Status LED |
| **Boot Button** | `GPIO_NUM_0` | Multifunction / Setup button |
| **Volume Up** | `GPIO_NUM_40` | Pushbutton for volume increase |
| **Volume Down** | `GPIO_NUM_39` | Pushbutton for volume decrease |
| **Power Control** | `GPIO_NUM_21` | RTC GPIO for power hold / deep sleep |
| **Charging Status** | `GPIO_NUM_38` | Digital input for battery charging detection |
| **Battery ADC** | `ADC_CHANNEL_6` (GPIO 14) | Analog input for battery voltage measurement |

---

## Power & Battery Management

- **No-Battery USB Operation**: When powered solely through USB 5V without an attached battery, the battery ADC pin floats below `1800` counts.
- **Battery Presence Detection**: `PowerManager::IsBatteryPresent()` checks whether `average_adc > 1800` (roughly > 3.0V). If false, `GetBatteryLevel` returns `false`, preventing false 0% alarms ("Low battery, please charge").
- **Sleep Prevention**: The board disables deep sleep shutdown (`PowerSaveTimer(-1, 60, -1)`) when running without battery.
