# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Removed
- `Install-MarkerPdf` function and `marker-pdf[full]` pip installation step

---

## [1.4.0] - 2026-03-18

### Added
- Python installation via pyenv-win with `Install-Python` function
- `marker-pdf[full]` dependency installed via pip after Python setup

### Fixed
- Python version pinned to 3.10.11 for stability
- `pyenv update` runs before install to ensure version list is current
- Improved error handling and reliability for pyenv-based Python setup
- Clarified admin requirement in README with step-by-step instructions

---

## [1.3.0] - 2026-03-09

### Added
- `--ssl-no-revoke` flag on all curl commands to fix certificate revocation errors in corporate environments
- Silent mode support (`-Silent` parameter)
- TLS 1.2 enforcement for all web requests
- Git Bash path verification after installation
- winget preferred for Git installation with direct download as fallback

### Changed
- nvm-windows switched to noinstall zip with manual setup for more reliable installation
- nvm-windows now uses NSIS silent install flag (`/S`)
- Default answer for Node.js install prompt changed to Yes
- Git dependency version updated to 2.53.0
- Execution policy set to `RemoteSigned` at installer start

### Fixed
- node/npm added to PATH by activating nvm immediately after install
- nvm symlink setup fixed by removing conflicting real directory before `nvm use`
- PowerShell argument quoting in launcher corrected
- Execution policy error handling added
- Repo URL migrated to new location

### Removed
- Atlassian MCP server integration

---

## [1.2.0] - 2025-07-25

### Added
- Comprehensive debug mode (`install.bat -debug` / `installer.ps1 -Debug`)
  - Verbose output for download, path, and execution diagnostics
  - `-NoExit` keeps PowerShell window open in debug mode
  - Debug parameter preserved through admin elevation
- Dual-method download fallback: curl primary, `Invoke-WebRequest` secondary
- Smart local/remote file detection in `install.bat`
  - Uses local `src/installer.ps1` and `src/config.json` when present
  - Auto-downloads from GitHub when files are absent
- Custom icon support for Windows Explorer context menu
  - Icon deployed to `%APPDATA%\ClaudeCode\` for persistence
  - Fallback to `shell32.dll,3` if deployment fails
- Interactive prompts with clear defaults for all installation steps
- Context menu Keep/Update/Remove options
- Atlassian MCP server detection and installation via Git Bash

### Changed
- Installer renamed from "START HERE" to `install.bat`
- `Get-UserConfirmation` shows `(default: Yes/No)` indicator
- Configuration-driven architecture with `src/config.json` for versions and URLs
- Admin elevation now preserves all command-line arguments

### Fixed
- Batch file delayed variable expansion (`!var!`) used consistently to fix URL construction
- Directory structure created before curl downloads to prevent write failures
- `-NoExit` added to normal mode PowerShell launch to prevent window closing prematurely
- Conditional `-NoExit` removed from admin elevation path for consistent behavior

---

## [1.1.0] - 2025-07-25

### Added
- Claude Code development tools and commands (`.claude/` directory)
- CLAUDE.md with architectural documentation and development patterns
- Comprehensive README with multiple installation methods

### Changed
- Enhanced installer with interactive prompts and improved user feedback
- `nvm-windows` chosen over Node.js MSI for version management

---

## [1.0.0] - 2025-07-25

### Added
- Initial Windows installer for Claude Code (`install.bat` + `src/installer.ps1`)
- Configuration file (`src/config.json`) with version and URL templates
- Admin privilege detection and self-elevation
- Git installation (winget or direct download)
- Node.js installation via nvm-windows
- Claude Code installation via npm
- Windows Explorer context menu integration
- Architecture detection (32-bit / 64-bit)
- Project standards and Claude Code documentation
