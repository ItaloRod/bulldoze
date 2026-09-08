# Bulldoze --- Contexto & Especificação Técnica

## 1. Visão Geral & Stack
**Bulldoze** é o Desktop Shell / Design System pessoal construído sobre:
- **OS/Compositor**: Arch Linux + Hyprland (configurado exclusivamente em Lua: `~/.config/hypr/hyprland.lua`).
- **Framework de Shell**: Quickshell 0.3.0 + QtQuick / QML (`~/.config/quickshell/bulldoze/`).
- **Identidade Visual**: Glassmorphism e profundidade física. Painéis de vidro translúcido acoplados fisicamente às bordas do monitor (Top Notch Bar, Top Morphing LockScreen & Greeter, Side Panels, Bottom OSD) com arcos côncavos de transição (`notchConcaveWidth: 16px`, `notchConcaveHeight: 10px`, `notchTopRadius: 12px`), cantos convexos arredondados (`notchBottomRadius: 14px`), blur nativo do Hyprland em todas as superfícies e ausência de bordas opacas ou elementos flutuantes desordenados.

---

## 2. Design System: Sistema Unificado de Vidro Translúcido

### 2.1 Superfícies, Tokens & Cores (`Theme.qml`)
- **Formato de cor**: `#AARRGGBB` (QML).
- `glassFill`: `#33000000` (vidro translúcido ~20% alpha para o notch superior, LockScreen e Greeter).
- `glassFillDark`: `#40000000` (vidro translúcido ~25% alpha para notches laterais, inferior, modais, cards, popups).
- `glassBorder`: `#24FFFFFF` (borda sutil de 1px, 14% alpha exposta ao desktop).
- `glassBorderSubtle`: `#18FFFFFF` (borda de 1px interna para itens e divisores, 9% alpha).
- `glassBorderStrong`: `#36FFFFFF` (borda de foco / hover / ativo, 21% alpha).
- `itemFill`: `#10FFFFFF` (fundo sutil para botões e tiles inativos).
- `hoverFill`: `#1CFFFFFF` (realce suave de hover).
- `activeFill`: `#33FFFFFF` (realce de toggle ativo).
- `separator`: `#1AFFFFFF` (linha divisória de 1px).
- `accent`: `#FFFFFF` (branco de destaque para indicadores, foco e spinners de carregamento).
- `textStrong`: `#F2FFFFFF` (títulos, hora, ícones principais).
- `textMedium`: `#DFFFFFFF` (corpo, nomes de app, workspaces ativos).
- `textMuted`: `#BFFFFFFF` (data, descrições secundárias, subtítulos).
- `textSubtle`: `#80FFFFFF` (placeholders de pesquisa, dicas).
- `indicatorInactive`: `#66FFFFFF` (workspaces inativos, status inativo).

### 2.2 Escala de Raios e Espaçamentos
- **Raios**: `radiusSmall: 6`, `radiusPill: 6`, `radiusItem: 12`, `radiusCard: 18`, `radiusModal: 22`.
- **Geometria do Notch (`GlassPanel.qml`)**: `notchHeight: 36`, `notchHoverHeight: 42`, `notchExpandedHeight: 48`, `notchRadius: 14`, `notchTopRadius: 12`, `notchConcaveWidth: 16`, `notchConcaveHeight: 10`, `notchBottomRadius: 14`.
- **Larguras do Notch**: `notchCollapsedWidth: 200` (idle calculado dinamicamente), `notchExpandedWidth: 680` (hover / subviews), `notchWidthRatio: 0.28`.
- **Espaçamentos**: `spacingXs: 4`, `spacingSm: 8`, `spacingMd: 12`, `spacingLg: 16`, `spacingXl: 20`, `spacingXxl: 24`, `contentInset: 18`, `groupSpacing: 12`, `statusSpacing: 12`, `workspaceSpacing: 6`.

### 2.3 Motion & Animações (Calibrado para 240Hz High Refresh Rate)
- **Física Pegajosa / Elástica ("Sticky Spring")**: Entradas usam `Easing.OutBack` com `stickyOvershoot: 1.15` (ou 1.25 no LockScreen/Greeter) para criar amortecimento orgânico de acoplamento às bordas da tela.
- **Saídas Rápidas**: Saídas usam decaimento direto (`Easing.InCubic` / `Easing.InQuad`).
- **Tokens de Duração (`Theme.qml`)**:
  - `animDurationMicro: 120ms` --- Flash de cor, ripples interativos (~30 frames @ 240Hz).
  - `animDurationFast: 180ms` --- Hover de itens, clique, switches (~45 frames @ 240Hz).
  - `animDurationNormal: 260ms` --- Workspace pills, sliders (~65 frames @ 240Hz).
  - `animDurationSticky: 320ms` --- Notches laterais, toasts, expansão de cards (~75 frames @ 240Hz).
  - `animDurationSlow: 360ms` --- Modais e aberturas completas (~85 frames @ 240Hz).
  - `animDurationExit: 200ms` --- Fechamento ágil (~50 frames @ 240Hz).
  - `notchExpandDuration: 340ms` --- Expansão suave do notch no hover (`Easing.OutBack`).
  - `notchCollapseDuration: 240ms` --- Recolhimento do notch ao retirar o mouse (`Easing.InOutCubic`).
  - `stickyOvershoot: 1.15` --- Fator de overshoot elástico dos painéis.
  - `buttonOvershoot: 1.30` --- Fator de pop tátil de botões interativos.

---

## 3. Arquitetura de Componentes & Dynamic Top Morphing Notch

### 3.1 Central Glass Notch (`shell.qml`, `GlassPanel.qml`, `components/views/`)
- **Acoplamento**: Fisicamente dockado no topo da tela ($y = 0$).
- **Layout em Linha Única com Altura Fixa (32px)**:
  - Mantém perfil contínuo e ultralimpo de 32px de altura tanto em repouso quanto em hover.
  - Eliminação de expansões verticais excessivas e da antiga linha secundária de controles rápidos.
- **Cálculo Dinâmico de Espaçamento e Largura**:
  - A largura expandida e recolhida é computada dinamicamente com base no conteúdo real (`contentExpandedWidth: 620px-680px`), mantendo o relógio perfeitamente equilibrado no centro.
- **Encapsulamento do Notch**:
  - **Esquerda (revelada no hover)**: Espaçador simétrico equivalente à largura do grupo de status da direita, mantendo o relógio rigorosamente equilibrado no centro.
  - **Centro (sempre visível)**: Relógio em linha única (Hora 13px DemiBold + Data 11px Medium em `pt-BR`).
  - **Direita (`Status.qml`)**: System Tray + Botão Modo Jogo (`""`) + Botão de Configurações (`""`).
  - **Modos Ativos Integrados**:
    - **Modo Jogo (`GamingBarView.qml`)**: Altura compacta (68px) com centralização simétrica e largura ideal calculada dinamicamente (`idealWidth`), contendo toggles para **GameMode**, **MangoHud**, e **Gamescope**, além de acesso aos ajustes avançados.
    - **Modo Perfil & Menu de Energia (`PowerBarView.qml`)**: Avatar circular ($26\text{px}$), nome de usuário com Privacy Blur e 4 ações de energia (Bloquear, Deslogar, Reiniciar, Desligar).
    - **Launcher Central do Sistema (`LauncherBarView.qml`, 920x640px)**: Central de controle e lançador unificado acionado via hover no topo (hotspot de 920px) ou `SUPER + H`. Possui barra horizontal de categorias no topo, banner responsivo de 180px com ajuste fino de corte/enquadramento, blocos empilhados de Data/Hora (relógio 48px e calendário) e Central de Jogos em 100% da largura, além de abas para Wi-Fi, Bluetooth, Som, Wallpapers e Jogos.

### 3.2 Barra Minimalista de Workspaces na Borda Inferior (`WorkspacePills.qml`, `shell.qml`)
- **Fusão Vetorial Direta (`unifiedShape`)**: Extrusão orgânica na base da moldura perimetral, compartilhando o sistema de morphing do dock inferior.
- **Escalonamento Curvilíneo Contínuo (`dockCurveFactor`)**: Os côncavos e cantos convexos escalam dinamicamente e proporcionalmente à altura de elevação da barra, garantindo transições perfeitamente contínuas e sem "asas" prematuras.
- **Geometria & Ergonomia**: Altura fixa de 32px (mesma altura do notch) e largura adaptativa ao número de workspaces ativos (`workspaceCount`), com padding interno simétrico de 18px.
- **Gatilhos & Comportamentos**:
  - **Comandos de Workspace**: Toda troca de workspace ativa a exibição temporária da barra por 2 segundos.
  - **Hover na Borda Inferior**: Zona de toque de 240x24px na base da tela (registrada em `mask: Region`) aciona a barra imediatamente. Permanece visível enquanto o cursor estiver dentro; fecha imediatamente ao sair.
  - **Coexistência com Spotlight**: Ao abrir o Spotlight (`SUPER + D`), a barra de workspaces fecha imediatamente. Ao trocar de workspace com o Spotlight aberto, o Spotlight fecha e a barra é exibida por 2 segundos.

### 3.3 Lançador de Aplicativos Inferior (`BottomLauncher.qml`, `shell.qml`)
- **Dock de Pesquisa Invertido**: Fisicamente fundido à borda inferior de 8px em `unifiedShape` ($640 \times 480\text{px}$).
- **Hierarquia Invertida**: Barra de busca com autofoco na base e lista de aplicativos expandindo-se para cima com navegação por teclado e visual translúcido.

### 3.3 Barra Lateral de Volume (`AudioBarView.qml`, `shell.qml`)
- **Extrusão na Borda Esquerda**: Integrada diretamente à moldura perimetral esquerda de 8px em `unifiedShape` ($48 \times 230\text{px}$) com asas côncavas suaves.
- **Controles Verticais**: Ícone de som com alternância rápida de mudo, slider vertical fino e botão de engrenagem para navegação direta até a aba de Som dos Ajustes.
- **OSD Inteligente (2s)**: Surge automaticamente ao pressionar atalhos de volume do teclado e recolhe em 2 segundos (pausando o timer se o mouse estiver sobreposto).

### 3.4 Modal Flutuante de Configurações de Jogos (`GamingSettingsModal.qml`)
- **Modal Centralizado Flutuante**: Janela centralizada ampla ($640 \times 560\text{ px}$) com rolagem suave (`Flickable`), cantos arredondados de $22\text{px}$ (`radiusModal`) e acabamento em vidro translúcido escuro.
- **Aba Gamescope (Completa)**:
  - **Visual & HDR**: HDR Nativo (`--hdr-enabled`), Mapeamento Inverso SDR $\to$ HDR (`--hdr-itm-enabled`), Seletor de Nits SDR (200, 300, 400, 600, 1000 nits).
  - **Exibição & Sincronização**: Tela Cheia Exclusiva (`--fullscreen`), Janela Sem Bordas (`-b`), Adaptive Sync / VRR (`--adaptive-sync`), Seletor de Taxa de Atualização (**240Hz**, **165Hz**, **144Hz**, **120Hz**, **60Hz**), Seletor de Resolução Nativa (**1440p**, **1080p**, **4K UHD**, **UW 3440p**).
  - **Upscaling & Filtros de Escala**: AMD FidelityFX FSR (`-F fsr`), Seletor de Nitidez FSR (Suave 0, Padrão 2, Nítido 5, Máximo 10), Integer Scaling / Pixel Perfect (`-S integer`), Resolução de Renderização Interna (Nativo, 1080p, 720p), Limitador de FPS (Sem Limite, 240, 165, 144, 120, 60 FPS).
- **Aba MangoHud (Completa)**:
  - **Presets Rápidos**: Completo, Essencial, Mínimo.
  - **Performance & GPU**: FPS em tempo real, Gráfico de Frametime (ms), Carga e Temperatura da GPU (°C), Alocação de Memória VRAM, Potência em Watts e Clock do Núcleo (MHz).
  - **CPU & Sistema**: Carga e Temperatura da CPU (°C), Memória RAM do Sistema, Consumo em Watts e Frequência dos núcleos (MHz).
  - **Layout & Posição**: Topo-Esquerda, Topo-Direita, Base-Esquerda, Base-Direita, Modo Linha Compacta (`hud_compact`).

### 3.5 Gerenciador de Wallpapers & Wallpaper Engine (`WallpaperManagerModal.qml`, `modules/WallpaperEngine.qml`)
- **Modal Centralizado Flutuante**: Janela ampla ($920 \times 640\text{px}$) acionada globalmente pelo atalho **`ALT + W`** (`hyprland.lua`), construída em vidro translúcido escuro (`glassFillDark`), borda de 1px (`glassBorder`) e `radiusModal` (22px).
- **Galeria Visual Integrada da Steam**:
  - Escaneia a pasta do Workshop da Steam (`~/.local/share/Steam/steamapps/workshop/content/431960/`) e faz cache automático de previews em `~/.cache/bulldoze/wallpapers/`.
  - Grid responsivo de cards com thumbnails de alta definição, títulos, tags e badges de wallpaper ativo (` ATIVO`) e tipo (`CENA` / `VÍDEO`).
  - Campo de busca instantânea com filtro em tempo real por título, ID ou tags.
- **Painel de Customização & Aspect Ratio**:
  - **Proporção da Tela**: Seletor de enquadramento: `Preencher (Fill - 16:9)`, `Adaptar (Fit - Exibir inteiro sem cortes)` e `Esticar (Stretch)`.
  - **Porta de Vídeo / Monitor**: Dropdown dinâmico com auto-detecção via Hyprland IPC e DRM, permitindo selecionar em qual saída de vídeo (`DP-1`, `HDMI-A-1`, etc.) ou no modo automático o wallpaper deve ser renderizado, com fallback inteligente caso portas sejam trocadas fisicamente.
  - **Remoção Automática de Patrocinadores/Doações**: Varredura profunda do `scene.pkg` para identificar objetos de QR code/doações (`sponsor_tip_x`, `微信赞助码`, `objeto 33`, etc.) e descarte direto na GPU via `--render-debug skip-object=<id>`.
  - **Propriedades Dinâmicas de Cena**: Mapeia automaticamente variáveis de shaders (`透视开关` / Raio-X, `透视大小` / Raio do Mouse, cores, switches e sliders).
  - **Desempenho**: Seletores de taxa de quadros (60, 120, 240 FPS), toggle de interatividade de mouse/parallax e pausa automática em janelas visíveis (áudio estritamente silenciado via `--silent`).
- **Isolamento de Áudio PipeWire**: Execução de papéis de parede com driver dummy no SDL/OpenAL para evitar deadlocks na renegociação de Bluetooth/YouTube ao pausar em segundo plano.

### 3.6 Central de Notificações no Canto Inferior Direito (`NotificationBarView.qml`, `shell.qml`, `modules/Notifications.qml`)
- **Fusão Diagonal no Canto da Moldura (`unifiedShape`)**:
  - Extrusão orgânica ancorada diretamente no canto inferior direito da tela, integrada à malha vetorial contínua de 8px.
  - A borda lateral direita transiciona suavemente em curva côncava para o topo do painel, e a base esquerda transiciona em curva côncava para a borda inferior, sem nenhum vão ou linha de corte.
- **Popup OSD (2,5s)**:
  - Ao chegar uma nova notificação, exibe apenas o card mais recente por 2,5 segundos com auto-hide.
- **Gatilho de Canto (Hot Zone)**:
  - Passar o cursor na quina inferior direita revela a notificação mais recente instantaneamente (ou estado vazio *"Nenhuma notificação"*).
  - Fechamento imediato ao retirar o mouse.
- **Expansão em Pilha com Dwell de 2s**:
  - Manter o mouse sobre o painel por 2 segundos expande a visualização para cima em até 4 notificações ($380 \times 96\text{px}$ a $380 \times 270\text{px}$).
- **Ordenação Bottom-to-Top & Rolagem**:
  - A notificação mais recente fica sempre na base física do painel, com as mais antigas empilhando-se para cima.
  - Rolagem nativa por roda do mouse (*mouse wheel*) quando houver mais de 4 notificações.
- **Ações & Limpeza**:
  - Botão individual "x" (``) para fechar cada alerta.
  - Botão de lixeira (``) na base para apagar todas as notificações de uma vez (visível estritamente quando expandido).

### 3.7 On-Screen Display (`Osd.qml`, `BottomGlassPanel.qml`)
- **Acoplamento Inferior**: Cápsula/Notch inferior ($300 \times 74\text{ px}$) dockado fisicamente na borda inferior da tela ($y = \text{screen.height}$, `margins.bottom: 0px`) utilizando `BottomGlassPanel.qml`.
- **Geometria**: Arcos côncavos na base flaring no bezel inferior e cantos convexos arredondados no topo, com borda sutil de 1px nos limites livres.
- **Animação**: Entrada elástica vertical ($y: 28 \to 0$, escala $0.90 \to 1.0$) com `animDurationSticky` (320ms), `Easing.OutBack` (overshoot 1.15) e saída suave via `animDurationExit` (200ms) `Easing.InCubic`.

### 3.8 Tela de Bloqueio (`LockScreen.qml`, `GlassPanel.qml`)
- **Fidelidade Total do Wallpaper (Zero Véu)**:
  - `WlSessionLockSurface.color` é estritamente `"transparent"`.
  - **Zero Véu ou Overlay Escurecedor**: Remoção total de qualquer camada de escurecimento sobre a imagem (`#30000000` ou similar). O wallpaper exibe 100% de saturação, nitidez e brilho naturais do desktop logado.
  - Recarregamento forçado de buffer de imagem (`bgImage.source`) e reinício determinístico da animação de entrada (`introAnim.restart()`) no gatilho `onLockedChanged`.
- **Arquitetura Top-Docked Dynamic Notch**: O card de autenticação e relógio ($680 \times 380\text{px}$) é fisicamente dockado no topo da tela ($y = 0$) utilizando `GlassPanel.qml`, espelhando com total fidelidade e continuidade a Top Notch Bar.
- **Continuidade e Animação de Expansão (Sticky Spring)**:
  - Ao bloquear a tela, o notch expande-se suavemente a partir do tamanho da barra fechada ($160\text{px} \times 36\text{px} \to 680\text{px} \times 380\text{px}$) com `Easing.OutBack` (overshoot: 1.25, duração: 380ms).
  - Ao validar a senha com sucesso no PAM, o card recolhe graciosamente de volta à barra padrão antes do desbloqueio da sessão.
- **Relógio e Data Integrados no Header**:
  - Relógio de alta visibilidade (52px Bold) + Data completa em `pt-BR` (14px Medium) integrados diretamente na parte superior do card, perfeitamente alinhados com a tipografia do `Clock.qml` e `Greeter.qml`.
- **Autenticação & Feedback**:
  - Avatar circular mascarado (`MultiEffect`), nome do usuário, campo de senha com alternador de visibilidade (olho `""`/`""`), submit ``, e animação de tremor (*shake*) com mensagem de erro em caso de falha.
  - PAM nativo via `Quickshell.Services.Pam` (`PamContext`).
- **Ações de Energia Integradas**: Botões estilizados no rodapé do notch ($36 \times 36\text{px}$) para Suspender, Reiniciar e Desligar com efeitos táteis de hover e tooltips em `pt-BR`.
- **Blur Puro de Componente (`GlassPanel.qml`)**:
  - Desfoque fosco restrito à geometria do card com `brightness: 0.0` e `contrast: 0.0`, preservando a luminosidade do wallpaper subjacente sem rebaixamento sintético de brilho.

### 3.9 QuickShell Greeter / Login Manager (`greeter.qml`, `Greeter.qml`, `GlassPanel.qml`)
- **Fidelidade Total do Wallpaper (Zero Véu)**:
  - `PanelWindow.color` é estritamente `"transparent"`.
  - Sem sobreposições de véu (`#30000000`), exibindo o wallpaper nativo de `/var/lib/greetd/Wallpaper_greeter.png`.
- **Ponto de Entrada (`greeter.qml`)**: Executado diretamente pelo `greetd` (`quickshell -p /etc/greetd/bulldoze-greeter`) sob o namespace Wayland `"bulldoze-greeter"`, com camada `WlrLayer.Overlay`, foco de teclado exclusivo e suporte a múltiplos monitores via `Variants`.
- **Arquitetura Top-Docked Dynamic Notch**: Card de login de alta fidelidade ($680 \times 400\text{px}$) dockado no topo ($y = 0$) através de `GlassPanel.qml`, unificado à linguagem visual da Lock Screen.
- **Animação de Expansão e Desbloqueio**: Expansão do notch superior ($160\text{px} \times 36\text{px} \to 680\text{px} \times 400\text{px}$) na inicialização e recolhimento responsivo ao concluir o login com sucesso.
- **Relógio e Data no Topo**: Tipografia ampla Bold + data completa em `pt-BR` no topo do card.
- **Identidade, Multi-Usuário e Seletor de Sessão**:
  - Avatar com máscara arredondada (`MultiEffect`), sincronizado com `~/.face` e AccountsService, exibindo Nome de Exibição e Hostname, com dropdown para alternância entre múltiplos usuários do sistema.
  - Seletor de Sessão Wayland em pílula translúcida com prioridade padrão para `Hyprland` e menu popup suspenso para as demais sessões disponíveis (`/usr/share/wayland-sessions`).
- **Autenticação & Feedback**: Campo de senha com alternador de visibilidade (olho ``/``), botão de login `` com spinner rotativo `` durante a autenticação e efeito de tremor (*shake*) em caso de erro.
- **Ações de Energia**: Tiles integrados ($36 \times 36\text{px}$) para Suspender (`systemctl suspend`), Reiniciar (`systemctl reboot`) e Desligar (`systemctl poweroff`) com tooltips informativas superiores.
- **Backend IPC Greetd (`scripts/greetd-client.py`)**: Cliente JSON-RPC via socket UNIX (`$GREETD_SOCK`) para descoberta dinâmica de usuários, sessões `.desktop` e fluxo completo de autenticação PAM com o `greetd`.
- **Instalação e Deploy Total (`scripts/install-greeter.sh`)**: Script automatizado que copia recursivamente todos os componentes (`components/*` incluindo `GlassPanel.qml`) e módulos (`modules/*`) para `/etc/greetd/bulldoze-greeter/`, ajusta permissões `root:greeter` (755) e configura o script `/usr/local/bin/bulldoze-greeter-start`.

---

## 4. Integração Hyprland & Blur

Configuração em `~/.config/hypr/hyprland.lua`:
- **Estilo Limpo Sem Bordas e Sem Sombras**: `border_size = 0` e `shadow = { enabled = false }` para foco total na profundidade glassmórfica translúcida.
- **Regra de Camadas com Blur**:
```lua
hl.layer_rule({
    match = { namespace = "bulldoze-.*" },
    blur = true,
    ignore_alpha = 0.1,
})
```

---

## 5. Critérios de Qualidade & Implementação

1. **Tokens Centralizados**: 100% dos estilos e durações de animação consumidos estritamente de `Theme.qml`.
2. **Integração Física aos Bezels**: Painéis do topo, laterais e inferior utilizam `GlassPanel.qml`, `SideGlassPanel.qml` e `BottomGlassPanel.qml` com arcos côncavos de 16px e cantos convexos de 14px, sem desenhar bordas nos pontos de contato com a borda da tela.
3. **Calibração 240Hz & Efeito Pegajoso**: Entradas utilizam `Easing.OutBack` com overshoot de 1.15 a 1.25 para um toque tátil/orgânico suave sem travamentos ou quebras de framerate.
4. **Zero Cores Sólidas Opacas & Zero Véus de Fundo**: Nenhuma superfície opaca preta/azul e nenhum véu artificial escurecendo o wallpaper do desktop, LockScreen ou Greeter. Apenas vidro translúcido com blur do compositor.
5. **0 Erros de Sintaxe / Lint**: Validação estrita via `qmllint`.
6. **Localização em Português Brasileiro (pt-BR)**: 100% dos textos, labels, botões, modais e formatação de datas (usando `Qt.locale("pt_BR")`) devem estar em português brasileiro.
7. **Padrão de Módulos Singleton (`modules/`)**: Módulos de lógica e backend (`Bluetooth.qml`, `Network.qml`, `Audio.qml`, `Gaming.qml`, `UserProfile.qml`, `Notifications.qml`) que mantêm timers de polling, listeners ou disparam notificações de sistema (`notify-send`) devem ser instanciados **exclusivamente como singletons no `shell.qml`** e injetados via propriedades nas subviews e componentes. **Nunca declarar instâncias internas de fallback (`internal*`) dentro de componentes visuais**, pois o QML cria os objetos eagerly na árvore, provocando duplicação de processos, desperdício de CPU e notificações múltiplas/triplicadas.
8. **Processos e Parsers de I/O (`Quickshell.Io`)**: Leituras de `stdout`/`stderr` de subprocessos devem utilizar estritamente `SplitParser` de `Quickshell.Io` (nunca tipos inexistentes como `StringParser`), acumulando ou processando as linhas emitidas.
9. **Gerenciamento de Processos Desanexados**: Execuções em segundo plano do QuickShell devem usar sessões desanexadas (`setsid`) para evitar encerramentos inesperados por sinais SIGHUP de subshells temporárias.
