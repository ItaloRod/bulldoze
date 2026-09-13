# Bulldoze --- Contexto & Especificação Técnica

## 1. Visão Geral & Stack
**Bulldoze** é o Desktop Shell / Design System pessoal construído sobre:
- **OS/Compositor**: Arch Linux + Hyprland (configurado exclusivamente em Lua: `~/.config/hypr/hyprland.lua`).
- **Framework de Shell**: Quickshell 0.3.0 + QtQuick / QML (`~/.config/quickshell/bulldoze/`).
- **Identidade Visual**: Glassmorphism e Liquid Glass. Elementos flutuantes em Dynamic Islands e pílulas (`LiquidGlass.qml`), 100% destacados das bordas físicas da tela com margem padrão de 8px (`islandMargin: 8`), sem moldura perimetral contínua e sem curvas côncavas aos bezels. Efeito Liquid Glass com pontos de luz especular superior (`glassBorderTop`), reflexo sutil inferior (`glassBorderBottom`), iluminação interna difusa (`glassHighlight`), sombra padrão unificada (`#59000000`, radius 20, offset Y 6) e blur nativo do Hyprland.

---

## 2. Design System: Sistema Unificado de Vidro Translúcido

### 2.1 Superfícies, Tokens & Cores (`Theme.qml`)
- **Formato de cor**: `#AARRGGBB` (QML).
- `glassFill`: `#33000000` (vidro translúcido ~20% alpha para Top Island, LockScreen e Greeter).
- `glassFillDark`: `#40000000` (vidro translúcido ~25% alpha para pílulas laterais, inferiores, modais, cards, popups).
- `glassBorder`: `#24FFFFFF` (borda perimetral sutil de 1px, 14% alpha).
- `glassBorderTop`: `#4DFFFFFF` (realce especular superior estilo Liquid Glass, 30% alpha).
- `glassBorderBottom`: `#14FFFFFF` (realce sutil inferior estilo Liquid Glass, 8% alpha).
- `glassHighlight`: `#26FFFFFF` (refração interna difusa superior estilo Liquid Glass, 15% alpha).
- `glassBorderSubtle`: `#18FFFFFF` (borda interna de 1px para itens e divisores, 9% alpha).
- `glassBorderStrong`: `#36FFFFFF` (borda de foco / hover / ativo, 21% alpha).
- `shadowColor`: `#59000000` (sombra padrão unificada, 35% alpha preto).
- `shadowRadius`: 20 (raio de desfoque da sombra).
- `shadowOffsetY`: 6 (deslocamento vertical da sombra, `shadowOffsetX: 0`).
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
- **Raios**: `radiusSmall: 6`, `radiusPill: 9999` (formato pílula integral `height / 2`), `radiusItem: 12`, `radiusCard: 18`, `radiusModal: 22`, `radiusIsland: 28` (Dynamic Islands expandidas), `radiusIslandLarge: 32` (LockScreen / Greeter).
- **Margens**: `islandMargin: 8` (afastamento padrão das bordas da tela).
- **Espaçamentos**: `spacingXs: 4`, `spacingSm: 8`, `spacingMd: 12`, `spacingLg: 16`, `spacingXl: 20`, `spacingXxl: 24`, `contentInset: 18`, `groupSpacing: 12`, `statusSpacing: 12`, `workspaceSpacing: 6`.

### 2.3 Motion & Animações (Calibrado para 240Hz High Refresh Rate)
- **Física Pegajosa / Elástica ("Sticky Spring")**: Entradas usam `Easing.OutBack` com `stickyOvershoot: 1.15` (ou 1.25 no LockScreen/Greeter) para criar amortecimento orgânico nos painéis flutuantes.
- **Saídas Rápidas**: Saídas usam decaimento direto (`Easing.InCubic` / `Easing.InQuad`).
- **Tokens de Duração (`Theme.qml`)**:
  - `animDurationMicro: 120ms` --- Flash de cor, ripples interativos (~30 frames @ 240Hz).
  - `animDurationFast: 180ms` --- Hover de itens, clique, switches (~45 frames @ 240Hz).
  - `animDurationNormal: 260ms` --- Workspace pills, sliders (~65 frames @ 240Hz).
  - `animDurationSticky: 320ms` --- Pílulas laterais, toasts, expansão de cards (~75 frames @ 240Hz).
  - `animDurationSlow: 360ms` --- Modais e aberturas completas (~85 frames @ 240Hz).
  - `animDurationExit: 200ms` --- Fechamento ágil (~50 frames @ 240Hz).
  - `notchExpandDuration: 340ms` --- Expansão suave da ilha no hover (`Easing.OutBack`).
  - `notchCollapseDuration: 240ms` --- Recolhimento da ilha ao retirar o mouse (`Easing.InOutCubic`).
  - `stickyOvershoot: 1.15` --- Fator de overshoot elástico dos painéis.
  - `buttonOvershoot: 1.30` --- Fator de pop tátil de botões interativos.

---

## 3. Arquitetura de Componentes & Dynamic Islands Flutuantes

### 3.1 Central Dynamic Island (`shell.qml`, `LiquidGlass.qml`, `DefaultBarView.qml`)
- **Posicionamento Flutuante**: Flutua a 8px do topo da tela ($y = 8\text{px}$, `islandMargin: 8`), completamente descolada da borda superior.
- **Layout em Linha Única com Altura Fixa (32px)**:
  - Mantém perfil contínuo e ultralimpo de 32px de altura em repouso.
  - Pílula compacta de repouso (~170-200px de largura) exibindo estritamente o Relógio e a Data em `pt-BR`.
- **Cálculo Dinâmico de Espaçamento e Largura**:
  - A largura expandida e recolhida é computada dinamicamente com base no conteúdo real, mantendo o relógio perfeitamente equilibrado no centro.
- **Interação Direta por Hover**:
  - Passar o cursor sobre a ilha de repouso abre diretamente o **Launcher Central** (`LauncherBarView.qml`, 920x640px) com a aba **Início** aberta.
  - Ao retirar o cursor, recolhe suavemente para a ilha compacta de repouso.

### 3.2 Barra Minimalista de Workspaces na Borda Inferior (`WorkspacePills.qml`, `shell.qml`)
- **Pílula Flutuante Independente**: Posicionada no centro inferior com 8px de margem ($y = \text{screen.height} - 32 - 8$).
- **Geometria & Ergonomia**: Altura fixa de 32px (mesma altura da ilha superior) e largura adaptativa ao número de workspaces ativos (`workspaceCount`), com padding interno simétrico de 18px.
- **Gatilhos & Comportamentos**:
  - **Comandos de Workspace**: Toda troca de workspace ativa a exibição temporária da barra por 2 segundos.
  - **Hover na Borda Inferior**: Zona de toque de 240x24px na base da tela (registrada em `mask: Region`) aciona a barra imediatamente. Permanece visível enquanto o cursor estiver dentro; fecha imediatamente ao sair.
  - **Coexistência com Spotlight**: Ao abrir o Spotlight (`SUPER + D`), a barra de workspaces fecha imediatamente. Ao trocar de workspace com o Spotlight aberto, o Spotlight fecha e a barra é exibida por 2 segundos.

### 3.3 Lançador de Aplicativos Inferior (`BottomLauncher.qml`, `shell.qml`)
- **Dock de Pesquisa Invertido Flutuante**: Posicionado na base ($640 \times 480\text{px}$, $y = \text{screen.height} - 480 - 8$).
- **Hierarquia Invertida**: Barra de busca com autofoco na base e lista de aplicativos expandindo-se para cima com navegação por teclado e acabamento Liquid Glass com `radiusIsland: 28`.

### 3.4 Barra Lateral de Volume (`AudioBarView.qml`, `shell.qml`)
- **Pílula Flutuante na Borda Esquerda**: Flutuante a 8px da borda esquerda ($x = 8, y = (\text{screen.height} - 230)/2$, $48 \times 230\text{px}$).
- **Controles Verticais**: Ícone de som com alternância rápida de mudo, slider vertical fino e botão de engrenagem para navegação direta até a aba de Som dos Ajustes.
- **OSD Inteligente (2s)**: Surge automaticamente ao pressionar atalhos de volume do teclado e recolhe em 2 segundos (pausando o timer se o mouse estiver sobreposto).

### 3.5 Modal Flutuante de Configurações de Jogos (`GamingSettingsModal.qml`)
- **Modal Centralizado Flutuante**: Janela centralizada ampla ($640 \times 560\text{ px}$) com rolagem suave (`Flickable`), cantos arredondados de $22\text{px}$ (`radiusModal`) e acabamento em vidro translúcido escuro.
- **Aba Gamescope (Completa)**: HDR Nativo, VRR / Adaptive Sync, Seletores de Taxa de Atualização (**240Hz**, 165Hz, 144Hz, 120Hz, 60Hz), AMD FSR, e trava de cursor (`--force-grab-cursor`).
- **Aba MangoHud (Completa)**: Presets rápido, GPU/CPU metrics, e layout HUD.

### 3.6 Central de Notificações no Canto Inferior Direito (`NotificationBarView.qml`, `shell.qml`, `modules/Notifications.qml`)
- **Pílula Flutuante no Canto**: Flutuante no canto inferior direito com 8px de margem ($x = \text{screen.width} - 380 - 8, y = \text{screen.height} - \text{height} - 8$).
- **Popup OSD (2,5s)**: Exibe apenas o card mais recente por 2,5 segundos com auto-hide.
- **Gatilho de Canto (Hot Zone)**: Passar o cursor na quina inferior direita revela a notificação mais recente instantaneamente.
- **Expansão em Pilha com Dwell de 2s**: Manter o mouse sobre o painel por 2 segundos expande a visualização para cima em até 4 notificações ($380 \times 96\text{px}$ a $380 \times 270\text{px}$).
- **Ordenação Bottom-to-Top & Rolagem**: A notificação mais recente fica sempre na base física do painel, com as mais antigas empilhando-se para cima.

### 3.7 On-Screen Display (`Osd.qml`, `BottomGlassPanel.qml`)
- **Cápsula Flutuante Inferior**: Cápsula/pílula ($300 \times 74\text{ px}$) centralizada com 8px de margem da base (`margins.bottom: 8`) utilizando `BottomGlassPanel.qml` e `LiquidGlass.qml`.
- **Geometria**: Pílula completa (`radiusPill: 9999`), iluminação Liquid Glass e sombra padrão unificada.
- **Animação**: Entrada elástica vertical ($y: 28 \to 0$, escala $0.90 \to 1.0$) com `animDurationSticky` (320ms), `Easing.OutBack` (overshoot 1.15) e saída suave via `animDurationExit` (200ms).

### 3.8 Tela de Bloqueio (`LockScreen.qml`, `LiquidGlass.qml`)
- **Card Flutuante Centralizado**: O card de autenticação e relógio ($680 \times 380\text{px}$) flutua centralizado vertical e horizontalmente na tela (`anchors.centerIn: parent`).
- **Fidelidade Total do Wallpaper (Zero Véu)**: Sem sobreposições de véu (`#30000000`), exibindo o wallpaper nativo em luminosidade natural com desfoque de fundo restrito ao container do card (`radiusIslandLarge: 32`).
- **Acabamento Liquid Glass & Sombra**: Envolto em `LiquidGlass.qml` com pontos de luz especular e sombra padrão unificada.
- **Relógio e Data Integrados no Header**: Relógio de alta visibilidade (52px Bold) + Data completa em `pt-BR` (14px Medium) no topo do card.
- **Autenticação & Feedback**: Avatar circular mascarado (`MultiEffect`), nome do usuário, campo de senha em pílula com alternador de visibilidade e animação de tremor (*shake*) em falha PAM.
- **Ações de Energia Integradas**: Botões estilizados no rodapé ($36 \times 36\text{px}$) para Suspender, Reiniciar e Desligar com tooltips em `pt-BR`.

### 3.9 QuickShell Greeter / Login Manager (`greeter.qml`, `Greeter.qml`, `LiquidGlass.qml`)
- **Card Flutuante Centralizado**: Card de login de alta fidelidade ($680 \times 400\text{px}$) centralizado vertical e horizontalmente na tela (`anchors.centerIn: parent`), unificado à linguagem visual da Lock Screen.
- **Acabamento Liquid Glass & Sombra**: Envolto em `LiquidGlass.qml` com pontos de luz especular e sombra padrão unificada, com desfoque de fundo restrito ao container do card (`radiusIslandLarge: 32`).
- **Identidade, Multi-Usuário e Seletor de Sessão**: Avatar com máscara arredondada (`MultiEffect`), seletor de sessão Wayland em pílula translúcida, e dropdown multi-usuário.
- **Autenticação & Feedback**: Campo de senha em pílula com alternador de visibilidade, botão de login ``, spinner `` e animação de tremor (*shake*).
- **Backend IPC Greetd (`scripts/greetd-client.py`)**: Cliente JSON-RPC via socket UNIX (`$GREETD_SOCK`).
- **Instalação Automatizada (`scripts/install-greeter.sh`)**: Copia recursivamente todos os componentes (incluindo `LiquidGlass.qml`) e módulos para `/etc/greetd/bulldoze-greeter/` com permissões `root:greeter` (755).

---

## 4. Integração Hyprland, GTK & Firefox

### 4.1 Hyprland (`~/.config/hypr/hyprland.lua`)
- **Gaps Externos**: `gaps_out: top 56, right 16, bottom 16, left 16` (calibrado com 8px margem + 32px ilha + 16px de folga proporcional para as janelas).
- **Arredondamento de Janelas**: `rounding = 12` (harmonizado com `radiusItem`).
- **Sombra Padrão Unificada**:
```lua
decoration = {
    shadow = {
        enabled = true,
        range = 20,
        render_power = 2,
        color = "rgba(00000059)",
        offset = "0 6",
    },
}
```
- **Regra de Camadas com Blur**:
```lua
hl.layer_rule({
    match = { namespace = "bulldoze-.*" },
    blur = true,
    ignore_alpha = 0.1,
})
```

### 4.2 Firefox & Thunar
- **Firefox (`userChrome.css`)**: Abas ativas, abas verticais e barra de URL em formato pílula (`border-radius: 9999px`), realce especular superior (`--bulldoze-glass-border-top`), reflexo sutil inferior (`--bulldoze-glass-border-bottom`) e sombra unificada.
- **Thunar / GTK3 (`~/.config/gtk-3.0/gtk.css`)**: Janelas com cantos de 12px, botões de navegação e barra de ferramentas em pílula (`border-radius: 9999px`) com sombra suave.

---

## 5. Critérios de Qualidade & Implementação

1. **Tokens Centralizados**: 100% dos estilos e durações de animação consumidos estritamente de `Theme.qml`.
2. **Liberdade Total das Bordas**: Remoção completa da moldura perimetral (`unifiedShape`) e de curvas côncavas aos bezels. Todos os componentes flutuam como Dynamic Islands ou pílulas com margem de 8px (`islandMargin: 8`).
3. **Efeito Liquid Glass & Sombra Padrão**: Todos os componentes de vidro implementam pontos de luz especular superior (`glassBorderTop`), reflexo inferior (`glassBorderBottom`), refração difusa interna (`glassHighlight`) e a sombra unificada (`#59000000`, radius 20, offset Y 6).
4. **Cards de Autenticação Centralizados**: LockScreen e Greeter flutuam perfeitamente centralizados vertical e horizontalmente na tela.
5. **Calibração 240Hz & Efeito Pegajoso**: Entradas utilizam `Easing.OutBack` com overshoot de 1.15 a 1.25 para um toque tátil/orgânico suave sem travamentos ou quebras de framerate.
6. **Zero Cores Sólidas Opacas & Zero Véus de Fundo**: Nenhuma superfície opaca preta/azul e nenhum véu artificial escurecendo o wallpaper do desktop, LockScreen ou Greeter. Apenas vidro translúcido com blur do compositor.
7. **0 Erros de Sintaxe / Lint**: Validação estrita via `qmllint`.
8. **Localização em Português Brasileiro (pt-BR)**: 100% dos textos, labels, botões, modais e formatação de datas (usando `Qt.locale("pt_BR")`) devem estar em português brasileiro.
9. **Padrão de Módulos Singleton (`modules/`)**: Módulos de lógica e backend (`Bluetooth.qml`, `Network.qml`, `Audio.qml`, `Gaming.qml`, `UserProfile.qml`, `Notifications.qml`) instanciados **exclusivamente como singletons no `shell.qml`**.
10. **Processos e Parsers de I/O (`Quickshell.Io`)**: Leituras de `stdout`/`stderr` de subprocessos devem utilizar estritamente `SplitParser` de `Quickshell.Io`.
11. **Gerenciamento de Processos Desanexados**: Execuções em segundo plano do QuickShell devem usar sessões desanexadas (`setsid`).
