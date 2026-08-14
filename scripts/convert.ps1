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
    [string]$Input  = "$PSScriptRoot\..\firmware\zero_code_start_ticlang.out",
    [ValidateSet("hex", "bin")]
    [string]$Format = "bin",
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$ToolchainDir = "C:\Users\Asus\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio\ti_cgt_arm_llvm\bin"
$BaseName     = [System.IO.Path]::GetFileNameWithoutExtension($Input)

if ($Output -eq "") {
    $Output = "$PSScriptRoot\..\$BaseName.$Format"
}

$TIObjcopy = "$ToolchainDir\tiarmobjcopy.exe"
$TIHexConv = "$ToolchainDir\tiarmhex.exe"

if (-not (Test-Path $Input)) {
    Write-Error "Input file not found: $Input"
    exit 1
}

Write-Host "=== Convert $Input ===" -ForegroundColor Cyan
Write-Host "Format : $Format"
Write-Host "Output : $Output"
Write-Host ""

if ($Format -eq "bin") {
    Write-Host "Running tiarmobjcopy ..." -ForegroundColor Yellow
    & $TIObjcopy -O binary $Input $Output
} else {
    Write-Host "Running tiarmhex ..." -ForegroundColor Yellow
    & $TIHexConv $Input "-o" $Output
}

$Size = (Get-Item $Output).Length
Write-Host ""
Write-Host "Done! Output: $Output ($Size bytes)" -ForegroundColor Green
