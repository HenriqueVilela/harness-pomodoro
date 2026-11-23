# Intervalo — harness de pausas

Estrutura de skills do Claude Code para "respirar" entre prompts pesados,
começando pelo Instagram, com uma persona por conta.

```
.
├── CLAUDE.md                         # regras, tipos de conta, matriz de permissões
├── README.md
├── intervalo/
│   ├── catalogo.json                 # skills de pausa, tempos e frequência-alvo
│   └── estado.json                   # último intervalo + histórico de sorteios
├── scripts/
│   └── escolher-intervalo.ps1        # sorteio ponderado
├── perfis/
│   ├── index.json                    # username / ID do Instagram -> pasta
│   ├── _modelo/                      # copiado para cada conta nova
│   │   ├── perfil.json
│   │   ├── personalidade.md          # mapa de personalidade + critérios de conexão
│   │   ├── gostos.md                 # temas, hashtags, contas favoritas (com peso)
│   │   ├── conexoes.md
│   │   └── memoria.md                # diário das sessões
│   └── <id-instagram>/               # uma pasta por conta (criada no 1º login)
└── .claude/skills/
    ├── intervalo/                    # ponto de entrada: sorteia a pausa
    ├── instagram-login/              # login + identificação da conta
    ├── instagram-perfil/             # cria/carrega a persona
    ├── instagram-pausa/              # a pausa em si
    ├── instagram-doomscroll/         # rolar Reels com match de gostos
    └── _template/
```

## Fluxo

0. `/intervalo`: sorteia qual pausa fazer (doomscroll é a mais comum) e
   segue para ela.
1. `/instagram-login`: abre o Instagram. Se não houver conta logada, você
   entra pelo painel do navegador.
2. A conta é identificada pelo ID/@ e procurada em `perfis/index.json`.
   - **Conhecida:** a persona é carregada ("bem-vindo de volta").
   - **Nova:** o Claude pergunta se a conta é **dele**, **sua** ou **de
     outra pessoa** e monta a persona.
3. `/instagram-pausa`: navega, pontua os posts pela persona, propõe as ações
   (curtidas e follows em lote, com um "sim") e registra tudo na memória.
4. `/instagram-doomscroll`: rola de 5 a 15 Reels e classifica cada um como
   Gostei (curtir), Match (curtir + seguir) ou Match certeiro (propor
   compartilhar).

Veja a matriz de permissões completa em `CLAUDE.md`.
