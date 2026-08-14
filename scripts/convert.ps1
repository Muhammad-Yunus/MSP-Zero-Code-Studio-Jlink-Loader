<#
.SYNOPSIS
    Convert TI ELF (.out) to Intel HEX or raw Binary
.DESCRIPTION
    Uses TI's tiarmhex.exe or tiarmobjcopy.exe from MSP Zero Code Studio
    toolchain to convert the firmware ELF file.
.PARAMETER Input
    Path to the .out (ELF) firmware file.
.PARAMETER Format
    Output format: hex or bin. Default: bin
.PARAMETER Output
    Output file path. Default: same name with .hex or .bin extension
.EXAMPLE
    .\convert.ps1 -Format hex
    .\convert.ps1 -Input firmware\my_app.out -Format bin -Output my_app.bin
#>
param(
    [string]$Firmware = "$PSScriptRoot\..\firmware\zero_code_start_ticlang.out",
    [ValidateSet("hex", "bin")]
    [string]$Format = "bin",
    [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"

$ToolchainDir = "C:\Users\Asus\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio\ti_cgt_arm_llvm\bin"
$BaseName   = [System.IO.Path]::GetFileNameWithoutExtension($Firmware)

if ($OutFile -eq "") {
    $OutFile = (Resolve-Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue).Path + "\$BaseName.$Format"
}

$TIObjcopy = "$ToolchainDir\tiarmobjcopy.exe"
$TIHexConv = "$ToolchainDir\tiarmhex.exe"

if (-not (Test-Path $Firmware)) {
    Write-Error "Firmware file not found: $Firmware"
    exit 1
}

Write-Host "=== Convert $Firmware ===" -ForegroundColor Cyan
Write-Host "Format : $Format"
Write-Host "Output : $OutFile"
Write-Host ""

if ($Format -eq "bin") {
    Write-Host "Running tiarmobjcopy ..." -ForegroundColor Yellow
    & $TIObjcopy -O binary $Firmware $OutFile
} else {
    Write-Host "Running tiarmhex ..." -ForegroundColor Yellow
    & $TIHexConv $Firmware "-o" $OutFile
}

$Size = (Get-Item $OutFile).Length
Write-Host ""
Write-Host "Done! Output: $OutFile ($Size bytes)" -ForegroundColor Green
