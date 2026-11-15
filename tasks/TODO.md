# Tasks & Project Roadmap — MEMO ESP32

## In Progress / Active Sprint
- [x] Establish base firmware compilation and esptool flash for ESP32-S3 N16R8 OLED 0.98"
- [x] Fix false battery warning on USB power (`battery_present_` ADC threshold > 1800)
- [x] Setup comprehensive project documentation (`README.md`, `LICENSE.md`, `CONTRIBUTIONS.md`, `docs/`)
- [x] Implement unified development and release CLI (`cli/cli.js`, `cli.bat`, `memo.bat`)
- [x] Create standardized deploy skill (`.agents/skills/deploy-release/SKILL.md`)
- [ ] Port modernized web configuration portal (192.168.4.1) from `../esp32-ai`
- [ ] Implement dual platform connectivity: XiaoZhi server protocol + MEMOROUTER agent platform (WSL `workspace/memorouter`)
- [ ] Configure OTA updater to pull releases directly from `hermannhahn/memo-esp32`
- [ ] Multi-target compilation support (N16R8 OLED 0.98", 1.54" TFT, custom ESP32-S3 boards)
