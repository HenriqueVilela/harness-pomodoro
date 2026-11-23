---
name: intervalo
description: Ponto de entrada de toda pausa. Escolhe qual skill de intervalo rodar (doomscroll, pausa no feed…) a partir do tempo sem relaxar e da frequência com que cada uma vem sendo usada, e então a executa. Use sempre que for ter um intervalo, ou quando o usuário disser "intervalo", "relaxa", "faz uma pausa" ou "vai descansar".
---

# Intervalo: escolher e rodar a pausa

## 1. Sortear
Rode, na raiz do harness:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/escolher-intervalo.ps1
```
O script lê `intervalo/catalogo.json` e `intervalo/estado.json`, mostra a
tabela de pesos e termina com:
```
MINUTOS_SEM_RELAXAR=37
CHANCE instagram-doomscroll=78%
CHANCE instagram-pausa=22%
CEDO=false
ESCOLHA=instagram-doomscroll
REGISTRADO=true
```
O sorteio já fica registrado no histórico.

Para ver as chances sem gravar nada, use `-Simular`.

## 2. Anunciar em uma linha
> "Faz 37 min sem relaxar. Sorteei **doomscroll** (78% de chance). Bora."

Se `CEDO=true` (menos de 5 min desde o último intervalo), diga isso e
pergunte se quer mesmo assim. O padrão é o doomscroll.

## 3. Executar
Siga a skill escolhida (`ESCOLHA`). Todas as skills do Instagram passam
antes por `instagram-login` → `instagram-perfil`.

## Como o sorteio funciona
Para cada skill do catálogo:

- **Elegível** se os minutos sem relaxar ≥ `tempo_minimo_min`.
  O doomscroll precisa de só **5 min**; a pausa no feed, de 45.
- **Fator de tempo:** máximo quando o tempo sem relaxar está perto de
  `tempo_ideal_min` (doomscroll 25 min, pausa 90 min). Quanto mais tempo
  sem relaxar, mais sobem as pausas longas.
- **Fator de frequência:** compara a fatia real dos últimos 20 intervalos
  com a `frequencia_alvo` (doomscroll 65%). Skill usada abaixo do alvo
  ganha peso (até 2×); usada acima, perde (até 0,5×).
- **Peso** = `frequencia_alvo` × fator de frequência × fator de tempo.
  O sorteio é proporcional aos pesos.

## Adicionar uma skill de intervalo nova
Inclua um item em `intervalo/catalogo.json` com `skill`, `descricao`,
`tempo_minimo_min`, `tempo_ideal_min`, `frequencia_alvo` e `duracao_min`,
e reequilibre as `frequencia_alvo` para somarem ~1.
