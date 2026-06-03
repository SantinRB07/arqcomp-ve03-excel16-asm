# Manda F9 pro Excel varias vezes seguidas, pra nao ter que ficar apertando na
# mao. Cada F9 e um ciclo de clock da CPU.
#
# Uso:
#   .\run-clock.ps1              -> 50 vezes
#   .\run-clock.ps1 -Count 400   -> 400 vezes (pro ex2, que e mais longo)
#
# Antes de rodar: deixe o Excel ja preparado (READ ROM e RESET feitos). Depois
# de executar, tem 3 segundos pra clicar na janela do Excel. Nao mexa em outra
# janela enquanto roda, senao o F9 vai pro lugar errado. Ctrl+C cancela.

param(
    [int]$Count = 50,
    [int]$DelayMs = 1500,
    [int]$StartDelaySec = 3
)

Add-Type -AssemblyName System.Windows.Forms

Write-Host ""
Write-Host "Vou apertar F9 $Count vezes (intervalo de $DelayMs ms)." -ForegroundColor Cyan
Write-Host "Clique na janela do Excel agora..." -ForegroundColor Yellow

for ($i = $StartDelaySec; $i -gt 0; $i--) {
    Write-Host "  $i..." -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host " ja!" -ForegroundColor Green

for ($i = 1; $i -le $Count; $i++) {
    [System.Windows.Forms.SendKeys]::SendWait('{F9}')
    Write-Host ("  F9 {0}/{1}" -f $i, $Count)
    Start-Sleep -Milliseconds $DelayMs
}

Write-Host "Pronto." -ForegroundColor Green
