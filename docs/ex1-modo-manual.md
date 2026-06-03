# Ex1 — Interação do usuário via Modo Manual

Este documento descreve como reproduzir a "entrada do usuário" do programa MIPS
original (`syscall 5` — ler inteiro do teclado) na CPU Excel-16, que **não possui
dispositivo de entrada por hardware**.

## 1. Contexto: a Excel-16 não tem teclado

O programa MIPS original lê `width` e `height` da entrada padrão:

```mips
addi $v0, $0, 5     # syscall 5 = ler inteiro
syscall             # valor lido fica em $v0
add  $8, $0, $v0    # copia para registrador
```

A CPU Excel-16 **não tem equivalente** a esse `syscall`: ela possui saída
(o display memory-mapped em `$F000`) mas **nenhum dispositivo de entrada**.
A inspeção da planilha `CPU.xlsx` confirma que os únicos pontos de I/O são o
display (saída) e o **modo manual** (entrada em runtime).

O **modo manual** é, na prática, o mecanismo de entrada do usuário da máquina:
com a chave `J2 = 1`, a CPU para de buscar instruções da RAM e passa a executar
a instrução de 32 bits que o usuário digita na célula `D8`. Usamos isso para o
usuário **injetar os dados do retângulo em runtime**, exatamente como o MIPS faz
após o `syscall`: o valor digitado é gravado na memória, e o programa principal
o lê de lá.

## 2. O programa principal (lê da memória, igual ao MIPS)

O `src/ex1.s` não muda — ele lê `width`/`height` da memória e calcula a área:

```asm
.DATA
WIDTH  = #0      ; $0002  (preenchido pelo usuario em runtime)
HEIGHT = #0      ; $0003  (preenchido pelo usuario em runtime)
AREA   = #0      ; $0004  (saida: low16)
AREAHI = #0      ; $0005  (saida: high16)
.CODE
LOAD R1 WIDTH    ; R1 <- MEM[$0002]
LOAD R2 HEIGHT   ; R2 <- MEM[$0003]
CLC
MULT R1 R2       ; R1 = low16(W*H) ; R2 = high16
LOAD R0 #4
STORE R1 R0      ; MEM[$0004] <- area low16
LOAD R0 #5
STORE R2 R0      ; MEM[$0005] <- area high16
END:
JMP END
```

## 3. Instruções de injeção (digitar em D8)

Cada instrução abaixo é um valor de 32 bits (8 dígitos hexadecimais).
A palavra alta (4 primeiros dígitos) é o opcode + registradores; a palavra baixa
(4 últimos) é o valor imediato. Os códigos foram conferidos com o compilador.

**Para width = 5 e height = 3:**

| Passo | Instrução       | Significado                | Digitar em `D8` |
|-------|-----------------|----------------------------|-----------------|
| 1     | `LOAD R0 #2`    | R0 = endereço de WIDTH     | `05000002`      |
| 2     | `LOAD R1 #5`    | R1 = valor de width (5)    | `05100005`      |
| 3     | `STORE R1 R0`   | MEM[$0002] = 5             | `07100000`      |
| 4     | `LOAD R0 #3`    | R0 = endereço de HEIGHT    | `05000003`      |
| 5     | `LOAD R1 #3`    | R1 = valor de height (3)   | `05100003`      |
| 6     | `STORE R1 R0`   | MEM[$0003] = 3             | `07100000`      |

### Como mudar os valores de entrada

- **width**: troque os 4 últimos dígitos do **passo 2**. Ex.: width=10 → `0510000A`.
- **height**: troque os 4 últimos dígitos do **passo 5**. Ex.: height=7 → `05100007`.
- Os endereços (passos 1 e 4) **não mudam** (`...0002` e `...0003`).

> Tabela rápida de conversão decimal → hex (4 dígitos):
> `1→0001  2→0002  5→0005  10→000A  16→0010  100→0064  255→00FF  1000→03E8`

## 4. Sequência completa de operação

### Setup
1. Abra `tools/ROM.xlsx` (com o ex1 compilado), depois `tools/CPU.xlsx`
   → clique **"Atualizar"** nos vínculos.
2. **READ ROM**: `S2 = 1`, F9 (espere "Ready"), `S2 = 0`, F9.
   (carrega o programa na RAM)
3. **RESET PC**: `F2 = 1`, F9, `F2 = 0`, F9.

### Entrada do usuário (modo manual)
4. Ligue o modo manual: `J2 = 1`.
5. Para cada uma das 6 instruções da tabela:
   - digite o código de 8 dígitos em `D8`;
   - aperte **F9 de 3 a 4 vezes** (espere "Ready" entre cada);
   - confirme o efeito olhando os registradores/RAM (ver §5).
6. Desligue o modo manual: `J2 = 0`.

### Execução
7. **RESET PC** de novo: `F2 = 1`, F9, `F2 = 0`, F9.
   (o modo manual avançou o PC; isto traz o PC de volta a 0)
8. Aperte **F9 ~40 vezes** (ou use `tools/run-clock.ps1 -Count 40`).
9. Leia o resultado: célula **E140** (`$0004`) = área. Para 5×3 deve ser **15**.

## 5. Onde observar (para confirmar e para o vídeo)

| O quê | Onde (na CPU.xlsx) |
|---|---|
| Registrador R0 | célula **C53** |
| Registrador R1 | célula **C54** |
| Registrador R2 | célula **C55** |
| WIDTH em RAM (`$0002`) | célula **C140** |
| HEIGHT em RAM (`$0003`) | célula **D140** |
| AREA em RAM (`$0004`) | célula **E140** |
| PC atual (hex) | célula **B8** |

Depois do passo 3 da injeção, **C140 deve mostrar 5**; depois do passo 6,
**D140 deve mostrar 3**. Isso prova que o usuário inseriu os dados em runtime —
é a "interação do usuário" pedida no enunciado.

## 6. Observações para o relatório

- O `syscall 5` do MIPS (ler inteiro do teclado) **não tem equivalente direto**
  na Excel-16, porque a arquitetura não possui dispositivo de entrada.
- A interação do usuário foi implementada via **modo manual** — o mecanismo de
  entrada em runtime da CPU — no qual o usuário digita instruções que gravam os
  dados na memória.
- O fluxo resultante é fiel ao MIPS: o dado fornecido pelo usuário é escrito na
  memória e, em seguida, lido pelo programa principal para o cálculo.
- Diferença prática: no MIPS o usuário digita um número; na Excel-16 o usuário
  digita a instrução de máquina que carrega esse número — pois a única "entrada"
  da CPU é o barramento de instruções do modo manual.
