# 📝 Registro de Alterações (Changelog)

Todas as mudanças notáveis no projeto **Bulldoze Desktop Shell** estão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/) e este projeto adere ao [Versionamento Semântico](https://semver.org/).

## [3.1.0] - 2026-08

### 🐛 Corrigido
- **Persistência das Configurações de Jogos e Perfil**:
  - Corrigida a leitura assíncrona de arquivos de configuração JSON multilinhas (`modules/Gaming.qml` e `modules/UserProfile.qml`), concatenando o fluxo de dados (`cat | tr '\n' ' '`) para evitar que o `SplitParser` dividisse o payload por linha e causasse falha no `JSON.parse`.
  - Restaurada a persistência e exibição imediata dos estados ativos de **GameMode**, **MangoHud** e **Gamescope** no Notch Bar, na Central de Jogos e na Central de Controle após reinicialização do shell.

---

## [3.0.0] - 2026-08

### 🚀 Reescrevendo o Desktop Shell em Quickshell & QML
A versão 3.0 marca uma reescrita arquitetural completa do ecossistema Bulldoze, abandonando componentes legados dispersos em favor de um Desktop Shell Wayland 100% unificado, reativo e modular construído sobre o framework [Quickshell](https://outfoxxed.me/quickshell/) e QtQuick/QML.

### ✨ Adicionado
- **Top Notch Bar Unificada (*Morphing Bar*)**: Barra superior em cápsula translúcida com expansão fluida e *views* modais contextuais intercambiáveis:
  - `DefaultBarView`: Visualização padrão com relógio central e indicadores rápidos.
  - `AudioBarView`: Controle visual de volume e saídas PipeWire.
  - `WifiBarView`: Varredura e conexão a redes Wi-Fi via NetworkManager.
  - `BluetoothBarView`: Gerenciamento de pareamento e conexões via BlueZ.
  - `GamingBarView` & `GamingSettingsModal`: Central de jogos com controle de Gamescope HDR/FSR e telemetria MangoHud (VRAM, RAM, GPU, CPU).
  - `NotificationBarView` & `NotificationCenter`: Central de notificações e toasts com auto-dismiss inteligente.
  - `PowerBarView`: Menu de controle de sessão e energia.
  - `ProfileBarView`: Cartão de perfil com sincronização automática de avatar (Firefox / AccountsService).
  - `SearchBarView` & `Launcher`: Menu de aplicativos com busca instantânea e navegação total por teclado.
- **Glassmorphism Físico**:
  - Arcos côncavos de 8px fundidos geometricamente às bordas (*bezels*) do monitor e cantos convexos de 12px com bordas de realce de 1px (`#24FFFFFF`).
  - Física de mola elástica (*Sticky Spring*) calibrada para monitores de **240Hz** (`Easing.OutBack` com overshoot de 1.15).
- **Wallpaper Engine Manager Integrado**:
  - Leitor nativo do Steam Workshop e parser de `project.json` / `scene.pkg`.
  - Filtro inteligente anti-propaganda (*Anti-Sponsor*), removendo QR Codes (WeChat/Alipay/Afdian) e anúncios embutidos por autores.
  - Captura automática de snapshots limpos sincronizados com a tela de bloqueio e greeter.
- **Greeter Nativo (`greetd`) & Lock Screen**:
  - Display Manager nativo do sistema com PAM e suporte a múltiplas sessões Wayland.
  - Script automatizado de instalação do greeter (`scripts/install-greeter.sh`).
- **Gaming Process Isolation**:
  - Wrapper `scripts/bulldoze-game-run` para isolar GameMode, MangoHud e Gamescope apenas nos jogos (Steam, Heroic, Lutris), protegendo o shell e navegadores contra injeções.
- **Controle Total via IPC**:
  - Handlers de IPC expostos para controle programático completo (`quickshell ipc -c bulldoze call shell <action>`).
- **Exemplos de Configuração**:
  - Adicionados modelos de configuração para Hyprland (Lua), Kitty Terminal e estilos Glassmorphism para Firefox (`userChrome.css`).

### 🔄 Modificado
- Centralização de tokens visuais em [`Theme.qml`](components/Theme.qml), permitindo ajustes rápidos de cores, fontes, raios e durações.
- 100% dos textos, rótulos de interface e formatação de datas localizados em Português Brasileiro (`pt_BR`).

### 🗑️ Removido / Descontinuado
- Dependência de daemons e utilitários externos avulsos (Waybar, Rofi, SwayNC, Dunst, wlogout, Swaylock).

---

## [2.0.0] - 2025-11

### 🏗️ Transição para Wayland & Hyprland Modular
A versão 2.0 introduziu a migração do ecossistema Bulldoze do X11/KDE para o compositor Wayland **Hyprland**, utilizando um conjunto de ferramentas e daemons modulares do ecossistema Linux.

### ✨ Adicionado
- Integração inicial com o compositor Hyprland e regras de janelas dinâmicas.
- Barra de status baseada em **Waybar** com módulos customizados em CSS.
- Lançador de aplicativos e menu de pesquisa com **Rofi / Wofi**.
- Central e daemon de notificações com **SwayNC / Mako**.
- Menu de energia modal utilizando **wlogout**.
- Tela de bloqueio e idle management via **Swaylock-effects** e **Hypridle**.
- Primeiros scripts auxiliares em Bash e Python para atalhos de volume, brilho e controle de áudio PipeWire.

### ⚠️ Limitações Identificadas
- Componentes visuais independentes com estilos CSS fragmentados e difícil sincronização de estados em tempo real.
- Falta de animações coordenadas e transições fluidas entre painéis e janelas.
- Alto acoplamento a múltiplos daemons e processos em segundo plano.

---

## [1.0.0] - 2025-03

### 🎨 Fundação do Bulldoze Desktop (KDE Plasma)
A versão inaugural do projeto focou na criação da identidade visual e do fluxo de trabalho do Bulldoze sobre o ambiente de desktop **KDE Plasma (KDE 5/6)** no Arch Linux.

### ✨ Adicionado
- Definição da paleta de cores inicial escura com detalhes translúcidos e acentos suaves.
- Temas Plasma personalizados (Look-and-Feel, Kvantum, Window Decorations e Aurorae).
- Layout de painéis customizado com widgets do KDE (Application Launcher, System Tray, Digital Clock).
- Regras de janela no KWin para transparência, blur e posicionamento automático.
- Scripts de automação para backup e sincronização de dotfiles em `~/.config`.
- Integração com atalhos globais de teclado do KDE para produtividade e multitarefa.
