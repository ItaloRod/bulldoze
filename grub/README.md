# Bulldoze 3.0 — GRUB Theme (QHD 2560×1440)

Tema oficial do GRUB 2 alinhado com o [design.md](../docs/design.md): estética de vidro translúcido escuro, geometria suave de abas côncavas nas extremidades, borda de 1px sutil (`#24FFFFFF`), suporte a ícones de distribuição e sincronização automática de wallpaper com o Greeter/Lockscreen.

## Características

- **Ancoragem no Bezel Esquerdo**: Notch lateral físico fundido à borda da tela ($x=0$) com espaçamento de 20% do canto inferior esquerdo ($y = 1152\text{px}$ na base, sobrando $288\text{px}$ de respiro inferior).
- **Curvas Côncavas Orgânicas**: Curvatura cúbica de transição nas pontas superior e inferior (`16×20px`) com cantos convexos arredondados de $18\text{px}$.
- **Vidro Translúcido com Blur Pré-Renderizado**: Efeito de blur estático sob o notch renderizado diretamente no wallpaper pelo backend de wallpapers do Bulldoze.
- **Sincronização Automática**: Sempre que você alterar o papel de parede pelo Wallpaper Manager do Bulldoze, o script atualiza automaticamente o `background.png` do GRUB.
- **Localização 100% em Português do Brasil (`pt-BR`)**: Instruções de navegação, cabeçalhos e status de inicialização automática.
- **Ícones de SO**: Suporte a ícones de 24×24px para Arch Linux, Linux genérico/LTS, Windows e UEFI Firmware.

## Estrutura de Arquivos

```text
grub/
├── theme.txt              # Configuração visual do tema gfxmenu para 2560×1440
├── notch_panel.png        # Painel gráfico com curvaturas côncavas e borda de 1px (#24FFFFFF)
├── selected.png           # Pílula de seleção ativa com cantos arredondados (508×48px)
├── background.png         # Wallpaper QHD com blur gaussiano pré-calculado sob o notch
├── dot.png                # Indicador pontual de status
├── fonts/                 # Fontes compiladas no formato proprietário PF2 do GRUB
│   ├── dejavu_bold_20.pf2
│   ├── dejavu_sans_14.pf2
│   └── dejavu_sans_11.pf2
└── icons/                 # Ícones de inicialização de SO
    ├── arch.png
    ├── linux.png / gnu-linux.png
    ├── windows.png
    └── uefi.png / uefi-firmware.png / recovery.png
```

## Instalação Rápida

Execute o instalador automatizado do Bulldoze:

```bash
chmod +x ../scripts/install-grub-theme.sh
../scripts/install-grub-theme.sh
```

O script irá:
1. Copiar todos os assets para `/boot/grub/themes/bulldoze/`.
2. Definir permissões de escrita para seu usuário no arquivo `background.png`, viabilizando sincronização automática sem senha de root.
3. Configurar `GRUB_THEME` e `GRUB_GFXMODE="2560x1440,auto"` em `/etc/default/grub`.
4. Executar `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
