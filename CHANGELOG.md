# 📝 Registro de Alterações (Changelog)

Todas as mudanças notáveis no projeto **Bulldoze Desktop Shell** estão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/) e este projeto adere ao [Versionamento Semântico](https://semver.org/).

## [3.5.1] - 2026-09

### 🥾 Bulldoze GRUB 3.0: Tema QHD Estilo Spotlight, Baker de Wallpaper e Pré-visualização
- **Tema GRUB 3.0 Nativo QHD (2560×1440) (`grub/`, `install-grub-theme.sh`, `preview-grub.sh`)**:
  - Tema completo para o bootloader GRUB em resolução nativa 2560×1440 com estética de vidro fosco (*frosted glassmorphism*), alinhado à identidade visual do Bulldoze 3.0.
  - Card lateral translúcido sem bordas duras, tipografia Roboto Mono monocromática e ícones de sistemas operacionais.
  - Script de instalação (`install-grub-theme.sh`) com sincronização dinâmica em `/boot/grub/themes/bulldoze` via helper com permissão sem senha (`sudoers.d/bulldoze-grub`).
  - Script de pré-visualização em máquina virtual QEMU (`preview-grub.sh`) com notificações e exibição contínua do cursor liberável via `Ctrl+Alt+G`.
- **Destaque do Item Selecionado Estilo Spotlight (`theme.txt`, `select_*.png`, `bulldoze-grub-wallpaper.py`)**:
  - Implementado sistema 9-slice pixmap (`select_*.png`) para o item ativo no menu de boot, espelhando a experiência visual do Spotlight (`BottomLauncher.qml`).
  - Pílula translúcida com preenchimento em vidro fosco esbranquiçado iluminado e borda sutil de 1px (`glassBorderStrong`).
  - Calibração de geometria (`item_height = 32`, `item_spacing = 20`, cantos de 8px) eliminando sobreposições e garantindo espaçamento limpo entre entradas de boot.
- **Baker Inteligente de Wallpaper do GRUB (`bulldoze-grub-wallpaper.py`, `bulldoze-wallpaper.py`, `GrubSettingsBarView.qml`, `LauncherBarView.qml`)**:
  - Renderização e composição de card com desfoque Gaussiano nativo diretamente no wallpaper do GRUB (`background.png`).
  - Captura nativa em 2560×1440 de cenas do Wallpaper Engine via `linux-wallpaperengine` (`snapshot-hires`), eliminando artefatos de zoom pixelado gerados por miniaturas `preview.jpg`.
  - Recorte proporcional com *aspect-fill* centralizado para evitar qualquer distorção de proporção em imagens fora do padrão 16:9.
  - Nova aba "GRUB Bootloader" no Launcher Central (`LauncherBarView.qml`) e painel dedicado (`GrubSettingsBarView.qml`) para gerenciar e pré-visualizar o tema em tempo real.

### 🎮 Gamescope: Presets de Jogos & Trava de Cursor na Janela
- **Trava de Cursor no Gamescope (`--force-grab-cursor`) (`modules/Gaming.qml`, `scripts/bulldoze-game-run`, `components/ControlCenter.qml`)**:
  - Implementada a opção `gsForceGrabCursor` ("Travar Cursor na Janela") para solucionar perda de foco e cliques desalinhados em jogos da engine Unity (ex: *Cities: Skylines II*).
  - Injeção automática da flag `--force-grab-cursor` no executável `bulldoze-game-run` e toggle direto no Control Center e nas configurações de jogos.
- **Gerenciador de Presets do Gamescope (`modules/Gaming.qml`, `GamingSettingsBarView.qml`)**:
  - Sistema reativo de perfis de performance e resolução por jogo (`gamescopePresets`), persistido em `~/.config/bulldoze/gaming.json`.
  - Perfis padrão integrados de fábrica:
    - *Padrão do Sistema*: 1440p nativo / 1080p render / 240Hz com FSR.
    - *Cities II - Mouse Corrigido & Nativo*: 1080p nativo / 144Hz / Trava de cursor ativa / FSR desligado.
    - *Cities II - Performance 720p FSR*: 1080p nativo / 720p render / 144Hz / Trava de cursor ativa / FSR nível 5.
  - Editor visual completo nos Ajustes de Jogos para criar, alternar, editar e excluir presets customizados de resolução, taxa de quadros e FSR.

### 🖥️ Seletor Dinâmico de Saída de Vídeo / Porta de Imagem no Gerenciador de Wallpapers
- **Detecção Inteligente e Seletor Dropdown no Painel de Wallpapers (`WallpaperBarView.qml`, `WallpaperEngine.qml`, `bulldoze-wallpaper.py`, `agents.md`)**:
  - Implementado dropdown estilizado em vidro translúcido (`glassFillDark` / `glassBorderStrong`) para seleção explícita da saída de vídeo (DisplayPort, HDMI, etc.) onde o wallpaper deve ser renderizado.
  - Varredura em tempo real via Hyprland IPC (`hyprctl monitors -j`) e detecção de conectores físicos DRM (`/sys/class/drm/card*-*`), exibindo resolução, taxa de atualização e status de conectividade (Conectado / Desconectado).
  - Suporte a modo Automático (segue o monitor ativo/focado) e fallback gracioso caso o cabo de vídeo seja trocado (ex: HDMI para DisplayPort `DP-1`) sem que o wallpaper deixe de renderizar.
  - Persistência reativa da porta selecionada em `~/.config/bulldoze/wallpaper.json` e aplicação instantânea no daemon do `linux-wallpaperengine`.

### 🎨 Refinamentos na Visualização de Notificações e Geometria do Shell
- **Ajustes de Proporção e Escala (`NotificationBarView.qml`, `shell.qml`)**:
  - Largura da central de notificações ampliada para 400px e altura por item ajustada para 66px, aprimorando legibilidade e área de clique.
  - Renderização nativa de fontes e ícones contextuais aprimorados no card individual de notificação.

## [3.5.0] - 2026-09

### 🔤 Correção de Nitidez e Renderização Nativa de Fontes e Ícones
- **Adoção Global de `NativeRendering` em Todo o Shell (`Text` e `TextInput`)**:
  - Implementado `renderType: Text.NativeRendering` e `renderType: TextInput.NativeRendering` em 100% dos componentes de interface (343 elementos em 21 arquivos).
  - Elimina aberração cromática, franjas coloridas (azul/laranja) e borrão visual em textos e ícones de fontes (Nerd Fonts / FontAwesome) renderizados sobre superfícies Wayland com transparência e vidro translúcido.
  - Nitidez consistente em toda a experiência: relógio, Spotlight (`BottomLauncher.qml`), Notificações (`NotificationBarView.qml`), Launcher Central (`LauncherBarView.qml`), Central de Controle (`ControlCenter.qml`), LockScreen e Greeter.

### 🚀 Redesign do Launcher Central e Expansão de Hotspot (`LauncherBarView.qml`, `shell.qml`)
- **Ampliação do Hotspot de Acionamento Superior**:
  - A área de gatilho do hover no topo da tela foi expandida para 920px de largura (idêntica à largura total do launcher), centralizada no topo e registrada na máscara de entrada do Wayland (`mask: Region`). O acionamento via mouse agora ocorre de forma imediata e ergonômica em toda a extensão do launcher.
- **Transição de "Ajustes" para Launcher Central (`LauncherBarView.qml`)**:
  - O arquivo foi renomeado de `SettingsBarView.qml` para `LauncherBarView.qml`.
  - O termo "Ajustes do Sistema" e o botão de fechar ("X") foram completamente eliminados da view.
  - O fechamento da view ocorre exclusivamente por hover-out ou pelo atalho global `SUPER + H`.
- **Barra de Categorias Horizontal no Topo**:
  - A antiga barra lateral vertical de 48px foi substituída por uma linha horizontal centralizada no topo, contendo as 6 categorias (Início, Wi-Fi, Bluetooth, Som, Wallpaper e Jogos) de forma fixa e independente da rolagem.
  - Toda a área de conteúdo abaixo passa a usufruir de 100% da largura útil da janela.
- **Banner de Boas-Vindas com 180px e Ajuste Fino de Corte**:
  - Altura do banner aumentada de 136px para 180px.
  - Cantos superiores arredondados com `theme.radiusItem` acompanhando organicamente o contorno do card de boas-vindas, mascarados via `MultiEffect` para prevenir qualquer vazamento visual do blur.
  - Enquadramento inicial alterado para exibir o topo da imagem (0%).
  - Novo botão de canetinha (`""`) no canto superior esquerdo do banner com popover e slider vertical para ajuste fino do enquadramento (0% a 100%), salvo automaticamente em `~/.config/bulldoze/banner_crop.json`.
  - Recarregamento reativo instantâneo do banner (`Wallpaper_greeter.png`) sempre que o wallpaper do sistema for alterado.
- **Blocos em 100% da Largura (Data/Hora e Central de Jogos)**:
  - Substituída a antiga divisão 60%/40% por blocos empilhados ocupando 100% da largura.
  - **Data, Hora e Calendário**: Relógio digital ampliado para 48px com badge destacando o dia da semana por extenso, data completa e calendário mensal em largura total.
  - **Central de Jogos & Performance**: Atalhos para GameMode, Bulldoptimizer, MangoHud e Gamescope reorganizados em uma única linha horizontal com 4 botões proporcionais.
- **Identificação do SO na Barra Inferior**:
  - O nome do computador na parte inferior esquerda foi substituído por `" Arch Linux"`, mantendo o `@bulldoze` no card superior.

### 📥 Nova Visualização da System Tray (Borda Superior Direita & Fusão Vetorial)
- **Remoção da System Tray do Notch Central (`Status.qml`)**:
  - A bandeja do sistema (`Tray`) foi completamente removida do notch superior, desacoplando os ícones de aplicativos em segundo plano da barra de status central.
  - O grupo da direita do notch (`Status.qml`) mantém os botões de Modo Jogo (``), Configurações (``) e Avatar, preservando a simetria e o equilíbrio central do relógio.
- **Novo Painel de System Tray Fundido à Borda Superior Direita (`shell.qml`, `TrayBarView.qml`)**:
  - **Fusão Vetorial Direta (`unifiedShape`)**: Extrusão orgânica na moldura perimetral superior direita da tela, espelhando a geometria do painel de notificações com curvas côncavas e convexas contínuas e borda sutil de 1px (`theme.glassBorderSubtle`).
  - **Perfil e Geometria Harmoniosa**: Altura fixa de 32px (`theme.notchHeight`), alinhada visualmente com a altura do notch superior e da barra de workspaces.
  - **Largura Responsiva**: Cálculo dinâmico baseado na contagem de ícones ativos da bandeja (`SystemTray.items`), com tiles individuais de 26x26px, espaçamento de 6px e insets do Design System.
  - **Tiles Interativos & Feedback Táctil**: Cada ícone é encapsulado em um tile de 26x26px com cantos arredondados de 6px (`theme.radiusSmall`), feedback de hover (`theme.hoverFill`), micro-escala táctil e ícone centralizado de 16x16px idêntico aos botões do notch.
  - **Gatilho de Hover na Borda (Hot Zone 48x48px)**: Passar o cursor sobre a zona sensível de 48x48px no canto superior direito revela a visualização da bandeja instantaneamente.
  - **Fechamento Instantâneo**: Recolhimento imediato com animação fluida ao remover o mouse da área da view ou interagir com o workspace.
  - **Suporte a Menus de Contexto SNI/DBus (`QsMenuAnchor`)**:
    - Clique esquerdo ativa o aplicativo (`modelData.activate()`).
    - Clique direito abre o menu de contexto nativo do aplicativo via `QsMenuAnchor` / SNI.
    - O painel permanece aberto e fixado enquanto qualquer menu de contexto estiver em exibição.
  - **Pegada Zero quando Vazia**: Quando não houver nenhum ícone ativo na bandeja (`trayItemCount === 0`), tanto o gatilho de hover quanto o container da view são completamente removidos da máscara do Wayland (`mask: Region`), permitindo cliques 100% transparentes sobre janelas subjacentes do workspace.

### 🗂️ Reformulação da Visualização de Workspaces (Dock Inferior Minimalista & Fusão Vetorial)
- **Remoção dos Workspaces do Notch Superior (`DefaultBarView.qml`)**:
  - As pílulas de workspaces foram completamente removidas do notch superior.
  - Foi mantido um espaçador simétrico à esquerda com largura equivalente ao grupo de status da direita, garantindo que o relógio permaneça rigorosamente travado no centro horizontal físico da tela.
- **Nova Barra de Workspaces na Borda Inferior Central (`shell.qml`)**:
  - **Fusão Vetorial Direta (`unifiedShape`)**: Extrusão orgânica na base central da moldura perimetral com curvas côncavas e convexas fluidas com traço de 1px contínuo, integrando-se perfeitamente ao ecossistema de docks do Bulldoze.
  - **Escalonamento Curvilíneo Contínuo (`dockCurveFactor`)**: Raios côncavos e convexos escalam proporcionalmente à altura de elevação da view, garantindo que a barra surja e recolha com tangência perfeita, sem "asas" ou arestas antecipadas.
  - **Geometria Responsiva**: Altura fixa de 32px (mesma altura do notch) e largura adaptativa proporcional à quantidade de workspaces ativos (`workspaceCount`), com padding interno de 18px (`theme.contentInset`).
  - **Gatilho por Comandos / Mudança de Workspace (2s)**: Toda alternância de workspace via atalhos globais (`SUPER + 1..9`, etc.) aciona a exibição do dock por 2 segundos com recolhimento automático suave.
  - **Gatilho de Hover na Borda Inferior (Hot Zone)**: Zona de detecção de 240px de largura e 24px de altura na base da tela, devidamente mapeada na máscara de entrada Wayland (`mask: Region`). Ao aproximar o mouse, o dock abre instantaneamente, permanecendo aberto enquanto o mouse estiver sobre a área e fechando imediatamente ao sair.
  - **Coexistência com Spotlight (`BottomLauncher.qml`)**:
    - Acionar comandos de workspace com o Spotlight aberto fecha o Spotlight e exibe a barra de workspaces por 2 segundos.
    - Acionar o Spotlight com a barra de workspaces aberta fecha a barra e abre o Spotlight imediatamente.
    - Hover na base da tela com o Spotlight aberto não aciona a barra de workspaces.
  - **Controle IPC**: Adicionados comandos `toggleWorkspaces` e `showWorkspaces` ao `IpcHandler`.
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
- **Remoção do Botão do Arch no Notch (`DefaultBarView.qml`)**:
  - Remoção do ícone/botão do Arch (`BulldozeLogo`) do notch superior, preservando a abertura do lançador exclusivamente via atalho global de teclado. O lado esquerdo agora abriga exclusivamente as pílulas dinâmicas de workspaces (`WorkspacePills`).
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
- **Otimizações para GPU AMD Radeon no Bulldoptimizer (`modules/Gaming.qml`, `LauncherBarView.qml`, `GamingSettingsBarView.qml`, `scripts/bulldoze-game-run`)**:
  - Transição de suporte de GPU da NVIDIA para a arquitetura AMD Radeon (foco na RX 9070 XT).
  - **AMD DPM Performance (Max Clocks)**: Trava o clock da GPU Core e da VRAM em performance máxima (`power_dpm_force_performance_level = high`, `pp_power_profile_mode = 1` [3D_FULL_SCREEN]), prevenindo downclocking repentino e frametime spikes.
  - **AMD RADV Anti-Lag & Shader Boost**: Injeção automática de variáveis de ambiente de alta performance no inicializador de jogos (`bulldoze-game-run`):
    - `AMD_VULKAN_ICD="RADV"`: Força o driver Vulkan da Valve/Mesa com compilador ACO.
    - `RADV_PERFTEST="aco,anti_lag"`: Ativa o compilador ACO e o AMD Anti-Lag para redução drástica de latência de entrada.
    - `MESA_SHADER_CACHE_MAX_SIZE="50G"`: Cache de shaders ampliado para 50GB, eliminando micro-travadas por recompilação.
    - `vk_xwayland_wait_ready=false`: Bypassa esperas artificiais de sincronização no XWayland.
    - `MESA_VK_WSI_PRESENT_MODE="mailbox"`: Apresentação imediata de quadros sem tearing e com menor latência.
    - `mesa_glthread=true`: Multi-threading assíncrono para jogos legados e títulos OpenGL.
  - Aplicação e reversão automáticas ao alternar o Bulldoptimizer ou sair dos jogos.
- **Auto-Pause do Wallpaper Exclusivo para Tela Cheia (`scripts/bulldoze-hypr-events.py`)**:
  - Ajustada a regra de suspensão do motor do Wallpaper Engine para considerar apenas janelas em tela cheia (`has_fs`) em vez de qualquer janela aberta (`win_count > 0`).
  - Permite que papéis de parede animados continuem em execução fluida durante o uso normal do desktop com janelas parciais/lado a lado, suspendendo e liberando 100% de VRAM e GPU apenas ao executar jogos em tela cheia.
- **Captura Assíncrona e Instantânea de Wallpaper Snapshots (`scripts/bulldoze-wallpaper.py`, `shell.qml`)**:
  - Pipeline otimizado em duas fases: geração instantânea via preview/textura do workshop (`snapshot`) e renderização em segundo plano da captura nativa 1440p limpa do engine (`snapshot-hires`).
  - Atualização imediata do banner do Launcher e da tela de login (`Wallpaper_greeter.png`), com notificação reativa via IPC (`reloadWallpaperSnapshot`), extinguindo congelamentos de interface ao alternar papéis de parede.
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
