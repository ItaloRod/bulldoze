# 🚜 Bulldoze 3.0 — Glassmorphic Desktop Shell for Linux

[![Wayland](https://img.shields.io/badge/Wayland-Hyprland-0055FF.svg?logo=wayland&logoColor=white)](https://hyprland.org)
[![Quickshell](https://img.shields.io/badge/Framework-Quickshell-FF4081.svg)](https://quickshell.org/)
[![Qt](https://img.shields.io/badge/Qt6-QML-41CD52.svg?logo=qt&logoColor=white)](https://www.qt.io/)
[![Arch Linux](https://img.shields.io/badge/OS-Arch_Linux-1793D1.svg?logo=archlinux&logoColor=white)](https://archlinux.org)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

**Bulldoze 3.0** é um projeto de desktop shell para Linux, desenvolvido com **QtQuick / QML** e integrado ao ecossistema **Wayland**. O projeto é pensado principalmente para **Arch Linux** e **Hyprland**, com foco em uma interface moderna, modular e altamente personalizável.

O Bulldoze busca oferecer uma experiência visual baseada em superfícies translúcidas, animações suaves e integração com ferramentas do sistema, mantendo as dependências externas separadas do código do projeto.

> **Nota sobre o escopo:** nomes de projetos, softwares, serviços, lojas e tecnologias de terceiros mencionados neste README são referências a dependências, integrações ou formatos compatíveis. O projeto Bulldoze não é afiliado, patrocinado ou endossado por esses projetos, salvo indicação expressa em seus respectivos canais oficiais.

---

## 📑 Sumário

- [🌟 Recursos](#-recursos)
- [🎨 Design e Interface](#-design-e-interface)
- [🕹️ Integração com Jogos](#️-integração-com-jogos)
- [🌌 Wallpapers](#-wallpapers)
- [🔒 Lock Screen e Greeter](#-lock-screen-e-greeter)
- [📦 Requisitos](#-requisitos)
- [🚀 Instalação](#-instalação)
- [⌨️ Atalhos](#️-atalhos)
- [🔌 IPC](#-ipc)
- [📂 Estrutura](#-estrutura)
- [⚖️ Licença e Terceiros](#️-licença-e-terceiros)
- [⚠️ Avisos](#️-avisos)

---

## 🌟 Recursos

| Componente | Arquivo / Área | Descrição |
| :--- | :--- | :--- |
| **Top Bar** | `shell.qml`, `components/` | Barra superior com informações e controles do sistema. |
| **Launcher** | `components/Launcher.qml` | Lançador de aplicativos com busca e navegação por teclado. |
| **Gaming Hub** | `components/GamingSettingsModal.qml`, `modules/Gaming.qml` | Interface para configurar recursos relacionados a jogos e ferramentas externas. |
| **Wallpaper Manager** | `components/WallpaperManagerModal.qml` | Interface para gerenciamento de wallpapers compatíveis com ferramentas externas. |
| **Notificações** | `components/NotificationCenter.qml` | Exibição e histórico de notificações. |
| **OSD** | `components/Osd.qml` | Feedback visual para ações como volume e mute. |
| **Lock Screen** | `components/LockScreen.qml` | Tela de bloqueio da sessão. |
| **Greeter** | `greeter.qml`, `components/Greeter.qml` | Interface de login destinada à integração com `greetd`. |

---

## 🎨 Design e Interface

O projeto segue uma direção visual inspirada em **glassmorphism**, com foco em:

- superfícies translúcidas;
- cantos e transições arredondadas;
- animações suaves;
- adaptação a diferentes resoluções e taxas de atualização;
- localização em português brasileiro (`pt-BR`).

Os valores de dimensões, animações, cores e outros tokens visuais podem ser encontrados no sistema de design do projeto.

---

## 🕹️ Integração com Jogos

O Bulldoze pode integrar ferramentas externas para execução e monitoramento de jogos, como:

- **Gamescope**;
- **MangoHud**;
- **GameMode**.

Essas ferramentas são programas independentes e devem ser instaladas separadamente quando necessárias.

### Steam Launch Options

Um exemplo de uso do wrapper fornecido pelo projeto:

```bash
~/.config/quickshell/bulldoze/scripts/bulldoze-game-run %command%
```

A compatibilidade real depende do jogo, da configuração do sistema e das ferramentas externas instaladas.

---

## 🌌 Wallpapers

O Bulldoze pode oferecer uma interface para gerenciamento de wallpapers utilizando ferramentas e formatos compatíveis disponíveis no Linux.

Dependendo da implementação utilizada, podem ser necessários softwares de terceiros, arquivos fornecidos pelos próprios usuários e conteúdo distribuído por plataformas externas.

O Bulldoze **não redistribui automaticamente conteúdo de terceiros** apenas por disponibilizar uma interface para encontrá-lo ou utilizá-lo.

---

## 🔒 Lock Screen e Greeter

O projeto pode incluir componentes destinados a:

- bloqueio da sessão gráfica;
- autenticação através de mecanismos do sistema;
- integração com `greetd`;
- exibição de informações do usuário e da sessão.

A configuração de autenticação e login deve ser tratada com cuidado, especialmente ao utilizar scripts que alterem arquivos de configuração do sistema ou executem comandos com privilégios administrativos.

O código do projeto não deve ser interpretado como uma auditoria de segurança. Revise a configuração antes de utilizá-la em uma máquina de produção.

---

## 📦 Requisitos

### Base

- Linux
- Wayland
- Qt 6 / QtQuick
- Quickshell

### Ambiente recomendado

- Arch Linux ou distribuição compatível
- Hyprland

### Integrações opcionais

- PipeWire / WirePlumber
- NetworkManager
- BlueZ / `bluez-utils`
- Python 3
- `gamescope`
- `mangohud`
- `gamemode`
- `linux-wallpaperengine`
- `greetd`

As ferramentas acima são projetos independentes, sujeitos às suas próprias licenças e condições de uso.

---

## 🚀 Instalação

### 1. Clonar o repositório

```bash
git clone https://github.com/ItaloRod/bulldoze.git ~/.config/quickshell/bulldoze
```

### 2. Configurar permissões

```bash
chmod +x ~/.config/quickshell/bulldoze/scripts/*
```

### 3. Iniciar o shell

Adicione ao seu `hyprland.conf` um comando de inicialização compatível com a sua versão do Quickshell. Por exemplo:

```ini
exec-once = quickshell -p ~/.config/quickshell/bulldoze
```

### 4. Integração com o sistema

Alguns recursos dependem de configuração adicional do Hyprland, do sistema de áudio, da rede, do Bluetooth ou de outras ferramentas externas.

Consulte a documentação específica de cada componente antes de habilitá-lo.

---

## ⌨️ Atalhos

Exemplo de associações para o Hyprland:

```ini
# Launcher
bind = ALT, D, exec, quickshell ipc -c bulldoze call shell toggleLauncher

# Modais
bind = ALT, C, exec, quickshell ipc -c bulldoze call shell toggleControlCenter
bind = ALT, X, exec, quickshell ipc -c bulldoze call shell togglePowerMenu
bind = ALT, G, exec, quickshell ipc -c bulldoze call shell toggleGamingSettings
bind = ALT, W, exec, quickshell ipc -c bulldoze call shell toggleWallpaperManager

# Lock
bind = SUPER, L, exec, quickshell ipc -c bulldoze call shell lockScreen

# Volume
binde = , XF86AudioRaiseVolume, exec, quickshell ipc -c bulldoze call shell raiseVolume
binde = , XF86AudioLowerVolume, exec, quickshell ipc -c bulldoze call shell lowerVolume
bind = , XF86AudioMute, exec, quickshell ipc -c bulldoze call shell toggleMute
```

Os nomes e parâmetros de comandos podem variar conforme a versão do Quickshell e do Hyprland utilizada.

---

## 🔌 IPC

Quando habilitado pelos componentes correspondentes, algumas funções podem ser acionadas através do IPC do Quickshell:

```bash
quickshell ipc -c bulldoze call shell toggleLauncher
quickshell ipc -c bulldoze call shell toggleGamingSettings
quickshell ipc -c bulldoze call shell toggleWallpaperManager
quickshell ipc -c bulldoze call shell closeActiveMode
quickshell ipc -c bulldoze call shell toggleWifi
quickshell ipc -c bulldoze call shell toggleBluetooth
quickshell ipc -c bulldoze call shell toggleAudio
quickshell ipc -c bulldoze call shell toggleNotifications
quickshell ipc -c bulldoze call shell togglePowerMenu
quickshell ipc -c bulldoze call shell raiseVolume
quickshell ipc -c bulldoze call shell lowerVolume
quickshell ipc -c bulldoze call shell toggleMute
quickshell ipc -c bulldoze call shell lockScreen
```

Esses comandos são exemplos da interface disponibilizada pelo projeto e podem mudar entre versões.

---

## 📂 Estrutura

```text
~/.config/quickshell/bulldoze/
├── shell.qml
├── greeter.qml
├── components/
│   ├── Theme.qml
│   ├── GlassPanel.qml
│   ├── SideGlassPanel.qml
│   ├── BottomGlassPanel.qml
│   ├── Launcher.qml
│   ├── GamingSettingsModal.qml
│   ├── WallpaperManagerModal.qml
│   ├── NotificationCenter.qml
│   ├── LockScreen.qml
│   ├── Greeter.qml
│   └── views/
├── modules/
│   ├── Audio.qml
│   ├── Network.qml
│   ├── Bluetooth.qml
│   ├── Gaming.qml
│   ├── UserProfile.qml
│   ├── WallpaperEngine.qml
│   ├── Notifications.qml
│   └── System.qml
├── scripts/
├── examples/
├── design.md
├── agents.md
├── gaming_guide.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

A estrutura pode mudar conforme o projeto evolui.

---

## ⚖️ Licença e Terceiros

Os arquivos originais do **Bulldoze** são distribuídos sob a **GNU General Public License v3.0**, conforme indicado no arquivo [`LICENSE`](LICENSE).

A licença GPL-3.0 se aplica aos arquivos que fazem parte deste projeto e que são efetivamente licenciados sob essa licença. **Dependências, bibliotecas, ferramentas, fontes, ícones, imagens, wallpapers e outros materiais de terceiros não passam automaticamente a ser licenciados pela GPL-3.0 do Bulldoze.**

Cada componente de terceiros continua sujeito à sua própria licença e aos respectivos avisos de copyright.

Quando este repositório incorporar código ou recursos de terceiros, a intenção é manter os respectivos avisos e informações de licença junto do material correspondente.

### Marcas e nomes de produtos

Nomes como **Linux**, **Arch Linux**, **Hyprland**, **Quickshell**, **Qt**, **Steam**, **Wallpaper Engine**, **Gamescope**, **MangoHud**, **GameMode**, **Firefox**, **greetd** e outros nomes mencionados neste projeto pertencem aos seus respectivos titulares.

A menção a essas tecnologias indica compatibilidade, dependência ou integração técnica e não implica endosso ou afiliação, salvo quando expressamente indicado.

---

## ⚠️ Avisos

- Este projeto é fornecido **como está**, sem garantia de funcionamento em todas as combinações de hardware, distribuição, compositor ou versões de dependências.
- Recursos que executam comandos do sistema, modificam configurações ou utilizam privilégios administrativos devem ser revisados antes de serem executados.
- Conteúdo obtido de plataformas externas, incluindo wallpapers, jogos e outros arquivos, permanece sujeito aos termos e licenças aplicáveis à respectiva plataforma e ao respectivo conteúdo.
- O usuário é responsável por verificar se a utilização e a redistribuição de qualquer conteúdo de terceiros são permitidas em sua região e no contexto de uso escolhido.

---

## 🤝 Contribuição

Contribuições são bem-vindas. Ao enviar código, imagens, documentação ou outros materiais para o projeto, certifique-se de que você possui os direitos necessários para contribuir com esse material e que sua contribuição pode ser distribuída de acordo com os termos aplicáveis ao projeto.

---

## 📄 Licença

Distribuído sob a **GNU General Public License v3.0**. Consulte o arquivo [`LICENSE`](LICENSE) para o texto completo da licença.
