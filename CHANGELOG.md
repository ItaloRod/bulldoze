# 📝 Registro de Alterações (Changelog)

Todas as mudanças notáveis no projeto **Bulldoze Desktop Shell** estão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/) e este projeto adere ao [Versionamento Semântico](https://semver.org/).

## [3.5.0] - 2026-09

### 🔔 Central de Notificações no Canto Inferior Direito & Fusão Vetorial
- **Integração Diagonal no Canto da Moldura (`shell.qml`, `NotificationBarView.qml`)**:
  - **Fusão Vetorial Direta (`unifiedShape`)**: As notificações foram completamente removidas do Notch superior e integradas como uma extrusão orgânica ancorada diretamente no canto inferior direito da tela.
  - **Transição Curva Diagonal Contínua**: A borda lateral direita transiciona suavemente em curva côncava para o topo da notificação, e o lado esquerdo desce em curva côncava para a borda inferior, preenchendo a quina sem frestas ou linhas indesejadas.
  - **Exibição Popup OSD (2,5s)**: Ao receber um alerta, exibe apenas a notificação mais recente em card compacto com fechamento automático em 2,5 segundos.
  - **Gatilho de Borda no Canto (Hot Zone)**: Passar o cursor sobre o canto inferior direito revela a notificação mais recente instantaneamente (ou *"Nenhuma notificação"* caso a fila esteja vazia). Ao sair da área, o painel fecha imediatamente.
  - **Expansão com Dwell de 2 Segundos**: Manter o cursor sobre o painel por 2 segundos expande verticalmente a visualização para cima, exibindo a pilha de notificações.
  - **Ordenação Bottom-to-Top & Scroll**: A notificação mais recente fica posicionada na base, com alertas anteriores empilhando-se para cima. Exibição de até 4 notificações simultâneas com rolagem via roda do mouse (*mouse wheel*) para notificações excedentes.
  - **Ações Individuais e Limpeza Geral**: Botão de fechar individual (``) em cada card e botão de lixeira (``) na base do painel expandido para descarte de todas as notificações.

### 🎯 Otimização do Notch Superior & Atalhos do Sistema
- **Notch em Linha Única com Altura Fixa (`DefaultBarView.qml`, `shell.qml`)**:
  - Reestruturação do layout da barra padrão do notch para uma única linha centralizada, com altura fixa de 32px tanto em repouso quanto em hover com o cursor.
  - Eliminação da segunda linha de controles rápidos (`QuickControls.qml`) e de expansões desnecessárias de hover.
- **Reposicionamento do Modo Jogo (`Status.qml`, `GamingBarView.qml`)**:
  - Botão de Gaming Mode (``) integrado diretamente ao grupo da direita (`Status.qml`), posicionado harmonicamente entre a System Tray e as Configurações (``).
  - Cálculo dinâmico de largura ideal (`idealWidth`) e centralização simétrica das pílulas no menu do Modo Jogo (`GamingBarView`), garantindo margens e paddings perfeitamente uniformes à esquerda e à direita.
- **Simplificação e Remoção de Modais Redundantes**:
  - Remoção dos botões e visualizações simplificadas de Wi-Fi e Bluetooth do Notch (`WifiBarView`, `BluetoothBarView`), concentrando todo o gerenciamento de rede nos Ajustes do Sistema.
  - Remoção do botão de sino de notificações do notch, mantendo a visualização e daemons preservados no código para a próxima iteração.
  - Limpeza dos comandos IPC correspondentes aos itens contidos nos Ajustes (`toggleWifi`, `toggleBluetooth`, `openWifiSettings`, etc.).
- **Atualização de Atalhos do Hyprland (`~/.config/hypr/hyprland.lua`)**:
  - Adicionado o atalho `Ctrl + Super + C` (`SUPER + CONTROL + C`) para abertura direta dos Ajustes do Sistema.
  - Removido o atalho `SUPER + W` (antigo atalho do gerenciador de wallpapers).

### 🔊 Reformulação da Interface de Áudio & Dispositivos
- **Nova Barra Lateral de Volume Simplificada Fundida à Borda (`AudioBarView.qml`, `shell.qml`)**:
  - **Fusão Vetorial Direta (`unifiedShape`)**: A barra de volume foi integrada diretamente à malha vetorial contínua da moldura perimetral esquerda de 8px, expandindo-se fluidamente para dentro da tela com curvas cúbicas suaves e borda de 1px sem costuras ou sobreposições flutuantes.
  - **Controle Minimalista Vertical**:
    - Topo: Ícone dinâmico de volume com alternância instantânea de mudo/desmudo ao clicar.
    - Centro: Slider vertical fino com suporte completo a clique e arrasto para controle de volume.
    - Base: Botão de engrenagem (``) para transição direta até a aba de Som nos Ajustes do Sistema.
  - **Temporizador Inteligente & OSD**:
    - Exibição automática por 2 segundos ao utilizar atalhos de volume do teclado (`raiseVolume`, `lowerVolume`, `toggleMute`).
    - Pausa automática do temporizador de fechamento quando o cursor do mouse estiver sobre a barra.
    - Ocultação automática em modo de tela cheia (`isFullscreenActive`) e quando a aba de Som dos Ajustes estiver ativa.
    - Suporte a acionamento manual via IPC (`quickshell ipc call shell toggleAudio`).

- **Interface Completa de Áudio nos Ajustes do Sistema (`SettingsBarView.qml`)**:
  - **Nova Categoria "Som" na Barra Lateral de Configurações**:
    - Slider horizontal de volume principal com porcentagem em tempo real e botão de mudo integrado.
    - Listagem dinâmica e reativa de todas as saídas de áudio disponíveis (Alto-falantes, HDMI, Fones Bluetooth, DACs USB).
    - Identificação visual de dispositivos através de ícones contextuais e badges de saída padrão.
    - Alternância instantânea de saída de som via PipeWire (`wpctl set-default <id>`).
    - Padronização visual em vidro translúcido monocromático (`theme.activeFill`, `theme.glassBorderStrong`), espelhando a identidade refinada da aba de Wi-Fi.

- **Simplificação dos Controles Rápidos do Notch (`QuickControls.qml`, `DefaultBarView.qml`)**:
  - Remoção do botão de áudio dos controles rápidos centrais do notch superior, mantendo o foco do notch em Wi-Fi, Bluetooth e Modo Jogo.

- **Helper Assíncrono de Áudio (`scripts/bulldoze-audio.py`, `modules/Audio.qml`)**:
  - Adicionado script utilitário para inspeção estruturada em JSON das saídas de som do PipeWire e troca de dispositivo padrão.

### ⚡ Performance & Otimizações do Sistema
- **Isolamento de Áudio do Wallpaper Engine (`scripts/bulldoze-wallpaper.py`)**:
  - Desacoplamento total do `linux-wallpaperengine` do subsistema PipeWire utilizando `SDL_AUDIODRIVER=dummy`, `ALSOFT_DRIVERS=dummy` e `--no-audio-processing`.
  - **Correção de Deadlock com Bluetooth & YouTube**: Evita que o congelamento do wallpaper via `SIGSTOP` (recurso de economia de GPU com janelas abertas) trave o grafo de renegociação do PipeWire (`[negotiating]`) ao conectar fones/caixas Bluetooth (ex: JBL Go) ou alterar dispositivos de som, eliminando congelamentos de vídeos no YouTube e navegadores.
- **Integração de Agendamento em Tempo Real (`ananicy-cpp` + `cachyos-ananicy-rules`)**:
  - Priorização automática e contínua de processos com baixa latência para o compositor Hyprland, Quickshell e jogos.
  - Rebaixamento automático de I/O e prioridade de CPU para processos em segundo plano (atualizadores, compiladores), eliminando micro-stutters.
- **Desduplicação de Memória RAM com KSM (`cachyos-ksm-settings` / `ksmd`)**:
  - Ativação do *Kernel Samepage Merging* (KSM) nativo via systemd, mesclando páginas idênticas de RAM entre processos de forma segura e sem consumo excessivo de CPU.
- **Guia Completo de Otimizações de Sistema (`docs/system_optimizations.md`)**:
  - Documentação detalhada sobre a arquitetura de agendamento de processos, KSM, comandos de instalação, ativação no systemd e monitoramento de economia de memória via `ksmstats`.

### 📂 Centralização & Arquitetura
- **Unificação de Scripts no Repositório (`scripts/`)**:
  - Centralizados e versionados os scripts de inicialização de sessão e wallpaper: `start-session`, `capture-greeter-wallpaper` e `bulldoze-wallpaper-daemon`.
  - Criados links simbólicos (*symlinks*) transparentes em `~/.config/bulldoze/scripts/` para total retrocompatibilidade com daemons e inicialização do Hyprland.
- **Separação Clara de Runtime vs Código**:
  - `~/.config/bulldoze/` mantido estritamente para dados de runtime e preferências mutáveis do usuário (`wallpaper.json`, `gaming.json`, `privacy.json`), desacoplando o código-fonte da configuração de estado.

### 🐛 Correções & Polimento
- **Suporte a Ícone do Bitwarden na System Tray (`components/Tray.qml`)**:
  - Tratamento e mapeamento dedicado para renderização correta do ícone do Bitwarden quando ativo na bandeja do sistema.

## [3.1.0] - 2026-08

### ✨ Adicionado
- **Spotlight Dock Inferior Invertido Fusionado à Moldura (`BottomLauncher.qml`, `shell.qml`)**:
  - **Fusão Vetorial Direta no `shell.qml`**: O Launcher deixou de ser uma janela isolada e foi fundido diretamente na malha vetorial contínua (`unifiedShape`) da borda inferior de 8px, utilizando o mesmo efeito de *frosted glass* de passagem única (`frameBlurContainer`) e borda contínua de 1px sem vazamento de papel de parede.
  - **Inversão de Hierarquia (Bottom-Up)**: Barra de pesquisa posicionada no rodapé da tela (`y = height - 8px`) com foco automático e badge `ESC`, com a lista de aplicativos e resultados expandindo-se fluidamente para cima.
  - **Tipografia e Escala Refinadas**: Altura de linha compactada para 38px, ícones de 22x22 e títulos em 13px (`theme.fontSizeMd`) para visual leve e sofisticado.

- **Layout do Notch Superior em 2 Níveis Equilibrado (`DefaultBarView.qml`, `QuickControls.qml`, `Status.qml`)**:
  - **Linha Principal Superior (Simetria Trilateral)**:
    - *Esquerda*: Menu Spotlight (`BulldozeLogo`) e alternador de workspaces (`WorkspacePills`).
    - *Centro*: Relógio e Data travados matematicamente no centro físico horizontal (`anchors.centerIn`).
    - *Direita*: System Tray, Notificações com badge e Mini Avatar do usuário com foto sincronizada.
  - **Linha Inferior Centralizada (`QuickControls.qml`)**: Controles rápidos de acesso imediato (Wi-Fi, Bluetooth, Som e Gaming Hub) posicionados diretamente abaixo do relógio.
  - **Dimensões & Margens Polidas**: Altura em repouso de `32px` e altura expandida de `64px`, com transições suaves e contêiner `mainRow` de 26px livre de conflitos de âncoras.

- **Moldura Perimetral de Vidro Transparente Integrada ao Notch (`shell.qml`, `LockScreen.qml`, `Greeter.qml`)**:
  - Moldura contínua de 8px ao redor de todo o perímetro do monitor (360°), alinhada com a escala de espaçamento definitiva do Hyprland (`gaps_in: 8`, `gaps_out: { top = 40, right = 24, bottom = 24, left = 24 }`).
  - **Fusão Estrutural e Vetorial Contínua**: A moldura perimetral e os notches superior e inferior foram fundidos em uma **única superfície Wayland (`PanelWindow`) e um único `ShapePath` contínuo**.
  - **Geometria de Curvas Cúbicas Tangenciais (`PathCubic`)**: Curvatura padronizada em `Theme.qml` com asas côncavas suaves (`notchConcaveWidth: 16px`, `notchConcaveHeight: 10px`) e cantos internos arredondados de 8px (`innerRadius: 8px`).
  - **Notch Fechado Compacto em 32px**: Altura do notch em repouso reduzida para `32px` (`notchHeight: 32px`).
  - **Harmonização Total com Lock Screen e Greeter**: Implementada a mesma moldura de vidro perimetral de 8px e caimento do notch no `LockScreen.qml` e no `Greeter.qml` (`greetd`).
  - **Transparência Total ao Mouse com Máscara Dinâmica**: Configurado com `mask: Region` dinâmico para liberar cliques para o desktop e interceptar durante foco no launcher ou submenus.
  - **Ocultação Automática em Tela Cheia (*Fullscreen Auto-Hide*)**: Monitoramento reativo via daemon assíncrono (`scripts/bulldoze-hypr-events.py`) conectado ao socket do Hyprland.

- **Bulldoze Wallpaper Handler Integrado ao Notch (`WallpaperBarView.qml`)**:
  - Centralização completa do Gerenciador de Wallpapers no Notch superior, eliminando modais flutuantes centralizados avulsos.
  - **Expansão Dinâmica da Barra**: Ao ativar o menu (`ALT + W`, comando IPC ou botão no perfil), o Notch expande fluidamente para `920 × 620 px` sobrepondo o desktop sem empurrar as janelas abertas (`exclusiveZone: 36`).
  - **Interface Completa em Duas Colunas**:
    - Galeria em grade (`GridView`) com busca em tempo real, badges de status (*Ativo, Vídeo, Cena*) e seleção visual.
    - Inspetor de propriedades com pré-visualização, controles de enquadramento (16:9/Fit/Stretch), FPS (60/120/240), áudio, interatividade de mouse e sliders/toggles dinâmicos de shaders do Workshop.
  - **Acesso Rápido no Menu de Perfil**: Adicionado botão de atalho `` no menu de sessão e perfil (`PowerBarView.qml`).

- **Painel de Configurações de Jogos Integrado ao Notch (`GamingSettingsBarView.qml`)**:
  - Migração completa do painel avançado de configurações de jogos para dentro do Notch, eliminando o modal flutuante centralizado.
  - **Expansão Fluida**: O Notch se expande para `720 × 580 px` ao clicar no botão de engrenagem (``) ou ao executar `quickshell ipc -c bulldoze call shell toggleGamingSettings`.
  - **Navegação em 3 Abas Responsivas**:
    - **Bulldoptimizer**: Controles de Wallpaper Estático (Zero-GPU), Efeitos do Hyprland e NVIDIA PowerMizer.
    - **Gamescope**: Ajustes de HDR Nativo, Mapeamento Inverso HDR ITM, Nits, Resoluções (1080p/1440p/4K), Taxas de atualização (60-240Hz), FSR Sharpness e Integer Scaling.
    - **MangoHud**: Presets de HUD (*Completo*, *Essencial*, *Mínimo*), telemetria detalhada de CPU/GPU, VRAM, RAM, frametime, potência em Watts e seletor visual de posicionamento na tela.


- **Módulo e Toggle Rápido Bulldoptimizer (``)**:
  - Novo recurso de otimização de jogos modular e desacoplado do GameMode, permitindo economia de GPU e redução de latência com controle individual.
  - **Wallpaper Estático Zero-GPU**: Pausa o motor dinâmico `linux-wallpaperengine` e exibe imagem estática (`Wallpaper_greeter.png`) na camada de fundo Wayland (`WlrLayer.Background`), liberando VRAM e ciclos de GPU para o jogo.
  - **Otimizações Dinâmicas do Hyprland**: Desativação de blur, sombras e animações do compositor com Direct Scanout (`render:direct_scanout 1`) enquanto o Bulldoptimizer estiver ativo.
  - **NVIDIA PowerMizer Performance**: Alternância opcional para travar a GPU em desempenho máximo (`GpuPowerMizerMode=1`), com detecção segura e compatível com futuras trocas para AMD/Intel.
  - **Interface & Controles**: Novo botão de alternância rápida no Notch Bar (`GamingBarView.qml`), grid 2x2 na Central de Controle (`ControlCenter.qml`) e aba de ajustes no modal flutuante (`GamingSettingsModal.qml`).
- **Pausa Automática do Wallpaper Engine por Workspace (`bulldoze-hypr-events.py`, `bulldoze-wallpaper.py`, `WallpaperEngine.qml`, `WallpaperBarView.qml`)**:
  - **Economia Inteligente de GPU & Compositor**: O daemon monitora em tempo real a quantidade de janelas abertas no workspace ativo via socket do Hyprland. Ao detectar qualquer janela aberta (`windows > 0`), envia sinal `SIGSTOP` para o `linux-wallpaperengine`, congelando no último frame renderizado e zerando o consumo da GPU e de recomposição de blur do Hyprland.
  - **Retomada Instantânea**: Ao alternar para um workspace vazio (`windows == 0`), envia sinal `SIGCONT` imediatamente, retomando a animação com fluidez sem nenhum delay.
  - **Controle por UI & Persistência**: Adicionada a opção `"pause_on_window": true` por padrão no `wallpaper.json` e novo toggle *"Pausar com Janelas no Workspace"* na seção de Desempenho do Gerenciador de Wallpapers.

- **Captura de Foco e Fechamento Confiável no Bottom Launcher (`BottomLauncher.qml`, `shell.qml`)**:
  - Conversão do componente base para `FocusScope` com timers de foco imediato e em fallback.
  - Integração do `HyprlandFocusGrab` no shell para fechar o launcher com segurança ao clicar fora.

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
