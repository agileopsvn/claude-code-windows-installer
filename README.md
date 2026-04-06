# Claude Code Installer

A one-click installer for [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) on Windows and macOS. Automatically installs all required dependencies for a complete AI-assisted development environment.

## What Gets Installed

| Tool | Purpose |
|------|---------|
| **Git + Git Bash** | Version control and terminal |
| **Node.js 20.18.0** | Required for Claude Code (via nvm-windows on Windows, nvm on macOS) |
| **Claude Code** | `@anthropic-ai/claude-code` - the main CLI |
| **uv** | Fast Python package manager (replaces pip/pyenv) |
| **Python 3.10.11** | Installed via uv |
| **pymupdf** | PDF processing library |
| **pandoc** | Document conversion tool |
| **docling** | Document parsing library |
| **1Password CLI (`op`)** | Secret management |
| **agent-browser** | `@anthropic-ai/agent-browser` - Claude browser automation |
| **Windows context menu** | Right-click "Open with Claude Code" (Windows only) |

---

## Windows

### Quick Install

> **Run from an Administrator Command Prompt.**

**Step 1 - Open Command Prompt as Administrator:**
- Press **Windows key**, type `cmd`
- Right-click **Command Prompt** → **Run as administrator**
- Click **Yes** on the UAC prompt

**Step 2 - Run:**

```cmd
curl -L --ssl-no-revoke "https://raw.githubusercontent.com/agileopsvn/claude-code-windows-installer/main/install.bat" -o install.bat && install.bat
```

**Silent mode** (no prompts, for automated installs):
```cmd
curl -L --ssl-no-revoke "https://raw.githubusercontent.com/agileopsvn/claude-code-windows-installer/main/install.bat" -o install.bat && install.bat -silent
```

**Debug mode** (verbose output for troubleshooting):
```cmd
install.bat -debug
```

### From Cloned Repository

```cmd
git clone https://github.com/agileopsvn/claude-code-windows-installer.git
cd claude-code-windows-installer
install.bat
```

The installer auto-detects local files and skips downloading them.

---

## macOS

### Quick Install

```bash
curl -fsSL "https://raw.githubusercontent.com/agileopsvn/claude-code-windows-installer/main/install.sh" | bash
```

**Silent mode:**
```bash
curl -fsSL "https://raw.githubusercontent.com/agileopsvn/claude-code-windows-installer/main/install.sh" -o install.sh && bash install.sh --silent
```

**Debug mode:**
```bash
bash install.sh --debug
```

### From Cloned Repository

```bash
git clone https://github.com/agileopsvn/claude-code-windows-installer.git
cd claude-code-windows-installer
bash install.sh
```

---

## After Installation

**Verify everything is installed:**
```bash
# Windows (Git Bash) or macOS (Terminal)
claude --version
node --version
uv --version
python --version
op --version
agent-browser --version
```

**Start using Claude Code:**
- **Windows**: Right-click any project folder → "Open with Claude Code" (opens Git Bash)
- **macOS/Windows Git Bash**: Navigate to your project and run `claude`
- First run opens a browser for login (one-time setup)

---

## Features

- **Silent mode** - `install.bat -silent` / `install.sh --silent` for automated/unattended installs
- **Smart detection** - Skips already-installed components, prompts to upgrade when outdated
- **Architecture aware** - Handles 32-bit and 64-bit Windows automatically
- **Admin elevation** - Windows installer auto-requests elevation when needed
- **Configuration-driven** - Versions defined in `src/config.json`, no code changes needed to update
- **Dual download fallback** - Falls back from curl to PowerShell if curl unavailable (Windows)

---

## Troubleshooting

### Download failures
- Corporate firewalls may block GitHub raw content
- Some Windows systems lack curl (installer falls back to PowerShell automatically)
- Try `install.bat -debug` for detailed download diagnostics

### SSL certificate errors (`CRYPT_E_NO_REVOCATION_CHECK`)
The curl command already includes `--ssl-no-revoke`. Alternatively use PowerShell:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/agileopsvn/claude-code-windows-installer/main/install.bat" -OutFile install.bat; .\install.bat
```

### Admin privilege issues
- Must open Command Prompt as Administrator before running the install command
- Some antivirus software may interfere with elevation

### Node.js version conflicts
- The installer uses nvm for version management
- Uninstall any existing MSI-based Node.js before running if you hit conflicts
- Use `nvm list` and `nvm use <version>` to switch versions after install

---

## Version Reference

Current versions (from `src/config.json`):

| Dependency | Version |
|------------|---------|
| Node.js | 20.18.0 |
| Git for Windows | 2.53.0 |
| Python (via uv) | 3.10.11 |

To update versions, edit `src/config.json` - no code changes required.

---

## File Structure

```
claude-code-windows-installer/
├── install.bat          # Windows entry point (curl-ready, admin-aware)
├── install.sh           # macOS entry point
├── src/
│   ├── installer.ps1    # Windows PowerShell installer
│   └── config.json      # Version and URL configuration
├── assets/
│   └── claude-color.ico # Custom context menu icon (Windows)
├── README.md
└── CLAUDE.md            # Development documentation
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.
