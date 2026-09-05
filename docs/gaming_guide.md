# 🎮 Guia Completo: Gamescope & MangoHud no Bulldoze 3.0

Este documento descreve detalhadamente cada opção do painel de **Jogos (Gaming Settings)** integrado à Central de Controle do Bulldoze, explicando seu funcionamento interno, impacto no desempenho e as recomendações de uso para o seu setup (**AMD Radeon RX 9070 XT + Ryzen 7 5700X + Monitor 2560x1440 @ 240Hz**).

---

## 📑 Sumário
1. [Conceito Fundamental: Como Funciona o Gamescope](#1-conceito-fundamental-como-funciona-o-gamescope)
2. [Aba Gamescope: Configurações de Escala & Vídeo](#2-aba-gamescope-configurações-de-escala--vídeo)
   - [Micro-compositor Gamescope](#micro-compositor-gamescope)
   - [Resolução de Renderização Interna (Entrada)](#resolução-de-renderização-interna-entrada)
   - [Resolução de Saída (Display Físico)](#resolução-de-saída-display-físico)
   - [Upscaling & Filtros de Escala (FSR / NIS / Linear / Nearest)](#upscaling--filtros-de-escala)
   - [Nitidez do Upscaler](#nitidez-do-upscaler)
   - [Escalonamento Inteiro](#escalonamento-inteiro)
   - [Taxa de Atualização (Hz)](#taxa-de-atualização-hz)
   - [Modos de Janela & Sincronização (Fullscreen, Borderless, VRR)](#modos-de-janela--sincronização)
   - [HDR & Inverse Tone Mapping](#hdr--inverse-tone-mapping)
3. [Aba MangoHud: Telemetria e Monitoramento](#3-aba-mangohud-telemetria-e-monitoramento)
   - [Presets Rápidos](#presets-rápidos)
   - [Consumo de VRAM e RAM](#consumo-de-vram-e-ram)
   - [Métricas de GPU e CPU](#métricas-de-gpu-e-cpu)
   - [FPS, Frametimes e Posição](#fps-frametimes-e-posição)
4. [Como Jogar: Integração no Steam e Lutris](#4-como-jogar-integração-no-steam-e-lutris)
5. [Perfis Recomendados](#5-perfis-recomendados)

---

## 1. Conceito Fundamental: Como Funciona o Gamescope

O **Gamescope** é um micro-compositor Wayland desenvolvido pela Valve (o mesmo utilizado no SteamOS / Steam Deck). Em vez de rodar o jogo diretamente na sua área de trabalho, ele cria uma "janela isolada" onde controla de forma independente:
1. **A resolução interna que o jogo enxerga** (Entrada: `-w` e `-h`).
2. **A resolução física final do monitor** (Saída: `-W` e `-H`).
3. **O algoritmo que estica/reconstrói essa imagem** (Filtro: `-F fsr`, `-F nis`, etc.).

```
┌──────────────────────────────────────────────────────────┐
│ JOGO RENDERIZA EM: 1080p (1920x1080)                     │
│ -> A GPU processa menos pixels = FPS MUITO MAIOR        │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ GAMESCOPE APLICA: AMD FSR / NVIDIA NIS + NITIDEZ         │
│ -> Reconstrói bordas, texturas e preserva nitidez        │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ SAÍDA FINAL NA TELA: 2K Nativo (2560x1440 @ 240Hz)      │
│ -> Preenche todo o seu monitor sem bordas ou borrões     │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Aba Gamescope: Configurações de Escala & Vídeo

### Micro-compositor Gamescope
* **O que faz:** Ativa ou desativa o micro-compositor no script de lançamento (`bulldoze-game-run`).
* **Quando usar:** Deixe sempre ativo quando desejar usar upscaling, isolamento gráfico ou forçar taxas de atualização específicas.

---

### Resolução de Renderização Interna (Entrada)
* **Argumentos aplicados:** `-w <largura> -h <altura>`
* **O que faz:** Define a resolução virtual em que o jogo roda internamente antes de ser ampliado para o monitor.
* **Opções no Painel:**
  * **Nativa (2K / 1440p):** O jogo roda nativamente em 2560x1440 (sem upscaling). Máxima qualidade visual.
  * **1080p (1920x1080 - 75%):** *Modo Qualidade*. Roda internamente em Full HD e amplia para 2K. Proporciona ganho de **35% a 50% de FPS** mantendo a imagem extremamente nítida com FSR/NIS.
  * **960p (1706x960 - 66%):** *Modo Balanceado*. Ideal para jogos muito pesados (ex: Cities: Skylines com mods ou Cyberpunk).
  * **720p (1280x720 - 50%):** *Modo Desempenho / Inteiro*. Renderiza na metade da resolução do monitor. Excelente para jogos 2D/Pixel Art com *Escalonamento Inteiro* (escala perfeita de 2x).

---

### Resolução de Saída (Display Físico)
* **Argumentos aplicados:** `-W <largura> -H <altura>`
* **O que faz:** Informa ao Gamescope qual é a resolução real da sua tela física.
* **Opções:** `1440p` (2560x1440 - Padrão do seu monitor), `1080p`, `4K`, `720p`.

---

### Upscaling & Filtros de Escala
* **Argumentos aplicados:** `-F <filtro>`
* **O que faz:** Define a fórmula matemática usada para ampliar a imagem renderizada para a resolução da tela.
* **Opções Disponíveis:**
  * **FSR (AMD FidelityFX Super Resolution 1.0):** Reconstrói bordas geométricas e aplica contraste adaptativo em duas passagens. Excelente definição geral.
  * **NIS (NVIDIA Image Scaling v1.0.3):** Algoritmo proprietário da NVIDIA otimizado para placas GeForce (como a sua RTX 3060). Produz excelente nitidez direcional com baixíssimo overhead.
  * **Linear:** Filtro bilinear suave tradicional. Deixa a imagem mais macia, sem efeito de sharpening.
  * **Nearest (Vizinho Mais Próximo):** Não interpola pixels; mantém blocos puros.

---

### Nitidez do Upscaler
* **Argumento aplicado:** `--fsr-sharpness <0-20>`
* **O que faz:** Ajusta o nível de pós-processamento de nitidez do FSR/NIS.
* **Escala do Slider:**
  * **0 a 2:** Nitidez Máxima (Sharp). Ideal para compensar resoluções de entrada menores (como 1080p para 1440p).
  * **5:** Padrão balanceado da Valve.
  * **15 a 20:** Imagem mais suave (Soft).

---

### Escalonamento Inteiro
* **Argumento aplicado:** `-S integer`
* **O que faz:** Força o Gamescope a multiplicar cada pixel por um número inteiro exato (1x, 2x, 3x), sem fazer interpolação fracionária.
* **Exemplo Prático:** Renderizando em 720p (1280x720) num monitor de 1440p (2560x1440), cada pixel vira um bloco exato de 2x2 pixels. Elimina 100% de borrões em jogos retrô, emuladores e pixel-art.

---

### Taxa de Atualização (Hz)
* **Argumento aplicado:** `-r <Hz>`
* **O que faz:** Sincroniza a taxa de varredura do micro-compositor com o monitor.
* **Opções:** `240Hz`, `165Hz`, `144Hz`, `120Hz`, `60Hz`.
* **Recomendação:** Deixe em `240Hz` para aproveitar o painel do seu monitor.

---

### Modos de Janela & Sincronização
* **Tela Cheia Nativa (`--fullscreen`):** Captura a tela de forma exclusiva. Recomendado para menor latência de entrada (input lag).
* **Janela Sem Bordas (`-b`):** Executa em janela borderless. Facilita o Alt+Tab para a área de trabalho sem perder o foco.
* **Taxa Variável / VRR (`--adaptive-sync`):** Ativa G-Sync / FreeSync no monitor para eliminar tearing sem introduzir o atraso do V-Sync tradicional.

---

### HDR & Inverse Tone Mapping
* **Habilitar Saída HDR (`--hdr-enabled`):** Ativa o pipeline de cores de 10-bit para telas compatíveis com HDR.
* **Mapeamento Inverso SDR ➔ HDR (`--hdr-itm-enabled`):** Utiliza algoritmo em shader para expandir o alcance dinâmico de jogos desenvolvidos originalmente em SDR.
* **Luminância de Conteúdo SDR (`--hdr-sdr-content-nits`):** Ajusta o brilho base de elementos da interface e texturas convencionais dentro do espaço HDR (padrão recomendado: 300 a 400 nits).

---

## 3. Aba MangoHud: Telemetria e Monitoramento

O **MangoHud** projeta uma camada de telemetria diretamente na tela com baixíssimo impacto no desempenho.

### Presets Rápidos
* **Essencial:** FPS, Consumo de VRAM e Consumo de RAM (foco no uso de memória solicitado).
* **Completo:** Todas as métricas (temperaturas, frequências de clock em MHz, consumo elétrico em Watts, CPU e GPU).
* **Mínimo:** Exibição ultra compacta em linha única.

### Métricas Individuais
* **Consumo de VRAM (`vram`):** Mostra quantos MB/GB da memória da sua RTX 3060 (12GB) o jogo está consumindo.
* **Consumo de RAM (`ram`):** Mostra o total de memória RAM do sistema em uso.
* **Uso & Temp da GPU (`gpu_stats`, `gpu_temp`):** Carga percentual da GPU e temperatura em °C.
* **Clock da GPU (`gpu_core_clock`):** Frequência atual do chip gráfico (MHz).
* **Potência da GPU (`gpu_power`):** Consumo em Watts da placa de vídeo.
* **Uso, Temp & Clock da CPU (`cpu_stats`, `cpu_temp`, `cpu_mhz`):** Métricas do seu Ryzen 7 5700X.
* **Gráfico de Frametimes (`frametime`):** Linha de consistência de quadros em milissegundos. Se a linha estiver reta, o jogo está perfeitamente fluido; picos indicam *stuttering*.
* **Posição na Tela:** Escolha entre os 4 cantos (`Superior Esquerdo`, `Superior Direito`, `Inferior Esquerdo`, `Inferior Direito`).

---

## 4. Como Jogar: Integração no Steam e Lutris

O script central `bulldoze-game-run` lê automaticamente as preferências salvas no `gaming.json` através do painel.

### No Steam:
Abra as **Propriedades do Jogo** e na linha **Opções de Inicialização**, insira:
```bash
bulldoze-game-run %command%
```

### No Cities: Skylines (com Mods / Bypass do Launcher):
```bash
WINEDLLOVERRIDES="winhttp=n,b" bulldoze-game-run eval $(echo "%command%" | sed "s/dowser.exe/Cities.exe/")
```

### No Heroic / Lutris / Terminal:
```bash
bulldoze-game-run /caminho/para/o/executavel
```

---

## 5. Perfis Recomendados para o seu Setup

| Cenário | Renderização | Saída | Upscaler | Nitidez | VRR | MangoHud |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Jogos Pesados / Simulação (ex: Cities: Skylines)** | `1080p` | `1440p` | `NIS` ou `FSR` | `2` | `Ativo` | `Essencial` (VRAM + RAM) |
| **Jogos Competitivos (FPS / Alta Taxa)** | `1080p` | `1440p` | `FSR` | `1` | `Ativo` | `Mínimo` |
| **Jogos Leves / Qualidade Máxima** | `Nativa (2K)`| `1440p` | Desativado | - | `Ativo` | `Essencial` |
| **Jogos 2D / Retrô / Emuladores** | `720p` | `1440p` | `Escala Inteira` | - | Desativado | Desativado |
