# 🚜 Bulldoze 3.0 — Modern Wayland Glassmorphic Desktop Shell

[![Wayland](https://img.shields.io/badge/Wayland-Hyprland-0055FF.svg?logo=wayland&logoColor=white)](https://hyprland.org)
[![Quickshell](https://img.shields.io/badge/Framework-Quickshell-FF4081.svg)](https://outfoxxed.me/quickshell/)
[![Qt](https://img.shields.io/badge/Qt6-QML-41CD52.svg?logo=qt&logoColor=white)](https://www.qt.io/)
[![Arch Linux](https://img.shields.io/badge/OS-Arch_Linux-1793D1.svg?logo=archlinux&logoColor=white)](https://archlinux.org)
[![Refresh Rate](https://img.shields.io/badge/Optimized-240Hz-00E676.svg)](#)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

**Bulldoze 3.0** é um Desktop Shell completo, modular e de altíssimo desempenho desenvolvido para **Arch Linux** e **Hyprland**, construído sobre o framework [Quickshell](https://outfoxxed.me/quickshell/) e **QtQuick / QML**.

Projetado sob o conceito de **Glassmorphism Físico**, o Bulldoze apresenta superfícies de vidro translúcido que se acoplam geometricamente aos limites do monitor (*bezels*), com física de mola elástica (*sticky spring*) e animações calibradas para monitores de alta taxa de atualização (**240Hz**).

---

## 📑 Sumário

- [🌟 Principais Recursos](#-principais-recursos)
- [🎨 Design System & Estética](#-design-system--estética)
- [🕹️ Gaming Hub & Wrapper de Jogos](#️-gaming-hub--wrapper-de-jogos)
- [🌌 Wallpaper Engine Manager](#-wallpaper-engine-manager)
- [🔒 Lock Screen & Greeter (Login Manager)](#-lock-screen--greeter-login-manager)
- [📦 Requisitos do Sistema](#-requisitos-do-sistema)
- [🚀 Instalação e Configuração](#-instalação-e-configuração)
- [⌨️ Atalhos de Teclado (Hyprland)](#️-atalhos-de-teclado-hyprland)
- [🔌 Controle via IPC (Linha de Comando)](#-controle-via-ipc-linha-de-comando)
- [📂 Estrutura do Repositório](#-estrutura-do-repositório)
- [📄 Licença](#-licença)

---

## 🌟 Principais Recursos

| Componente | Arquivo Principal | Namespace Wayland | Descrição |
| :--- | :--- | :--- | :--- |
| **Top Notch Bar Unificada** | [`shell.qml`](shell.qml)<br>[`components/GlassPanel.qml`](components/GlassPanel.qml) | `bulldoze-bar` | Barra superior inteligente com expansão e views contextuais (Workspaces, Áudio, Wi-Fi, Bluetooth, Perfil, Energia, Notificações). |
| **Application Launcher** | [`components/Launcher.qml`](components/Launcher.qml) | `bulldoze-launcher` | Menu modal centralizado com busca instantânea, navegação completa por teclado e ícones dinâmicos do sistema. |
| **Central de Jogos & Settings** | [`components/GamingSettingsModal.qml`](components/GamingSettingsModal.qml)<br>[`modules/Gaming.qml`](modules/Gaming.qml) | `bulldoze-gaming-modal` | Painel completo com suporte a **Gamescope HDR / FSR**, resoluções, taxas até 240Hz e telemetria **MangoHud** (VRAM, RAM, GPU, CPU). |
| **Wallpaper Engine Manager** | [`components/WallpaperManagerModal.qml`](components/WallpaperManagerModal.qml)<br>[`scripts/bulldoze-wallpaper.py`](scripts/bulldoze-wallpaper.py) | `bulldoze-wallpaper-modal` | Gerenciador e explorador de papéis de parede do Steam Workshop com remoção de propagandas, ajuste de shaders e snapshot para Lock/Greeter. |
| **Central de Notificações** | [`components/NotificationCenter.qml`](components/NotificationCenter.qml)<br>[`components/SideGlassPanel.qml`](components/SideGlassPanel.qml) | `bulldoze-notifications` | Toasts dinâmicos na lateral direita, auto-dismiss inteligente e histórico integrado. |
| **On-Screen Display (OSD)** | [`components/Osd.qml`](components/Osd.qml)<br>[`components/views/AudioBarView.qml`](components/views/AudioBarView.qml) | Integrado / OSD | Feedback visual moderno e não intrusivo para controle de volume e mudo. |
| **Tela de Bloqueio** | [`components/LockScreen.qml`](components/LockScreen.qml) | `bulldoze-lock` | Autenticação PAM nativa, relógio flutuante e fundo sincronizado com efeito de desfoque. |
| **Greeter (Login Manager)** | [`greeter.qml`](greeter.qml)<br>[`components/Greeter.qml`](components/Greeter.qml) | `bulldoze-greeter` | Display manager nativo para `greetd` com seleção de sessões Wayland e sincronização de avatares. |

---

## 🎨 Design System & Estética

O Bulldoze 3.0 adota uma filosofia de design focada em precisão geométrica e elegância visual:

* **Geometria Côncava e Convexa**: Painéis acoplados às bordas utilizam transições côncavas suaves de **8px** que se fundem organicamente à moldura da tela, com cantos convexos arredondados de **12px** e bordas de destaque de `1px` (`#24FFFFFF`).
* **Física de Mola ("Sticky Spring")**: Movimentos suaves utilizando `Easing.OutBack` com coeficiente elástico de overshoot (`1.15`), criando a sensação física de atração magnética às bordas da tela.
* **Calibração 240Hz**: Tempos de resposta entre 120ms e 320ms, garantindo fluidez absoluta sem micro-travamentos (*stuttering*).
* **Localização em Português Brasileiro (pt-BR)**: Formatação completa de datas, horas, rótulos e avisos do sistema em português.

---

## 🕹️ Gaming Hub & Wrapper de Jogos

O Bulldoze inclui um subsistema dedicado para jogos sem risco de interferir no ambiente de trabalho:

* **Isolamento de Processos**: Os módulos de **Gamescope**, **MangoHud** e **GameMode** só são injetados em aplicações executadas explicitamente através do script wrapper [`scripts/bulldoze-game-run`](scripts/bulldoze-game-run).
* **Gamescope HDR & FSR**: Controle em tempo real de modos HDR (`--hdr-enabled`), conversão SDR->HDR (`--hdr-itm-enabled`), nits de luminância, resoluções internas/saída (1080p, 1440p, 4K) e taxas de atualização (240Hz, 165Hz, etc.).
* **MangoHud Telemetry**: Monitoramento granular de **Consumo de VRAM** (memória de vídeo), **Consumo de RAM**, uso de CPU/GPU, temperaturas, potências em Watts e frametimes.

### Como usar no Steam
Nas **Opções de Inicialização** (*Launch Options*) de qualquer jogo na Steam, basta adicionar:

```bash
~/.config/quickshell/bulldoze/scripts/bulldoze-game-run %command%
```

*(Também compatível com Heroic Games Launcher, Lutris e Bottles).*

---

## 🌌 Wallpaper Engine Manager

Gerenciador nativo de papéis de parede animados do Steam Workshop via `linux-wallpaperengine`:

* **Scan do Workshop**: Identifica automaticamente wallpapers instalados, prévias e arquivos `project.json` / `scene.pkg`.
* **Filtro Anti-Sponsor Inteligente**: Identifica e remove camadas indesejadas de doação, QR Codes (WeChat/Alipay/Afdian) e anúncios embutidos por autores.
* **Ajuste de Propriedades**: Personalização de esquemas de cores, velocidade, shaders e volume de áudio por papel de parede.
* **Sincronização de Snapshot**: Captura automaticamente frames limpos para utilização na tela de bloqueio ([`LockScreen.qml`](components/LockScreen.qml)) e no greeter de login.

---

## 🔒 Lock Screen & Greeter (Login Manager)

O projeto inclui tanto a tela de bloqueio da sessão ativa quanto o Greeter para inicialização do sistema via `greetd`:

* **Autenticação PAM Segura**: Validação de senha nativa sem componentes externos inseguros.
* **Sync de Perfil & Avatar**: O script [`scripts/sync-profile.py`](scripts/sync-profile.py) sincroniza o avatar do usuário através do perfil do Firefox, contas do sistema (`AccountsService`) ou imagem local (`~/.face`).
* **Instalador Automatizado**: Script de configuração para o `greetd` pronto para execução.

---

## 📦 Requisitos do Sistema

### Pacotes Principais
* **Arch Linux** (ou distribuição baseada)
* **Hyprland** (compositor Wayland)
* **Quickshell** (`quickshell-git`)
* **Qt 6** (`qt6-declarative`, `qt6-svg`, `qt6-5compat`)

### Áudio, Rede & Sistema
* **PipeWire** & **WirePlumber** (gerenciamento de áudio)
* **NetworkManager** (`nmcli`)
* **BlueZ** & **bluez-utils** (`bluetoothctl`)
* **Python 3** + **Pillow** (`python-pillow`)

### Jogos & Papel de Parede (Opcionais / Recomendados)
* `gamescope`
* `mangohud`
* `gamemode`
* `linux-wallpaperengine`
* `greetd` (para uso como gerenciador de login)

---

## 🚀 Instalação e Configuração

### 1. Clonar o Repositório
Clone os arquivos diretamente no diretório de configuração do Quickshell:

```bash
git clone https://github.com/SEU_USUARIO/bulldoze.git ~/.config/quickshell/bulldoze
```

### 2. Configurar Permissões de Execução
Torne os scripts auxiliares executáveis:

```bash
chmod +x ~/.config/quickshell/bulldoze/scripts/*
```

### 3. Integrar ao Hyprland (`hyprland.conf`)
Adicione a inicialização do Bulldoze e as regras de camada/blur ao seu arquivo de configuração do Hyprland:

```ini
# Inicialização do Bulldoze Shell
exec-once = quickshell -p ~/.config/quickshell/bulldoze

# Regras de Blur e Camadas para o Glassmorphism
layerrule = blur, bulldoze-bar
layerrule = ignorezero, bulldoze-bar
layerrule = blur, bulldoze-launcher
layerrule = ignorezero, bulldoze-launcher
layerrule = blur, bulldoze-gaming-modal
layerrule = ignorezero, bulldoze-gaming-modal
layerrule = blur, bulldoze-wallpaper-modal
layerrule = ignorezero, bulldoze-wallpaper-modal
layerrule = blur, bulldoze-notifications
layerrule = ignorezero, bulldoze-notifications
layerrule = blur, bulldoze-lock
```

### 4. (Opcional) Instalar o Greeter de Login para `greetd`
Para usar o Bulldoze como tela de login do sistema:

```bash
sudo ~/.config/quickshell/bulldoze/scripts/install-greeter.sh
```

---

## ⌨️ Atalhos de Teclado (Hyprland)

Adicione as seguintes associações de teclas ao seu `hyprland.conf`:

```ini
# Lançador de Aplicativos
bind = ALT, D, exec, quickshell ipc -c bulldoze call shell toggleLauncher

# Painéis & Modos da Top Notch Bar
bind = ALT, C, exec, quickshell ipc -c bulldoze call shell toggleControlCenter
bind = ALT, X, exec, quickshell ipc -c bulldoze call shell togglePowerMenu
bind = ALT, G, exec, quickshell ipc -c bulldoze call shell toggleGamingSettings
bind = ALT, W, exec, quickshell ipc -c bulldoze call shell toggleWallpaperManager

# Bloqueio de Sessão
bind = SUPER, L, exec, quickshell ipc -c bulldoze call shell lockScreen

# Controle de Volume & Mute (com feedback OSD)
binde = , XF86AudioRaiseVolume, exec, quickshell ipc -c bulldoze call shell raiseVolume
binde = , XF86AudioLowerVolume, exec, quickshell ipc -c bulldoze call shell lowerVolume
bind  = , XF86AudioMute, exec, quickshell ipc -c bulldoze call shell toggleMute
```

---

## 🔌 Controle via IPC (Linha de Comando)

Você pode controlar qualquer função do shell via terminal ou scripts externos:

```bash
# Alternar Lançador e Modais
quickshell ipc -c bulldoze call shell toggleLauncher
quickshell ipc -c bulldoze call shell toggleGamingSettings
quickshell ipc -c bulldoze call shell toggleWallpaperManager
quickshell ipc -c bulldoze call shell closeActiveMode

# Modos da Barra Superior
quickshell ipc -c bulldoze call shell toggleWifi
quickshell ipc -c bulldoze call shell toggleBluetooth
quickshell ipc -c bulldoze call shell toggleAudio
quickshell ipc -c bulldoze call shell toggleGaming
quickshell ipc -c bulldoze call shell toggleNotifications
quickshell ipc -c bulldoze call shell togglePowerMenu

# Controle de Áudio e Bloqueio
quickshell ipc -c bulldoze call shell raiseVolume
quickshell ipc -c bulldoze call shell lowerVolume
quickshell ipc -c bulldoze call shell toggleMute
quickshell ipc -c bulldoze call shell lockScreen
```

---

## 📂 Estrutura do Repositório

```text
~/.config/quickshell/bulldoze/
├── shell.qml                     # Orquestrador raiz da interface e barra notch
├── greeter.qml                   # Ponto de entrada do Greeter (Login greetd)
├── components/                   # Componentes de interface do usuário
│   ├── Theme.qml                 # Design tokens, cores, física e animações
│   ├── GlassPanel.qml            # Superfície de vidro superior com curvas côncavas
│   ├── SideGlassPanel.qml        # Superfície de vidro lateral (Notificações)
│   ├── BottomGlassPanel.qml      # Superfície de vidro inferior (Lock / Greeter)
│   ├── Launcher.qml              # Menu de aplicativos com busca rápida
│   ├── GamingSettingsModal.qml   # Modal avançado de Gamescope & MangoHud
│   ├── WallpaperManagerModal.qml # Modal do Wallpaper Engine do Steam Workshop
│   ├── NotificationCenter.qml    # Central e toasts de notificações
│   ├── LockScreen.qml            # Tela de bloqueio PAM nativa
│   ├── Greeter.qml               # Card de autenticação do login manager
│   ├── Clock.qml, Osd.qml, ...   # Relógio, OSD, Workspace pills e Logo
│   └── views/                    # Views contextuais da barra superior
│       ├── AudioBarView.qml
│       ├── BluetoothBarView.qml
│       ├── DefaultBarView.qml
│       ├── GamingBarView.qml
│       ├── NotificationBarView.qml
│       ├── PowerBarView.qml
│       ├── ProfileBarView.qml
│       ├── SearchBarView.qml
│       └── WifiBarView.qml
├── modules/                      # Módulos de integração com o sistema
│   ├── Audio.qml                 # Controle PipeWire / WirePlumber
│   ├── Network.qml               # Gerenciamento Wi-Fi via NetworkManager
│   ├── Bluetooth.qml             # Conexões via BlueZ
│   ├── Gaming.qml                # Estados de Gamescope e MangoHud
│   ├── UserProfile.qml           # Sincronização de perfil e avatar
│   ├── WallpaperEngine.qml       # Integração com Wallpaper Engine
│   ├── Notifications.qml         # Daemon Wayland de notificações
│   └── System.qml, Battery.qml   # Recursos e monitoramento do sistema
├── scripts/                      # Scripts e utilitários auxiliares
│   ├── bulldoze-game-run         # Wrapper de execução para jogos Steam/Lutris
│   ├── bulldoze-wallpaper.py     # Backend Python do Wallpaper Engine
│   ├── sync-profile.py           # Sincronizador de avatar e perfil
│   ├── greetd-client.py          # Cliente IPC JSON-RPC para o greetd
│   └── install-greeter.sh        # Script instalador do Greeter no sistema
├── examples/                     # Modelos e arquivos de configuração de exemplo
│   ├── hyprland.lua.example      # Configuração do Hyprland (Lua) com binds e layers
│   ├── kitty.conf.example        # Terminal Kitty translúcido (Bulldoze Theme)
│   └── firefox/
│       └── userChrome.css.example# Estilização Glassmorphic completa para o Firefox
├── design.md                     # Especificação técnica do Design System
├── agents.md                     # Diretrizes de arquitetura para agentes IA
├── gaming_guide.md               # Guia detalhado de calibração para jogos
├── CHANGELOG.md                  # Histórico de versões e evolução do projeto
├── LICENSE                       # Licença GNU General Public License v3.0
└── README.md                     # Documentação principal
```

---

## 📄 Licença

Distribuído sob a licença [GNU General Public License v3.0 (GPL-3.0)](LICENSE). Você tem a liberdade de executar, estudar, compartilhar e modificar este software livremente.
