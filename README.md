# VE03 — Arquitetura de Computadores

Verificação Especial 03 da disciplina de Arquitetura de Computadores (IME).

Tradução de dois algoritmos para a CPU **Excel-16** (CPU de 16 bits implementada
em planilha Excel — projeto [InkboxSoftware/excelCPU](https://github.com/InkboxSoftware/excelCPU)):

1. **Exemplo 1** — Cálculo da área de um retângulo (origem: MIPS ASM)
2. **Exemplo 2** — Conversão de pixels RGB para escala de cinza (origem: C)

> Aluno: Lucas Santiago

## Estrutura do repositório

```
VE03/
├── README.md
├── .gitignore
├── src/                Código-fonte (originais + traduções Excel-16 ASM)
│   ├── ex1.asm           MIPS original (referência)
│   ├── ex1.s             Tradução Excel-16 ASM
│   ├── ex2.c             C original (referência)
│   └── ex2.s             Tradução Excel-16 ASM
├── build/              ROMs compiladas (entregáveis)
│   ├── ROM-ex1.xlsx
│   └── ROM-ex2.xlsx
├── tools/              Toolchain Excel-16 (cópia do upstream)
│   ├── compileExcelASM16.py    Compilador Excel-ASM16
│   ├── CPU.xlsx                Simulador da CPU
│   ├── ROM.xlsx               ROM de trabalho (lida pela CPU)
│   ├── instructionSet.xlsx
│   ├── Excel-ASM16.xml
│   ├── run-clock.ps1          Script p/ automatizar os ciclos de clock (F9)
│   ├── LICENSE
│   └── samples/               Programas de exemplo do upstream
├── docs/               Relatório descritivo (entregável)
│   └── Relatorio-VE03.pdf
└── media/              Vídeos das simulações (entregáveis)
    ├── ex1-simulacao.mp4
    └── ex2-simulacao.mp4
```

## Pré-requisitos

- **Python 3.x** com a biblioteca `openpyxl` (para o compilador):
  ```powershell
  pip install openpyxl
  ```
- **Microsoft Excel** com **cálculo iterativo habilitado**:
  Arquivo → Opções → Fórmulas → marcar *"Habilitar cálculo iterativo"* e
  definir *"Iterações máximas"* = **1**. (A CPU usa fórmulas circulares no clock;
  sem isso ela não funciona.)

## Como compilar

A partir da raiz do projeto (PowerShell):

```powershell
# Compila o ex1 (cada programa gera sua própria ROM)
python tools\compileExcelASM16.py src\ex1.s build\ROM-ex1.xlsx

# Compila o ex2
python tools\compileExcelASM16.py src\ex2.s build\ROM-ex2.xlsx
```

## Como executar no simulador

1. Coloque a ROM desejada como a ROM de trabalho:
   ```powershell
   Copy-Item build\ROM-ex1.xlsx tools\ROM.xlsx -Force
   ```
2. Abra **`tools\ROM.xlsx`** primeiro, depois **`tools\CPU.xlsx`**
   (clique *"Atualizar"* se o Excel perguntar sobre os vínculos).
3. **READ ROM**: na CPU, célula `S2` = `1`, F9 (espere "Ready"), `S2` = `0`, F9.
   (copia a ROM para a RAM da CPU)
4. **RESET PC**: célula `F2` = `1`, F9, `F2` = `0`, F9.
5. Execute o clock: aperte **F9** várias vezes, ou use o script:
   ```powershell
   .\tools\run-clock.ps1 -Count 40     # ex1
   .\tools\run-clock.ps1 -Count 400    # ex2 (mais longo)
   ```

> ⚠ **Entrada de dados**: edite os valores na **`ROM.xlsx`** (nunca nas células
> de RAM da `CPU.xlsx`, que contêm fórmulas).

### Onde ver os resultados (na CPU.xlsx)

- **ex1**: célula `E140` = área do retângulo (`$0004`).
- **ex2**: células `A141`–`G141` = os 7 valores de cinza (`$0100`–`$0106`);
  mesmos valores no display em `A380`–`G380` (`$F000`+).

## Referências

- **CPU Excel-16:** https://github.com/InkboxSoftware/excelCPU
- **Simulador MIPS (validação do ex1):** https://shawnzhong.github.io/JsSpim/

## Licença

O toolchain em `tools/` é redistribuído sob a licença original (ver
[tools/LICENSE](tools/LICENSE)). O código em `src/` e a documentação são de
autoria do aluno.
