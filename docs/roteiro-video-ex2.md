# Roteiro de gravação — Ex2 (RGB → escala de cinza)

Vídeo de ~2-3 min. O array de pixels é fixo no programa (no C original também é
`const`), então **não há entrada do usuário** — o foco é mostrar a conversão e
os 7 resultados.

---

## Antes de gravar (off-camera)
- Cálculo iterativo habilitado no Excel.
- `tools/ROM.xlsx` deve ter o **ex2** compilado (não o ex1!).
- Janela do Excel maximizada.

---

## Saídas esperadas

| Pixel | Valor (0xRRGGBB) | R | G | B | gray = (R+G+B)/3 |
|---|---|---|---|---|---|
| 0 | 0x00010000 | 1 | 0 | 0 | **0** |
| 1 | 0x00010101 | 1 | 1 | 1 | **1** |
| 2 | 0x00000006 | 0 | 0 | 6 | **2** |
| 3 | 0x00003333 | 0 | 51 | 51 | **34** |
| 4 | 0x0000030C | 0 | 3 | 12 | **5** |
| 5 | 0x00700853 | 112 | 8 | 83 | **67** |
| 6 | 0x00294999 | 41 | 73 | 153 | **89** |

→ Resultado final: **0, 1, 2, 34, 5, 67, 89**

> Confira rodando o `ex2.c` original (compilar com gcc e executar) — deve
> imprimir exatamente esses 7 números.

---

## Mapa das células de saída (CPU.xlsx)

**Resultados em RAM (`$0100`–`$0106`):**
| gray | Célula |
|---|---|
| gray[0] | **A141** |
| gray[1] | **B141** |
| gray[2] | **C141** |
| gray[3] | **D141** |
| gray[4] | **E141** |
| gray[5] | **F141** |
| gray[6] | **G141** |

**Mesmos valores como pixels no display (`$F000`–`$F006`):** células **A380–G380**.

Controle: `S2` (READ ROM), `F2` (RESET PC), `B8` (PC atual).

---

## Cena 1 — Apresentação (~30s)
**Mostra:** `src/ex2.c` (C original) e `src/ex2.s` (Excel-16).

**Narra:**
> "Exemplo 2: converte pixels RGB para escala de cinza, fazendo a média dos três
> canais. O desafio é que cada pixel tem 24 bits e a CPU é de 16 bits — então
> guardo cada pixel em duas palavras: uma com o vermelho, outra com verde e azul.
> O programa percorre o array até o sentinela -1, extrai R, G e B com máscaras e
> rotação de bits, e divide a soma por 3 com a instrução DIV."

---

## Cena 2 — Carregar o programa (~20s)
**Mostra:** `CPU.xlsx` ("Atualizar"). READ ROM: `S2=1` F9 (Ready), `S2=0` F9.
Aponta a área de dados (linha 140) com os 7 pixels carregados.

**Narra:**
> "Carrego o programa. Na memória estão os 7 pixels e o sentinela $FFFF que marca
> o fim do array."

---

## Cena 3 — Execução (~40s)
**Mostra:** RESET PC (`F2=1` F9, `F2=0` F9). Roda o clock:
`tools/run-clock.ps1 -Count 400` (ou aperta F9 bastante). Aponta o PC (**B8**)
girando no loop, e os resultados aparecendo um a um em **A141, B141, ...**

**Narra:**
> "Deixo a CPU executar. Observem o contador de programa repetindo o loop, uma
> vez para cada pixel, e os valores de cinza aparecendo na memória, um por um."

> ⚠ O ex2 tem 7 iterações e é bem mais longo que o ex1 — são várias centenas de
> ciclos de clock. Use o script `run-clock.ps1` com `-Count` alto (≈400). Se
> preferir, acelere essa parte do vídeo na edição.

---

## Cena 4 — Resultados em RAM (~20s)
**Mostra:** as células **A141–G141** com os valores **0, 1, 2, 34, 5, 67, 89**.

**Narra:**
> "Os sete valores de cinza: 0, 1, 2, 34, 5, 67, 89 — exatamente o que o programa
> em C produz."

---

## Cena 5 — Resultados no display (~20s, bônus visual)
**Mostra:** rola até a área do display (linha 380), células **A380–G380** com os
mesmos valores. Se a aba do display renderizar como imagem, mostra os tons.

**Narra:**
> "Os mesmos valores também foram escritos no display da CPU, no endereço $F000,
> como saída visual."

---

## Cena 6 — Comparação com o C (~20s, recomendado)
**Mostra:** o terminal rodando o `ex2.c` compilado, imprimindo `0 1 2 34 5 67 89`.

**Narra:**
> "Comparando com a execução do programa original em C: os resultados são
> idênticos. A tradução está correta."

---

## Sequência rápida (resumo)
1. ROM = ex2 (já compilada)
2. CPU: `S2=1` F9 → `S2=0` F9 (READ ROM)
3. `F2=1` F9 → `F2=0` F9 (RESET PC)
4. `run-clock.ps1 -Count 400` (ou F9 várias centenas de vezes)
5. Ler **A141–G141** = `0, 1, 2, 34, 5, 67, 89`
