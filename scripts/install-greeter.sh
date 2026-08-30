#!/bin/bash
set -e

# =========================================================
# Bulldoze 3.0 — QuickShell Greeter Installer for Greetd
# =========================================================

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="/etc/greetd/bulldoze-greeter"
START_SCRIPT="/usr/local/bin/bulldoze-greeter-start"

echo "==> Instalando Bulldoze QuickShell Greeter..."

# 1. Cria diretório de destino
sudo mkdir -p "$TARGET_DIR"
sudo mkdir -p "$TARGET_DIR/components"
sudo mkdir -p "$TARGET_DIR/modules"
sudo mkdir -p "$TARGET_DIR/scripts"

# 2. Copia arquivos necessários do QuickShell
sudo cp "$SRC_DIR/greeter.qml" "$TARGET_DIR/shell.qml"
sudo cp "$SRC_DIR/greeter.qml" "$TARGET_DIR/greeter.qml"

if [ -d "$SRC_DIR/components" ]; then
    sudo cp -r "$SRC_DIR/components/"* "$TARGET_DIR/components/" 2>/dev/null || true
fi

if [ -d "$SRC_DIR/modules" ]; then
    sudo cp -r "$SRC_DIR/modules/"* "$TARGET_DIR/modules/" 2>/dev/null || true
fi

sudo cp "$SRC_DIR/scripts/greetd-client.py" "$TARGET_DIR/scripts/"
sudo chmod +x "$TARGET_DIR/scripts/greetd-client.py"

# 3. Ajusta permissões para leitura pelo usuário 'greeter'
sudo chown -R root:greeter "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"

# 3.1 Permissões dos wallpapers em /var/lib/greetd
sudo touch /var/lib/greetd/Wallpaper_greeter.png 2>/dev/null || true
sudo chown paulo:greeter /var/lib/greetd/Wallpaper_greeter* 2>/dev/null || true
sudo chmod 664 /var/lib/greetd/Wallpaper_greeter* 2>/dev/null || true

# 4. Atualiza o script de inicialização do greeter
sudo tee "$START_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
set -e

# =========================================================
# Bulldoze Greeter — Bootstrap (QuickShell Greeter)
# =========================================================

/usr/local/bin/bulldoze-greeter-wallpaper

exec quickshell -p /etc/greetd/bulldoze-greeter
EOF

sudo chmod 755 "$START_SCRIPT"

echo "==> QuickShell Greeter instalado com sucesso em $TARGET_DIR!"
echo "==> Script de bootstrap atualizado em $START_SCRIPT."
