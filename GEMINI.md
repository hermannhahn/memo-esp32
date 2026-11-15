# MEMO ESP32 — Project Context & Agent Governance

This document serves as the project governance and technical manual for **MEMO ESP32**.

---

## 1. Project Overview & Repository

- **Repository**: [hermannhahn/memo-esp32](https://github.com/hermannhahn/memo-esp32)
- **Base Framework**: ESP-IDF voice assistant firmware (modular board abstraction, audio pipeline, protocol engine, display managers).
- **Target Hardware (Default)**: ESP32-S3 N16R8 (16MB Flash, 8MB Octal PSRAM) with 0.96"/0.98" OLED Display (`nologo/xingzhi-cube-0.96oled-wifi`).
- **Extensibility**: Multi-board support is preserved natively via `scripts/build.py`. Any supported board in `main/boards/` can be built and flashed.

---

## 2. Command Execution Priority

Always follow this order before executing any build, flash, or publication command:

1. **`dev-cli`** (`memo <command>`) or root helper (`cli.bat <command>`)
2. **Batch Scripts** in project root (`build.bat`, `flash.bat`, `publish.bat`)
3. **PowerShell Scripts** in project root (`build.ps1`, `build-dev.ps1`, `flash.ps1`, `publish.ps1`)
4. Direct native commands (`python scripts/build.py`, `idf.py`)

---

## 3. Available CLI Commands (`memo`)

| Command | Action |
|---|---|
| `memo build [board] [variant]` | Full release build via `build.ps1` (`build.py` + `merge-bin` + copies to `releases/`). |
| `memo build-dev [board]` | Fast developer build via `build-dev.ps1` without release packaging. |
| `memo flash [port]` | Flashes compiled binary to ESP32 (default port: `COM4`). |
| `memo test [port]` | Runs `build-dev` followed immediately by `flash`. |
| `memo publish [major\|minor\|patch] [--reset-updates]` | Merges `development` -> `main`, updates `releases/manifest.json`, pushes to GitHub, creates GitHub Release on `hermannhahn/memo-esp32`, and bumps next cycle version. |
| `memo release [version]` | Full sequence: `build` followed by `publish`. |
| `memo compile [board] [flags]` | Custom board compilation via `scripts/build.py`. |
| `memo list-boards` | Lists all supported board targets and variants. |
| `memo gen-lang` | Updates language configuration and translation dictionaries. |
| `memo assets` | Compiles default SPIFFS asset image. |
| `memo audio-debug` | Starts audio streaming debug server. |

---

## 4. Git Flow & Release Lifecycle

- **`main`**: Protected production branch containing stable releases and release tags.
- **`development`**: Active integration branch where features and fixes are merged.
- **Workflow**:
  1. Work on temporary feature/fix branches created from `development`.
  2. Validate changes using `memo build-dev` and `memo flash`.
  3. Merge into `development` and push.
  4. Build release binary: `memo build`.
  5. Publish official release: `memo publish [patch|minor|major]`.

---

## 5. Language & Code Standards

- **Code, Frontend & Automation**: 100% US English. No Portuguese hardcoded in code, variables, functions, scripts, comments, docstrings, or terminal logs.
- **Chat**: Brazilian Portuguese for user conversation.
