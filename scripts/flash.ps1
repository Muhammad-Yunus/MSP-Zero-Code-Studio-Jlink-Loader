<#
.SYNOPSIS
    Flash firmware to MSPM0G3507 via J-Link (GDB method)
.DESCRIPTION
    Starts JLinkGDBServer, then connects with arm-none-eabi-gdb to load
    the firmware ELF file to the target board.
.PARAMETER Firmware
    Path to the .out (ELF) firmware file. Defaults to firmware/zero_code_start_ticlang.out
.PARAMETER Port
    GDB server port. Default: 2331
.EXAMPLE
    .\flash.ps1
    .\flash.ps1 -Firmware firmware\my_app.out
    .\flash.ps1 -Firmware firmware\my_app.out -Port 2332
#>
param(
    [string]$Firmware = "$PSScriptRoot\..\firmware\zero_code_start_ticlang.out",
    [int]$Port = 2331
)

$ErrorActionPreference = "Stop"

$JLinkPath = "C:\Program Files\SEGGER\JLink_V844\JLinkGDBServer.exe"
$GdbPath   = Get-Command arm-none-eabi-gdb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $GdbPath) {
    $GdbPath = "C:\ST\STM32CubeIDE_2.0.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.100.202509120712\tools\bin\arm-none-eabi-gdb.exe"
}

if (-not (Test-Path $Firmware)) {
    Write-Error "Firmware not found: $Firmware"
    exit 1
}

Write-Host "=== MSPM0G3507 Flash via J-Link ===" -ForegroundColor Cyan
Write-Host "Firmware : $Firmware"
Write-Host "JLinkGDBServer : $JLinkPath"
Write-Host "GDB            : $GdbPath"
Write-Host ""

# Start JLinkGDBServer
Write-Host "[1/2] Starting JLinkGDBServer on port $Port ..." -ForegroundColor Yellow
$jlinkProc = Start-Process -FilePath $JLinkPath `
    -ArgumentList "-device", "MSPM0G3507", "-if", "SWD", "-speed", "auto", "-port", $Port, "-singlerun" `
    -PassThru -NoNewWindow
Write-Host "       PID: $($jlinkProc.Id)"

Start-Sleep -Seconds 3

# Flash via GDB
Write-Host "[2/2] Flashing firmware via GDB ..." -ForegroundColor Yellow
& $GdbPath -q `
    --eval-command='set confirm off' `
    --eval-command="target extended-remote :$Port" `
    --eval-command="file $Firmware" `
    --eval-command='load' `
    --eval-command='kill'

# Clean up
Stop-Process -Id $jlinkProc.Id -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Done! Firmware flashed to MSPM0G3507." -ForegroundColor Green
