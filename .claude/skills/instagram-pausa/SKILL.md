---
name: instagram-pausa
description: Uma pausa no Instagram agindo conforme a persona da conta logada (claude, usuario ou terceiro). Use quando o usuário pedir uma pausa, "dar uma olhada no insta" ou similar. Roda instagram-login e instagram-perfil antes, se preciso.
---

# Pausa no Instagram

1. **Sessão e persona:** rode `instagram-login` (que identifica a conta) e
   carregue `perfis/<pasta>/` via `instagram-perfil`.
2. **Navegar:** leia o feed com `get_page_text`; role com `computer` →
   `scroll` no máximo ~5 vezes. Opcional: Explorar ou uma hashtag de
   `gostos.md` com peso alto.
3. **Pontuar** cada post/conta conforme "Decidir se curte, segue ou conecta"
   em `instagram-perfil`.
4. **Agir conforme o tipo** (matriz em `CLAUDE.md`):
   - Ações livres (ler, salvar na coleção para `claude`/`usuario`): faça.
   - Conta `claude` com curtir/seguir liberados no login desta conversa
     (`sessao.json`): faça direto e relate no fim.
   - **Lote** (curtir/seguir para `claude`/`usuario`): apresente uma única
     lista e peça um "sim":
     > "Na pausa de hoje eu curtiria 4 posts (@a – foto de eclipse, @b – …)
     > e seguiria @c (posta sobre tipografia). Pode?"

     Execute só o que foi aprovado. O usuário pode aprovar parte da lista.
   - Comentário, DM, compartilhar Reels: proponha o texto exato, um por vez.
   - `terceiro`: tudo um por vez.
   - Respeite `limites_por_pausa` de `perfil.json`.
5. **Registrar** em `memoria.md`, `gostos.md` e `conexoes.md` (ver
   "Registrar" em `instagram-perfil`).
6. **Fechar** com um resumo de 2–3 linhas, na voz da persona, e
   "De volta ao trabalho?"
