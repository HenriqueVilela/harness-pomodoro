<#
.SYNOPSIS
  Sorteia a skill do próximo intervalo com base no tempo sem relaxar e na
  frequência com que cada skill vem sendo escolhida.

.PARAMETER Simular
  Só mostra o cálculo e a escolha; não grava nada em intervalo/estado.json.

.PARAMETER Raiz
  Pasta do harness (padrão: a pasta acima de scripts/).

.EXAMPLE
  powershell -File scripts/escolher-intervalo.ps1 -Simular
#>
param(
  [switch]$Simular,
  [string]$Raiz = (Split-Path $PSScriptRoot -Parent)
)
$ErrorActionPreference = 'Stop'

function Read-Json([string]$caminho) {
  [IO.File]::ReadAllText($caminho, [Text.Encoding]::UTF8) | ConvertFrom-Json
}

$catPath = Join-Path $Raiz 'intervalo\catalogo.json'
$estPath = Join-Path $Raiz 'intervalo\estado.json'
$cat = Read-Json $catPath
# estado.json fica fora do git: cria vazio se não existir (clone novo)
if (-not (Test-Path $estPath)) {
  $vazio = '{ "ultimo_intervalo": null, "historico": [] }'
  [IO.File]::WriteAllText($estPath, $vazio, (New-Object Text.UTF8Encoding $false))
}
$est = Read-Json $estPath
$agora = Get-Date

# Minutos sem relaxar (sem histórico = trata como muito tempo)
if ($est.ultimo_intervalo) {
  $minutos = ($agora - [datetime]$est.ultimo_intervalo).TotalMinutes
} else {
  $minutos = 600
}

$historico = @($est.historico)
$janela = @($historico | Select-Object -Last $cat.janela_frequencia)
$total = $janela.Count

$linhas = foreach ($s in $cat.skills) {
  $usos = @($janela | Where-Object { $_.skill -eq $s.skill }).Count

  # Fator de frequência: puxa a frequência real para a frequencia_alvo
  if ($total -gt 0) {
    $real = [double]$usos / $total
    $fFreq = [double]$s.frequencia_alvo / [math]::Max([double]$real, [double]0.05)
    $fFreq = [math]::Min(2.0, [math]::Max(0.5, $fFreq))
  } else {
    $real = 0; $fFreq = 1.0
  }

  # Fator de tempo: máximo quando minutos ~ tempo_ideal_min
  $ratio = [math]::Max($minutos, 1) / $s.tempo_ideal_min
  $fTempo = [math]::Max(0.2, [math]::Sqrt([math]::Min($ratio, 1 / $ratio)))

  $elegivel = $minutos -ge $s.tempo_minimo_min
  $peso = if ($elegivel) { $s.frequencia_alvo * $fFreq * $fTempo } else { 0 }

  [pscustomobject]@{
    skill     = $s.skill
    elegivel  = $elegivel
    usos      = "$usos/$total"
    freq_alvo = $s.frequencia_alvo
    f_freq    = [math]::Round($fFreq, 2)
    f_tempo   = [math]::Round($fTempo, 2)
    peso      = [math]::Round($peso, 3)
  }
}

$soma = ($linhas | Measure-Object -Property peso -Sum).Sum
$cedo = $soma -le 0

if ($cedo) {
  $escolha = $cat.padrao_quando_cedo
} else {
  $alvo = Get-Random -Minimum 0.0 -Maximum $soma
  $acum = 0.0
  foreach ($l in $linhas) {
    $acum += $l.peso
    if ($l.peso -gt 0 -and $alvo -lt $acum) { $escolha = $l.skill; break }
  }
  if (-not $escolha) { $escolha = ($linhas | Sort-Object peso -Descending)[0].skill }
}

$linhas | Format-Table -AutoSize | Out-String | Write-Output
Write-Output ("MINUTOS_SEM_RELAXAR={0}" -f [math]::Round($minutos))
foreach ($l in $linhas) {
  $pct = if ($soma -gt 0) { [math]::Round(100 * $l.peso / $soma) } else { 0 }
  Write-Output ("CHANCE {0}={1}%" -f $l.skill, $pct)
}
Write-Output ("CEDO={0}" -f $cedo.ToString().ToLower())
Write-Output ("ESCOLHA={0}" -f $escolha)

if (-not $Simular) {
  $novo = [pscustomobject]@{
    skill               = $escolha
    quando              = $agora.ToString('o')
    minutos_sem_relaxar = [math]::Round($minutos)
  }
  $hist = @($historico + $novo) | Select-Object -Last 100
  $saida = [pscustomobject]@{
    ultimo_intervalo = $agora.ToString('o')
    historico        = @($hist)
  }
  $json = $saida | ConvertTo-Json -Depth 5
  [IO.File]::WriteAllText($estPath, $json, (New-Object Text.UTF8Encoding $false))
  Write-Output "REGISTRADO=true"
}
