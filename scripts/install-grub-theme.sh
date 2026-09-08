#!/bin/bash
set -e

# =========================================================
# Bulldoze 3.0 — GRUB Theme Installer & Configurator
# Native QHD (2560x1440) Left-Docked Notch Theme
# =========================================================

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../grub" && pwd)"
TARGET_DIR="/boot/grub/themes/bulldoze"
GRUB_DEFAULT="/etc/default/grub"

echo "==> Instalando Bulldoze 3.0 GRUB Theme..."

# 1. Cria diretório de destino
sudo mkdir -p "$TARGET_DIR"
sudo mkdir -p "$TARGET_DIR/fonts"
sudo mkdir -p "$TARGET_DIR/icons"

# 2. Copia arquivos de tema, assets, fontes e ícones
echo "==> Copiando assets visuais e fontes..."
sudo cp "$SRC_DIR/theme.txt" "$TARGET_DIR/"
sudo cp "$SRC_DIR/notch_panel.png" "$TARGET_DIR/" 2>/dev/null || true
sudo cp "$SRC_DIR/selected.png" "$TARGET_DIR/" 2>/dev/null || true
sudo cp -f "$SRC_DIR/select_"*.png "$TARGET_DIR/" 2>/dev/null || true
sudo cp "$SRC_DIR/background.png" "$TARGET_DIR/"
sudo cp "$SRC_DIR/dot.png" "$TARGET_DIR/" 2>/dev/null || true

# Copia fontes e ícones
sudo cp -r "$SRC_DIR/fonts/"* "$TARGET_DIR/fonts/" 2>/dev/null || true
sudo cp -f "$SRC_DIR/fonts/"*.pf2 "$TARGET_DIR/" 2>/dev/null || true
sudo cp -r "$SRC_DIR/icons/"* "$TARGET_DIR/icons/" 2>/dev/null || true

# 3. Configura sincronização dinâmica de wallpaper pelo Bulldoze
echo "==> Configurando sincronização dinâmica do wallpaper..."
CURRENT_USER="${SUDO_USER:-$USER}"

# Como /boot normalmente é uma partição VFAT (FAT32/ESP), chown/chmod não são suportados.
# Configuramos um helper /usr/local/bin/bulldoze-sync-grub-bg com permissão sudo sem senha:
SYNC_HELPER="/usr/local/bin/bulldoze-sync-grub-bg"
sudo tee "$SYNC_HELPER" > /dev/null << EOF
#!/bin/bash
CACHE_BG="/home/${CURRENT_USER}/.cache/bulldoze/grub_background.png"
THEME_DIR="/home/${CURRENT_USER}/.config/quickshell/bulldoze/grub"
TARGET_DIR="${TARGET_DIR}"

if [ -f "\$CACHE_BG" ]; then
    cp -f "\$CACHE_BG" "\${TARGET_DIR}/background.png"
fi
if [ -d "\$THEME_DIR" ]; then
    cp -f "\$THEME_DIR/theme.txt" "\$THEME_DIR/selected.png" "\$THEME_DIR/select_"*.png "\${TARGET_DIR}/" 2>/dev/null || true
    cp -f "\$THEME_DIR/fonts/"*.pf2 "\${TARGET_DIR}/" 2>/dev/null || true
    cp -rf "\$THEME_DIR/icons" "\${TARGET_DIR}/" 2>/dev/null || true
fi
EOF
sudo chmod 755 "$SYNC_HELPER"

SUDOERS_FILE="/etc/sudoers.d/bulldoze-grub"
sudo tee "$SUDOERS_FILE" > /dev/null << EOF
${CURRENT_USER} ALL=(ALL) NOPASSWD: ${SYNC_HELPER}
EOF
sudo chmod 440 "$SUDOERS_FILE"

# 4. Configuração em /etc/default/grub
if [ -f "$GRUB_DEFAULT" ]; then
    echo "==> Verificando configuração em $GRUB_DEFAULT..."
    
    # Adiciona ou atualiza GRUB_THEME
    if grep -q "^GRUB_THEME=" "$GRUB_DEFAULT"; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$TARGET_DIR/theme.txt\"|" "$GRUB_DEFAULT"
    else
        echo "GRUB_THEME=\"$TARGET_DIR/theme.txt\"" | sudo tee -a "$GRUB_DEFAULT" > /dev/null
    fi

    # Configura resolução nativa de 2560x1440
    if grep -q "^GRUB_GFXMODE=" "$GRUB_DEFAULT"; then
        sudo sed -i "s|^GRUB_GFXMODE=.*|GRUB_GFXMODE=\"2560x1440,auto\"|" "$GRUB_DEFAULT"
    else
        echo "GRUB_GFXMODE=\"2560x1440,auto\"" | sudo tee -a "$GRUB_DEFAULT" > /dev/null
    fi
fi

# 5. Atualização do grub.cfg
echo "==> Gerando grub.cfg..."
if command -v grub-mkconfig >/dev/null 2>&1; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "==> Tema Bulldoze 3.0 para GRUB instalado com sucesso em $TARGET_DIR!"
