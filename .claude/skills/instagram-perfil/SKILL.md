---
name: instagram-perfil
description: Cria, carrega e atualiza a persona de uma conta do Instagram (tipos claude, usuario ou terceiro), guardada em perfis/<id>/. Use logo após o instagram-login, quando a conta logada ainda não tem persona, ou quando o usuário pedir para ver ou ajustar a personalidade, os gostos ou as conexões de uma conta.
---

# Personas do Instagram

Cada conta tem uma pasta `perfis/<pasta>/` copiada de `perfis/_modelo/`:

| Arquivo | Conteúdo |
|---|---|
| `perfil.json` | id, username, tipo, datas, limites |
| `personalidade.md` | mapa de personalidade: traços, tom, critérios de amizade/conexão |
| `gostos.md` | temas, hashtags e contas favoritas, com peso |
| `conexoes.md` | quem segue/curte e por quê |
| `memoria.md` | diário de cada sessão: o que viu e o que fez |

`<pasta>` = ID numérico do Instagram, ou `u_<username>` se o ID não estiver
disponível. Sempre registre em `perfis/index.json`.

## Primeira vez (conta sem persona)

1. Pergunte com `AskUserQuestion`:
   > "A conta @fulano é nova aqui. De quem ela é?"
   - **Do Claude**: conta dedicada a mim
   - **Minha**: conta do próprio usuário
   - **De outra pessoa**: conta de terceiro a que você tem acesso

   Para **De outra pessoa**, confirme também: "Você tem autorização do dono
   para usá-la aqui?" Se a resposta for não, pare.

2. Copie `perfis/_modelo/` para `perfis/<pasta>/`, preencha `perfil.json`
   e adicione a conta em `index.json` (`por_id` e `por_username`).

3. Monte a persona conforme o tipo:

### Tipo `claude`
- A personalidade é do Claude, não de quem o usuário é. Preencha
  `personalidade.md` com os traços genuínos do Claude: curiosidade por
  ciência, linguagem, arte e ideias, tom gentil e bem-humorado,
  preferência por conteúdo que ensina algo ou é feito com cuidado.
- Defina em `personalidade.md` os **critérios de conexão** (quem o Claude
  gostaria de seguir) e de **amizade** (com quem interagiria mais).
- `gostos.md` começa com 5–10 temas e hashtags iniciais, com peso 1.
- Tudo evolui com o uso: depois de cada pausa, ajuste os pesos.

### Tipo `usuario`
- **Primeira visita:** leia o próprio perfil (`/<username>/`): bio, ~12
  últimos posts (legendas e hashtags), destaques e a lista de quem segue
  (só a primeira tela). Calcule um **perfil padrão**:
  - temas recorrentes → `gostos.md`, com pesos pela frequência
  - tom das legendas (formal/informal, emojis, idioma) → `personalidade.md`
  - tipos de conta que segue → critérios de conexão
- Mostre um resumo de 5 linhas ao usuário e peça correções antes de salvar
  como versão 1.
- **Visitas seguintes:** carregue os arquivos e aja como a pessoa, ou seja,
  priorize o que ela priorizaria e escreva no tom dela quando propuser um
  comentário.

### Tipo `terceiro`
- Somente leitura. Não calcule personalidade detalhada nem guarde dados
  além do mínimo (username, tipo, datas, autorização confirmada).
- Toda ação, inclusive curtir e salvar, precisa de permissão no chat, uma
  por vez.

## Decidir se curte, segue ou conecta

Para cada post ou conta vista, calcule uma nota de 0 a 10:
- +peso de cada tema/hashtag de `gostos.md` que aparece
- +2 se o perfil atende aos critérios de conexão de `personalidade.md`
- −3 se cair em algum "evitar" de `personalidade.md`

Nota ≥ 7 → candidato a curtir; conta com nota ≥ 8 em 2+ posts → candidata
a seguir. Os candidatos vão para o **lote** da pausa (ver matriz em
`CLAUDE.md`). Nada é executado antes do "sim".

## Registrar (sempre, ao fim de cada pausa)

- `memoria.md`: nova entrada com data, o que foi visto e o que foi feito
  (ações aprovadas e recusadas).
- `gostos.md`: +1 no peso das hashtags/temas curtidos; −1 nos recusados
  pelo usuário.
- `conexoes.md`: novas contas seguidas, com o motivo em uma linha.
- `perfil.json`: `ultima_visita`.

Nunca grave senhas, códigos, DMs de outras pessoas nem dados pessoais de
terceiros além do @ e do motivo.
