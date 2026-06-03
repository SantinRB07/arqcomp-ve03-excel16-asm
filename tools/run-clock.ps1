# run-clock.ps1
# Envia teclas F9 automaticamente para o Excel, simulando ciclos de clock
# da CPU Excel-16. Util para evitar apertar F9 manualmente N vezes.
#
# USO:
#   .\run-clock.ps1                       # padrao: 50 F9, 1500ms entre eles
#   .\run-clock.ps1 -Count 100            # 100 ciclos
#   .\run-clock.ps1 -Count 30 -DelayMs 2000  # 30 ciclos, 2s entre eles
#
# COMO USAR:
#   1. Abra o CPU.xlsx no Excel e prepare a simulacao (READ ROM, RESET PC)
#   2. Deixe a janela do Excel em foco
#   3. Rode o script no PowerShell
#   4. Em 3 segundos, alterne para o Excel (Alt+Tab) - depois disso o
#      script envia F9 automaticamente.
#
# AVISO: nao mexa em outras janelas durante o envio - as teclas vao
# para o app que estiver em foco.

param(
    [int]$Count = 50,
    [int]$DelayMs = 1500,
    [int]$StartDelaySec = 3
)

Add-Type -AssemblyName System.Windows.Forms

Write-Host ""
Write-Host "==> Vou enviar $Count F9 com $DelayMs ms entre eles." -ForegroundColor Cyan
Write-Host "==> Voce tem $StartDelaySec segundos para alternar para o Excel (Alt+Tab)." -ForegroundColor Yellow
Write-Host "==> Para abortar a qualquer momento: Ctrl+C neste terminal." -ForegroundColor Yellow
Write-Host ""

# Contagem regressiva
for ($i = $StartDelaySec; $i -gt 0; $i--) {
    Write-Host "  $i..." -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host " GO!" -ForegroundColor Green
Write-Host ""

# Envia F9 N vezes
for ($i = 1; $i -le $Count; $i++) {
    [System.Windows.Forms.SendKeys]::SendWait('{F9}')
    Write-Host ("  F9 [{0,3}/{1}]" -f $i, $Count)
    Start-Sleep -Milliseconds $DelayMs
}

Write-Host ""
Write-Host "==> Pronto. $Count ciclos enviados." -ForegroundColor Green
