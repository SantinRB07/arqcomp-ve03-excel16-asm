# VE03 — Arquitetura de Computadores

Verificação Especial 03 da disciplina de Arquitetura de Computadores (IME).

Tradução de dois algoritmos para a CPU **Excel-16** (CPU de 16 bits implementada
em planilha Excel — projeto [InkboxSoftware/excelCPU](https://github.com/InkboxSoftware/excelCPU)):

1. **Exemplo 1** — Cálculo da área de um retângulo (origem: MIPS ASM)
2. **Exemplo 2** — Conversão de pixels RGB para escala de cinza (origem: C)

> Aluno: Lucas Santiago
> Entrega: 11/05/2026

## Estrutura do repositório

```
VE03/
├── src/                Código-fonte (originais + traduções Excel-16 ASM)
│   ├── ex1.asm           MIPS original (referência)
│   ├── ex1.s             Tradução Excel-16 ASM
│   ├── ex2.c             C original (referência)
│   └── ex2.s             Tradução Excel-16 ASM
├── build/              ROMs compiladas
│   ├── ROM-ex1.xlsx
│   └── ROM-ex2.xlsx
├── tools/              Toolchain Excel-16 (cópia do upstream)
│   ├── compileExcelASM16.py
│   ├── CPU.xlsx
│   ├── ROM.xlsx              Template vazio
│   ├── instructionSet.xlsx
│   ├── Excel-ASM16.xml
│   └── LICENSE
├── docs/               Relatório descritivo
│   └── Relatorio-VE03.pdf
└── media/              Vídeos das simulações
    ├── ex1-simulacao.mp4
    └── ex2-simulacao.mp4
```

## Pré-requisitos

- Python 3.x com a biblioteca `openpyxl`
  ```sh
  pip install openpyxl
  ```
- Microsoft Excel (para abrir `CPU.xlsx` e simular a execução)

## Como compilar e executar

A partir da raiz do projeto:

```sh
# 1. Copiar template ROM para build/
cp tools/ROM.xlsx build/ROM-ex1.xlsx

# 2. Compilar o assembly Excel-16
python tools/compileExcelASM16.py src/ex1.s build/ROM-ex1.xlsx

# 3. Abrir CPU.xlsx no Excel e importar a ROM gerada (seguir instruções
#    do README upstream do excelCPU)
```

Repetir o processo trocando `ex1` por `ex2`.

## Referências

- **CPU Excel-16:** https://github.com/InkboxSoftware/excelCPU
- **Simulador MIPS (validação ex1):** https://shawnzhong.github.io/JsSpim/

## Licença

O toolchain em `tools/` é redistribuído sob a licença original (ver `tools/LICENSE`).
O código em `src/` e a documentação são de autoria do aluno.
