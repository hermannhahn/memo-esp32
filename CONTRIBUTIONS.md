# Contributing to MEMO ESP32

Thank you for your interest in contributing to **MEMO ESP32**!

## 1. Code & Language Standards (Strict)

- **100% US English**: All code, function names, variables, struct fields, comments, docstrings, commits, and terminal outputs must be strictly in English.
- **No Portuguese Hardcoded**: Any language-specific strings must only exist inside localization dictionaries (`assets/lang_config.h` or i18n modules).

## 2. Architecture & Board Abstraction

- **Modular Boards**: Each board implementation must reside in its own subdirectory under `main/boards/` (e.g. `main/boards/nologo/xingzhi-cube-0.96oled-wifi/`).
- **Never Hardcode Board Pins in Core**: Core files (`main/application.*`, `main/ota.*`, `main/protocols/`) must interact with hardware exclusively via abstract `Board` interfaces.
- **Factory Registration**: Exactly one board factory is exported per build via `DECLARE_BOARD(...)`.

## 3. Git Workflow

- **Branching**:
  - `development`: Active integration branch. All pull requests, feature branches, and bug fixes must branch off and merge into `development`.
  - `main`: Protected production branch containing stable tagged releases.
- **Semantic Commits**:
  - `feat(...)`: New features
  - `fix(...)`: Bug fixes
  - `docs(...)`: Documentation updates
  - `refactor(...)`: Code refactoring without behavioral changes
  - `chore(...)`: Tooling, build system, or dependency updates

## 4. Build & Validation

Before submitting changes:
1. Build the firmware using `./build.bat` or `memo build`.
2. Format touched C/C++ files with `.clang-format`.
3. Test on physical hardware whenever possible using `flash.bat` or `memo flash`.
