# Roteiro de gravação — Ex1 (área do retângulo)

Vídeo de ~2 min. Entrada do usuário feita **editando a ROM** (abordagem mais
simples e direta). Faça o setup *antes* de começar a gravar.

---

## Antes de gravar (off-camera)
- Habilite o cálculo iterativo no Excel (Arquivo → Opções → Fórmulas →
  "Habilitar cálculo iterativo", máx. 1 iteração).
- Confirme que `tools/ROM.xlsx` tem o ex1 compilado.
- Deixe a janela do Excel maximizada.

---

## Mapa das células (cola na frente)

**Na ROM.xlsx (entrada):**
| Célula | É o quê |
|---|---|
| **C1** | width (largura) — endereço `$0002` |
| **D1** | height (altura) — endereço `$0003` |

**Na CPU.xlsx (controle e saída):**
| Célula | É o quê |
|---|---|
| `S2` | READ ROM |
| `F2` | RESET PC |
| `B8` | PC atual (hex) |
| `C140` / `D140` | width / height carregados na RAM |
| **E140** | **resultado (área), endereço `$0004`** |
| `F140` | high16 da área (overflow), endereço `$0005` |

---

## Cena 1 — Apresentação (~20s)
**Mostra:** `src/ex1.asm` (MIPS) e `src/ex1.s` (Excel-16).

**Narra:**
> "Exemplo 1: calcula a área de um retângulo. O original em MIPS lê largura e
> altura do teclado e imprime a área. Traduzi para Excel-16, onde a entrada é
> fornecida pela ROM e o cálculo usa a instrução MULT."

---

## Cena 2 — Entrada do usuário (~25s)
**Mostra:** a `ROM.xlsx`. Edita **C1 = 5** (width) e **D1 = 3** (height). Salva (`Ctrl+S`).

**Narra:**
> "Os dados de entrada ficam na ROM: na célula C1 coloco a largura, 5, e em D1
> a altura, 3. Salvo a ROM."

---

## Cena 3 — Carregar na CPU (~20s)
**Mostra:** vai pra `CPU.xlsx` ("Atualizar" se pedir). Faz READ ROM:
`S2 = 1`, F9 (espera "Ready"), `S2 = 0`, F9. Aponta **C140 = 5** e **D140 = 3**.

**Narra:**
> "Carrego a ROM na memória da CPU com o botão READ ROM. Vejam que a largura 5
> e a altura 3 aparecem na memória, nos endereços $0002 e $0003."

---

## Cena 4 — Execução (~30s)
**Mostra:** RESET PC (`F2 = 1`, F9, `F2 = 0`, F9). Depois aperta F9 várias vezes
(ou `tools/run-clock.ps1 -Count 40`). Aponta o PC (**B8**) avançando.

**Narra:**
> "Reseto o contador de programa e deixo a CPU executar. Ela lê a largura, lê a
> altura, multiplica com MULT e grava o resultado na memória."

---

## Cena 5 — Resultado (~15s)
**Mostra:** célula **E140 = 15**.

**Narra:**
> "O resultado: 5 vezes 3 igual a 15, no endereço $0004. Confere com o esperado
> no simulador MIPS."

---

## Cena 6 — Segundo caso (~20s, recomendado)
**Mostra:** volta pra ROM, muda **C1 = 10** e **D1 = 10**, salva, READ ROM,
RESET PC, executa. Mostra **E140 = 100**.

**Narra:**
> "Confirmo com outro caso: 10 por 10 dá 100. O programa funciona para qualquer
> entrada."

> 💡 Bônus opcional — overflow de 16 bits: teste **1000 × 1000**. O resultado
> real, 1.000.000, não cabe em 16 bits, então E140 mostra `16960` (`$4240`) e
> F140 mostra `15` (`$000F`). Juntos formam `$F4240` = 1.000.000 — mostrando que
> tratamos o produto de 32 bits em duas palavras (low + high), igual o MIPS faz
> com `mflo`/`mfhi`.

---

## Sequência rápida (resumo)
1. ROM: C1 = width, D1 = height → salvar
2. CPU: `S2=1` F9 → `S2=0` F9 (READ ROM)
3. `F2=1` F9 → `F2=0` F9 (RESET PC)
4. F9 ~40x
5. Ler **E140** (resultado)
