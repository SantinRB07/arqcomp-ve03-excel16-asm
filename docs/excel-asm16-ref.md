# Excel-ASM16 — Referência da Linguagem

Documento técnico de referência para a CPU **Excel-16** (projeto
[InkboxSoftware/excelCPU](https://github.com/InkboxSoftware/excelCPU)).
Compilado a partir do `instructionSet.xlsx`, do `compileExcelASM16.py` e dos
sample programs (`bouncingBall.s`, `cycle.s`).

---

## 1. Arquitetura

| Recurso | Detalhe |
|---|---|
| Largura da palavra | **16 bits** |
| Registradores | **16 GPRs:** `R0`–`R15` |
| RAM | 64 K words (endereços `$0000`–`$FFFF`) |
| Display | Framebuffer memory-mapped em `$F000`–`$FFFF` (4 K words) |
| Flags | **C** (carry) e **Z** (zero) |
| ROM/programa | Compilada na planilha `ROM.xlsx` (256×256 = 65 536 words) |

---

## 2. Conjunto de instruções (25 opcodes, `0x00`–`0x19`)

### 2.1 Controle de fluxo (todas usam **2 words**: opcode + endereço)

| Mnem. | Forma | Efeito |
|---|---|---|
| `JMP` | `JMP addr` | `PC ← addr` |
| `JEQ` | `JEQ addr` | se `Z = 1`, `PC ← addr` |
| `JLT` | `JLT addr` | se `C = 0`, `PC ← addr` (less-than **sem sinal**) |
| `JGE` | `JGE addr` | se `C = 1` ou `Z = 1`, `PC ← addr` (≥ **sem sinal**) |
| `NOP` | `NOP` | nada |

### 2.2 Memória

| Mnem. | Forma | Efeito | Tamanho |
|---|---|---|---|
| `LOAD` | `LOAD Ra, var` / `LOAD Ra, @addr` | `Ra ← MEM[addr]` | 2 words |
| `LOAD` | `LOAD Ra, #imd` / `LOAD Ra, $hex` | `Ra ← imd` | 2 words |
| `LOAD` | `LOAD Ra, Rb` | `Ra ← MEM[Rb]` | 1 word |
| `STORE` | `STORE Ra, var` / `STORE Ra, @addr` | `MEM[addr] ← Ra` | 2 words |
| `STORE` | `STORE Ra, Rb` | `MEM[Rb] ← Ra` | 1 word |
| `TRAN` | `TRAN Ra, Rb` | `Rb ← Ra` (**destino é o 2º!**) | 1 word |

### 2.3 ALU aritmética

| Mnem. | Forma | Efeito | Observação |
|---|---|---|---|
| `ADD` | `ADD Ra, Rb` | `Ra ← Ra + Rb + C` | ⚠ usa carry — `CLC` antes de soma "limpa" |
| `SUB` | `SUB Ra, Rb` | `Ra ← Ra − Rb − C` | ⚠ idem (borrow). `CLC` antes |
| `MULT` | `MULT Ra, Rb` | `Ra:Rb ← Ra * Rb` (Ra=low16, Rb=high16) | ⚠ **destrói Rb** |
| `DIV` | `DIV Ra, Rb` | `Ra ← Ra / Rb`, `Rb ← Ra mod Rb` | ⚠ **destrói Rb** |
| `INC` | `INC Ra` | `Ra ← Ra + 1` | flags **não** afetadas |
| `DEC` | `DEC Ra` | `Ra ← Ra − 1` | flags **não** afetadas |

### 2.4 Lógica e bit-shift

| Mnem. | Forma | Efeito |
|---|---|---|
| `AND` | `AND Ra, Rb` | `Ra ← Ra & Rb` |
| `OR`  | `OR  Ra, Rb` | `Ra ← Ra \| Rb` |
| `XOR` | `XOR Ra, Rb` | `Ra ← Ra ^ Rb` |
| `NOT` | `NOT Ra` | `Ra ← ~Ra` |
| `ROL` | `ROL Ra, #n` | rotaciona Ra à esquerda `n` vezes (imediato 4-bit, máx 15) |
| `ROR` | `ROR Ra, #n` | rotaciona Ra à direita `n` vezes |

> ⚠ **`ROL`/`ROR` é rotação, não shift.** Para shift lógico `>> 8`, é preciso
> `ROR Ra, #8` seguido de `AND Ra, mask` com `mask = $00FF` para zerar os bits
> que voltaram pelo topo.

### 2.5 Comparação e flags

| Mnem. | Forma | Efeito |
|---|---|---|
| `CMP` | `CMP Ra, Rb` | calcula `Ra − Rb`, atualiza só `C` e `Z` |
| `CLC` | `CLC` | `C ← 0` |
| `STC` | `STC` | `C ← 1` |

---

## 3. Sintaxe de operandos

| Notação | Significado | Exemplo |
|---|---|---|
| `R0`–`R15` | Registrador | `R8` |
| `#dec` | Imediato decimal (0–65535) | `#100` |
| `$hex` | Imediato hexadecimal | `$FF`, `$1A2B` |
| `@hex` | Endereço de memória literal (hex) | `@1000` |
| `nome` | Label/variável (resolve em endereço) | `loop`, `width` |

O compilador faz **uppercase em tudo** (`line.upper()`), então labels e
variáveis são case-insensitive.

---

## 4. Diretivas

| Diretiva | Uso |
|---|---|
| `nome = valor` | Define **variável** (1 word de RAM). Tem que vir antes do `.CODE` |
| `.DATA` | Início da seção de dados |
| `.CODE` | Início da seção de código. **Insere automaticamente um `JMP`** no endereço 0 que pula a área de dados |
| `ORG addr` | Avança o ponteiro de montagem até `addr` preenchendo com zeros |
| `.INC "arquivo.bin"` | Inclui um binário literal (cada par de bytes vira 1 word) |
| `label:` | Marca endereço com um label |
| `; comentário` | Comentário até o fim da linha |

---

## 5. I/O

### 5.1 Display (saída)

- **Framebuffer**: `$F000`–`$FFFF` (4 096 words = 4 KB).
- Cada pixel = 1 word de cor (formato 4-4-4-4 RGBA, baseado nos exemplos).
- **Escrever em qualquer endereço a partir de `$F000` pinta um pixel** na tela.
- Layout exato (resolução vs. stride) varia entre os samples; tipicamente
  64×64 ou 128×32 pixels com stride de 32 ou 128 words por linha.

Exemplo (extraído de `cycle.s`):
```asm
.DATA
  SCREEN = $F000
.CODE
  LOAD  R0, SCREEN          ; R0 = $F000 (ponteiro do framebuffer)
  LOAD  R1, $0123           ; cor
LOOP:
  STORE R1, R0              ; pinta pixel
  INC   R0                  ; próximo pixel
  JMP   LOOP
```

### 5.2 Entrada (não há em runtime)

A Excel-16 **não tem** instruções de entrada nem teclado. Como a CPU é uma
planilha, a "entrada do usuário" funciona assim:

1. Programa define variáveis em `.DATA` que serão lidas (ex: `width`, `height`).
2. **Antes de rodar**, o usuário abre **`ROM.xlsx`** (não `CPU.xlsx`!) e edita
   diretamente as células correspondentes a essas variáveis. As células da
   `ROM.xlsx` contêm valores estáticos (números puros) nas posições do `.DATA`,
   então podem ser editadas à mão sem problema.
3. Salva a `ROM.xlsx` (mantém aberta), abre a `CPU.xlsx`, e aciona o botão
   **READ ROM** (célula `S2`). Isso copia o conteúdo da ROM para a RAM da CPU.
4. Roda a simulação (F9 a cada ciclo de clock) — o programa lê os valores
   carregados.
5. O resultado é gravado em outras células de RAM e o usuário observa o valor
   diretamente na `CPU.xlsx`.

> ⚠ **NÃO edite as células de RAM diretamente na `CPU.xlsx`** — todas elas têm
> fórmulas grandes (`=IF($P$133, [1]ROM!A1, IF($D$133, 0, ...))`) que
> implementam a lógica de READ ROM / RESET / STORE. Sobrescrever uma célula com
> um valor literal destrói a fórmula e a CPU para de funcionar para aquele
> endereço.

---

## 6. Esqueleto típico de programa

```asm
.DATA
  width   = #0
  height  = #0
  area    = #0

.CODE
  ; .CODE injeta automaticamente um JMP para cá pulando a área de dados

  LOAD  R1, width       ; R1 ← MEM[width]
  LOAD  R2, height      ; R2 ← MEM[height]
  CLC                   ; precaução: zerar carry antes de MULT
  MULT  R1, R2          ; R1 = low(width*height), R2 = high(...)
  STORE R1, area        ; MEM[area] ← R1

end:
  JMP end               ; loop infinito (CPU não tem HALT)
```

---

## 7. Pegadinhas e diferenças críticas vs. MIPS

| MIPS | Excel-16 |
|---|---|
| 32-bit, 32 registradores `$0..$31` | 16-bit, 16 registradores `R0..R15` |
| 3 operandos (`add $1, $2, $3`) | 2 operandos, destino sobrescrito (`ADD R1, R2`) |
| `addi`/`ori` com imediato | `LOAD R, #imd` (cada imediato custa 2 words) |
| `mflo`/`mfhi` para `mult` | `MULT` já coloca low em Ra e high em Rb (clobber!) |
| `syscall` para I/O | Sem I/O em runtime — display memory-mapped, sem entrada |
| `bne`/`beq` com 2 operandos | `CMP R, R` + `JEQ`/`JLT`/`JGE` (separado) |
| Add não afeta carry implicitamente | `ADD`/`SUB` somam/subtraem **com** carry — `CLC` antes |
| Shift `sll`/`srl` (lógico) | `ROL`/`ROR` (rotação) — precisa AND para mascarar |
| Direção do `move`: `move $dst, $src` | `TRAN Rsrc, Rdst` — destino é o **segundo** |

---

## 8. Compilação

```sh
python compileExcelASM16.py programa.s ROM.xlsx
```

- 1º arg: arquivo `.s` (assembly Excel-16)
- 2º arg: planilha de saída (template `ROM.xlsx` é sobrescrito com o binário)
- A `CPU.xlsx` lê a `ROM.xlsx` por referência externa, então basta substituir
  o arquivo e abrir/atualizar o `CPU.xlsx`.
