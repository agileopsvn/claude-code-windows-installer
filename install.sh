#!/bin/bash
# Claude Code macOS Installer
# Installs Claude Code and all dependencies on macOS
#
# Usage:
#   ./install.sh                    # Interactive installation
#   ./install.sh --silent           # Auto-accept all prompts
#   ./install.sh --debug            # Enable debug output
#   curl -fsSL <url>/install.sh | bash   # One-liner install
#
# What gets installed:
#   - Homebrew (if missing)
#   - Git (via Homebrew)
#   - nvm + Node.js 20.x
#   - uv + Python 3.10.x
#   - Python packages: pymupdf, pandoc, docling
#   - 1Password CLI (op)
#   - Claude Code
#   - @anthropic-ai/agent-browser

set -euo pipefail

# --- Configuration ---
NODE_VERSION="20.18.0"
NODE_MIN_MAJOR=20
PYTHON_VERSION="3.10.11"
PIP_PACKAGES=("pymupdf" "pandoc" "docling")

# --- Flags ---
SILENT=false
DEBUG=false

for arg in "$@"; do
    case "$arg" in
        --silent|-y) SILENT=true ;;
        --debug) DEBUG=true ;;
    esac
done

# --- Helpers ---

color_reset="\033[0m"
color_red="\033[0;31m"
color_green="\033[0;32m"
color_yellow="\033[0;33m"
color_cyan="\033[0;36m"
color_magenta="\033[0;35m"
color_gray="\033[0;90m"

info()    { printf "${color_cyan}%s${color_reset}\n" "$*"; }
success() { printf "${color_green}%s${color_reset}\n" "$*"; }
warn()    { printf "${color_yellow}%s${color_reset}\n" "$*"; }
error()   { printf "${color_red}%s${color_reset}\n" "$*"; }
debug()   { [[ "$DEBUG" == true ]] && printf "${color_gray}[DEBUG] %s${color_reset}\n" "$*"; }

confirm() {
    local msg="$1"
    local default="${2:-N}"

    if [[ "$SILENT" == true ]]; then
        printf "%s -> Auto-accepting (silent mode)\n" "$msg"
        return 0
    fi

    local prompt
    if [[ "$default" == "Y" ]]; then
        prompt="$msg [Y/n]: "
    else
        prompt="$msg [y/N]: "
    fi

    read -rp "$prompt" response
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy] ]]
}

command_exists() {
    command -v "$1" &>/dev/null
}

# --- Banner ---

printf "\n${color_magenta}========================================${color_reset}\n"
printf "${color_magenta}     Claude Code Installer (macOS)      ${color_reset}\n"
printf "${color_magenta}========================================${color_reset}\n\n"

# --- Check macOS ---

if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This installer is for macOS only. Use install.bat for Windows."
    exit 1
fi

debug "macOS $(sw_vers -productVersion) detected"
debug "Architecture: $(uname -m)"

# --- Homebrew ---

info "Checking system requirements..."
echo

if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session (Apple Silicon vs Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew installed!"
else
    success "Homebrew is already installed."
fi

# Ensure brew is on PATH
if ! command_exists brew; then
    error "Homebrew not found on PATH after installation. Please restart your terminal and re-run."
    exit 1
fi

# --- Git ---

echo
if ! command_exists git; then
    info "Installing Git via Homebrew..."
    brew install git
    success "Git installed!"
else
    success "Git is already installed ($(git --version))."
fi

# --- nvm + Node.js ---

echo
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -d "$NVM_DIR" ]] || ! command_exists nvm 2>/dev/null; then
    info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Source nvm for current session
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    success "nvm installed!"
else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    success "nvm is already installed."
fi

# Check Node.js version
node_ok=false
if command_exists node; then
    node_major=$(node -v | sed 's/v//' | cut -d. -f1)
    if [[ "$node_major" -ge "$NODE_MIN_MAJOR" ]]; then
        node_ok=true
        success "Node.js $(node -v) is installed and meets minimum requirement."
    else
        warn "Node.js $(node -v) found, but v${NODE_MIN_MAJOR}+ is required."
    fi
fi

if [[ "$node_ok" == false ]]; then
    info "Installing Node.js v${NODE_VERSION} via nvm..."
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    success "Node.js v${NODE_VERSION} installed and set as default!"
fi

# --- uv + Python ---

echo
if ! command_exists uv; then
    info "Installing uv (fast Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Add uv to PATH for current session
    if [[ -f "$HOME/.local/bin/uv" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    elif [[ -f "$HOME/.cargo/bin/uv" ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    success "uv installed!"
else
    success "uv is already installed ($(uv --version))."
fi

# Install Python via uv
python_ok=false
if command_exists python3; then
    py_version=$(python3 --version 2>&1 | awk '{print $2}')
    if [[ "$py_version" == "$PYTHON_VERSION"* ]]; then
        python_ok=true
        success "Python $py_version is already installed."
    fi
fi

if [[ "$python_ok" == false ]]; then
    info "Installing Python ${PYTHON_VERSION} via uv..."
    uv python install "$PYTHON_VERSION"
    success "Python ${PYTHON_VERSION} installed via uv!"
fi

# --- Python packages (pymupdf, pandoc, docling) ---

echo
info "Installing Python packages via uv..."
for pkg in "${PIP_PACKAGES[@]}"; do
    info "  Installing $pkg..."
    if uv pip install --system "$pkg" 2>/dev/null; then
        success "  $pkg installed."
    else
        # Try with uv tool install as fallback
        if uv pip install "$pkg" 2>/dev/null; then
            success "  $pkg installed."
        else
            warn "  Warning: Failed to install $pkg. Install manually: uv pip install $pkg"
        fi
    fi
done

# --- pandoc binary (separate from Python pandoc package) ---

echo
if ! command_exists pandoc; then
    info "Installing pandoc via Homebrew..."
    brew install pandoc
    success "pandoc installed!"
else
    success "pandoc is already installed ($(pandoc --version | head -1))."
fi

# --- 1Password CLI ---

echo
if ! command_exists op; then
    info "Installing 1Password CLI (op)..."
    brew install --cask 1password-cli 2>/dev/null || brew install 1password-cli 2>/dev/null
    if command_exists op; then
        success "1Password CLI installed!"
    else
        warn "1Password CLI installation failed. Install manually: brew install --cask 1password-cli"
    fi
else
    success "1Password CLI is already installed ($(op --version))."
fi

# --- Claude Code ---

echo
if ! command_exists claude; then
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    success "Claude Code installed!"
else
    success "Claude Code is already installed."
    if confirm "Would you like to reinstall Claude Code?" "N"; then
        npm install -g @anthropic-ai/claude-code
        success "Claude Code reinstalled!"
    fi
fi

# --- @anthropic-ai/agent-browser ---

echo
if ! command_exists agent-browser; then
    info "Installing @anthropic-ai/agent-browser..."
    npm install -g @anthropic-ai/agent-browser
    success "@anthropic-ai/agent-browser installed!"

    info "Installing browser for agent-browser..."
    npx agent-browser install 2>/dev/null || warn "Browser install failed. Run 'agent-browser install' manually."
else
    success "@anthropic-ai/agent-browser is already installed."
fi

# --- Shell profile setup ---

echo
info "Ensuring shell profile is configured..."

SHELL_PROFILE=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    debug "Shell profile: $SHELL_PROFILE"

    # Ensure Homebrew is in profile
    if ! grep -q 'brew shellenv' "$SHELL_PROFILE" 2>/dev/null; then
        if [[ -f /opt/homebrew/bin/brew ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$SHELL_PROFILE"
        elif [[ -f /usr/local/bin/brew ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$SHELL_PROFILE"
        fi
        success "Added Homebrew to $SHELL_PROFILE"
    fi

    # Ensure nvm is in profile
    if ! grep -q 'NVM_DIR' "$SHELL_PROFILE" 2>/dev/null; then
        cat >> "$SHELL_PROFILE" << 'NVMEOF'

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
NVMEOF
        success "Added nvm to $SHELL_PROFILE"
    fi

    # Ensure uv/local bin is in profile
    if ! grep -q '.local/bin' "$SHELL_PROFILE" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_PROFILE"
        success "Added ~/.local/bin to PATH in $SHELL_PROFILE"
    fi
fi

# --- Done ---

echo
printf "${color_green}========================================${color_reset}\n"
printf "${color_green}    Installation Complete!              ${color_reset}\n"
printf "${color_green}========================================${color_reset}\n"
echo
echo "Installed tools:"
echo "  - Git, nvm + Node.js v${NODE_VERSION}"
echo "  - uv + Python ${PYTHON_VERSION}"
echo "  - Python packages: ${PIP_PACKAGES[*]}"
echo "  - pandoc, 1Password CLI (op)"
echo "  - Claude Code, @anthropic-ai/agent-browser"
echo
echo "How to use:"
echo "  - Open Terminal, navigate to a project folder, and type 'claude'"
echo "  - Or run 'claude' from any directory"
echo
warn "Important:"
warn "The first time you open Claude Code, you'll be asked to authenticate."
warn "Select #2 'Billing Account'. Your browser will open to login."
echo
warn "Please restart your terminal or run: source $SHELL_PROFILE"
