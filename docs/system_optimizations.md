# ⚡ Guia de Otimização e Performance do Sistema — Bulldoze 3.5

Este documento detalha a camada de otimizações de agendamento de processos e gerenciamento de memória adotada no ecossistema do **Bulldoze 3.5**, garantindo altíssima fluidez na interface gráfica (Quickshell / Hyprland), resposta instantânea em multitarefas e prioridade máxima para jogos e aplicações pesadas.

---

## 📑 Sumário

1. [Visão Geral da Arquitetura de Performance](#1-visão-geral-da-arquitetura-de-performance)
2. [Ananicy-CPP & CachyOS Rules (Escalonamento de CPU e I/O)](#2-ananicy-cpp--cachyos-rules)
3. [KSM & CachyOS KSM Settings (Desduplicação de Memória RAM)](#3-ksm--cachyos-ksm-settings)
4. [Instalação e Configuração](#4-instalação-e-configuração)
5. [Monitoramento e Diagnóstico](#5-monitoramento-e-diagnóstico)
6. [Integração com o Bulldoze Gaming Hub](#6-integração-com-o-bulldoze-gaming-hub)

---

## 1. Visão Geral da Arquitetura de Performance

O ambiente Bulldoze utiliza efeitos visuais avançados de *glassmorphism*, animações a altas taxas de atualização (ex: 240Hz) e integração profunda com jogos via Gamescope e MangoHud.

Para garantir que a interface nunca apresente micro-travamentos (*stuttering* ou *frame drops*), mesmo quando o sistema estiver sob carga pesada (como compilação de pacotes, downloads em segundo plano ou renderização 3D), utilizamos duas tecnologias complementares:

```
┌────────────────────────────────────────────────────────┐
│                   PROCESSOS DO SISTEMA                 │
│  (Quickshell, Hyprland, Jogos Steam, Navegadores, etc) │
└───────────────┬────────────────────────┬───────────────┘
                │                        │
                ▼                        ▼
┌───────────────────────────────┐ ┌───────────────────────────────┐
│     ananicy-cpp + rules       │ │       ksmd (Kernel KSM)       │
│  - Prioridade dinâmica (nice) │ │  - Varredura de páginas RAM   │
│  - Políticas SCHED_RR/FIFO    │ │  - Desduplica páginas iguais  │
│  - I/O prioritário (ionice)   │ │  - Economia inteligente de RAM│
└───────────────┬───────────────┘ └───────────────┬───────────────┘
                │                                 │
                ▼                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    KERNEL LINUX & HARDWARE                      │
│             (Menor Latência + Máxima Responsividade)            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Ananicy-CPP & CachyOS Rules

### O que é?
O **`ananicy-cpp`** é uma reescrita moderna em C++ do daemon Ananicy (*ANother Auto NICe Daemon*). Ele monitora continuamente os processos em execução e aplica perfis de agendamento em tempo real com uso quase nulo de CPU e memória.

### CachyOS Rules (`cachyos-ananicy-rules`)
É a base de regras mantida e otimizada pela equipe do CachyOS. Ela define como cada tipo de processo deve se comportar:

* **Compositor & Shell (`Hyprland`, `quickshell`, `waybar`):** Ganham alta prioridade de agendamento e I/O, prevenindo congelamentos de tela e garantindo 240 FPS fluidos.
* **Jogos (`steam`, `gamescope`, `wine`, `proton`, executáveis nativos/DXVK):** Recebem prioridade máxima de CPU (`nice -10` a `-20` ou `SCHED_RR`), reduzindo a latência de entrada (*input lag*) e eliminando quedas bruscas de FPS.
* **Tarefas em Segundo Plano (`pacman`, `git`, compactadores, atualizadores):** São ajustadas para prioridade ociosa (*idle* / `nice 19`), evitando que monopolizem a CPU durante o uso interativo.

---

## 3. KSM & CachyOS KSM Settings

### O que é o KSM (*Kernel Samepage Merging*)?
O KSM é um recurso embutido no Kernel Linux que busca páginas de memória RAM com conteúdo 100% idêntico entre múltiplos processos e as funde em uma única página compartilhada com proteção *Copy-on-Write* (CoW). Se algum processo tentar alterar os dados, o Kernel cria uma cópia instantânea isolada.

### `cachyos-ksm-settings` (Substituto moderno do `uksmd`)
Em vez de depender de um daemon de espaço de usuário pesado, o `cachyos-ksm-settings` configura e gerencia o KSM nativo diretamente através de unidades e *overrides* do `systemd`:
* **Economia Real de RAM:** Especialmente eficiente para navegadores baseados em Chromium/Firefox (múltiplas abas), máquinas virtuais (QEMU/KVM), containers e processos Qt/QML.
* **Eficiência:** Configurado para varrer intervalos inteligentes sem gerar aquecimento ou consumo de CPU desnecessário.

---

## 4. Instalação e Configuração

### Instalação via AUR / Repositórios CachyOS:
```bash
yay -S ananicy-cpp cachyos-ananicy-rules cachyos-ksm-settings
```
*(Se solicitado o provedor de `libspdlog`, selecione a versão otimizada do repositório `cachyos-extra-v3`).*

### Habilitação dos Serviços do Systemd:
```bash
# Ativar o daemon de prioridades de processos
sudo systemctl enable --now ananicy-cpp

# Ativar a desduplicação de memória KSM
sudo systemctl enable --now ksmd
```

---

## 5. Monitoramento e Diagnóstico

Para verificar se os serviços estão em execução e checar a telemetria do sistema:

### 1. Status dos Serviços:
```bash
systemctl status ananicy-cpp
systemctl status ksmd
```

### 2. Estatísticas de Economia de Memória RAM:
Execute a ferramenta oficial do CachyOS KSM:
```bash
ksmstats
```
*Saída esperada:*
```text
=====================
ksmstats for CachyOS
=====================
Full scans               ...
Interval                 20 ms
Pages sharing            ... MiB
Pages shared             ... MiB
General profit           ... MiB  <-- Quantidade de RAM economizada
```

---

## 6. Integração com o Bulldoze Gaming Hub

Quando você executa jogos através do launcher integrado do Bulldoze (`bulldoze-game-run`), o pipeline completo atua em conjunto:

1. **Gamescope:** Realiza o upscale e controle de resolução/refresh rate (ex: FSR/NIS para 1440p @ 240Hz).
2. **MangoHud:** Exibe as métricas de frametime e consumo em tempo real.
3. **Ananicy-CPP:** Eleva a prioridade do Gamescope e do executável do jogo para tempo real.
4. **KSM:** Otimiza o footprint de memória dos launchers e processos de apoio.
