#!/bin/bash
# =========================================================
# Bulldoze 3.0 — GRUB Theme Live Preview (QEMU)
# Testa o tema do GRUB em uma janela gráfica sem reiniciar
# =========================================================

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../grub" && pwd)"
RESOLUTION="2560x1440"

# 1. Não rodar como root/sudo (impede conexão com a janela Wayland/Hyprland)
if [ "$EUID" -eq 0 ]; then
    echo "==> AVISO: Não execute o preview com 'sudo'!"
    echo "O QEMU precisa abrir uma janela gráfica na sua sessão de usuário normal."
    if [ -n "$SUDO_USER" ]; then
        echo "Redirecionando execução para o usuário '$SUDO_USER'..."
        exec sudo -u "$SUDO_USER" "$0" "$@"
    fi
    exit 1
fi

# 2. Verifica se o grub2-theme-preview está instalado
if ! command -v grub2-theme-preview &> /dev/null; then
    echo "==> 'grub2-theme-preview' não está instalado."
    echo "Para instalar no Arch/CachyOS:"
    echo "    yay -S grub2-theme-preview qemu-desktop xorriso"
    exit 1
fi

# 3. Detecta se KVM está disponível
EXTRA_ARGS=()
if [ ! -e /dev/kvm ]; then
    echo "==> /dev/kvm não detectado. Usando modo de compatibilidade (--no-kvm)..."
    EXTRA_ARGS+=("--no-kvm")
fi

# Notifica o usuário com as instruções para desvincular o mouse/teclado do QEMU
if command -v notify-send &> /dev/null; then
    notify-send "Bulldoze GRUB Preview" "Pressione [Ctrl + Alt + G] para liberar o mouse/teclado, ou use Machine > Quit." -i preferences-desktop-theme -t 8000
fi

echo "========================================================="
echo "==> Iniciando preview do tema GRUB em $RESOLUTION..."
echo "==> ATENÇÃO: A janela do QEMU captura o mouse e teclado!"
echo "==> Para liberar o cursor e usar seus atalhos normais:"
echo "==> Pressione [Ctrl + Alt + G] ou feche pelo menu Machine -> Quit."
echo "========================================================="

exec grub2-theme-preview --resolution "$RESOLUTION" --display "gtk,show-cursor=on" "${EXTRA_ARGS[@]}" "$THEME_DIR"
