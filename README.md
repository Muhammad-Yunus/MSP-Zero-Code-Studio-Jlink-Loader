# MSP Zero Code Studio — Flash `.out` to MSPM0G3507 via J-Link

<p align="center">
  <img src="docs/Weact_Studio_MSPM0G3507_banner.png" alt="WeAct MSPM0G3507 Banner" width="100%">
</p>

> Flash TI `.out` (ELF) firmware to **MSPM0G3507** using **J-Link** — no XDS debugger required.

<p align="center">
  <a href="https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader"><img src="https://img.shields.io/github/license/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader?style=for-the-badge" alt="License"></a>
  <a href="https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader"><img src="https://img.shields.io/github/v/tag/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader?style=for-the-badge" alt="Tag"></a>
  <a href="https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader"><img src="https://img.shields.io/github/last-commit/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader?style=for-the-badge" alt="Last Commit"></a>
  <a href="https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader"><img src="https://img.shields.io/github/stars/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader?style=for-the-badge" alt="Stars"></a>
</p>

<p align="center">
  <a href="https://www.ti.com/tool/MSP-ZERO-CODE-STUDIO"><img src="https://img.shields.io/badge/TI-MSP_Zero_Code_Studio-0099BD?style=for-the-badge&logo=texasinstruments" alt="TI MSP Zero Code Studio"></a>
  <a href="https://www.segger.com/products/debug-probes/j-link/"><img src="https://img.shields.io/badge/J--Link-SEGGER-V8.44-52B70C?style=for-the-badge" alt="J-Link V8.44"></a>
  <a href="https://github.com/WeActStudio/WeActStudio.MSPM0G3507CoreBoard/"><img src="https://img.shields.io/badge/Board-WeAct_MSPM0G3507-FF6B6B?style=for-the-badge" alt="WeAct Board"></a>
  <a href="https://developer.arm.com/architectures/cpu-architecture/m-profile"><img src="https://img.shields.io/badge/CPU-Cortex--M0%2B-0099BD?style=for-the-badge&logo=arm" alt="Cortex-M0+"></a>
</p>

---

## Hardware

<table align="center">
  <tr>
    <td align="center">
      <img src="docs/Weact_Studio_MSPM0G3507.png" alt="WeAct MSPM0G3507 Board" width="500"><br>
      <sub>WeAct Studio MSPM0G3507 Core Board</sub>
    </td>
    <td align="left" valign="top">
      <table>
        <tr><td><b>Target Board</b></td><td>WeAct Studio MSPM0G3507 Core Board</td></tr>
        <tr><td><b>MCU</b></td><td>TI MSPM0G3507 (Cortex-M0+, 512KB Flash, 128KB RAM)</td></tr>
        <tr><td><b>Programmer</b></td><td>J-Link (SEGGER), connected via SWD (2-pin: SWCLK, SWDIO)</td></tr>
        <tr><td><b>Toolchain</b></td><td>MSP Zero Code Studio (TI ARM Clang)</td></tr>
      </table>
    </td>
  </tr>
</table>

---

## Quick Start

```powershell
git clone https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader.git
cd MSP-Zero-Code-Studio-Jlink-Loader

# Flash default firmware
bash scripts/flash.sh

# Or with PowerShell
.\scripts\flash.ps1
```

---

## Script Usage

All scripts auto-detect the TI toolchain, J-Link, and GDB paths.

### Flash Firmware

```powershell
bash scripts/flash.sh                         # default firmware
bash scripts/flash.sh firmware/my_app.out
.\scripts\flash.ps1 -Firmware firmware\my_app.out
```

### Convert `.out` to `.hex` or `.bin`

```powershell
bash scripts/convert.sh firmware/my_app.out hex
bash scripts/convert.sh firmware/my_app.out bin
.\scripts\convert.ps1 -Format hex
.\scripts\convert.ps1 -Format bin
```

### Change GDB Server Port

```powershell
PORT=2332 bash scripts/flash.sh
```

---

## Repository Structure

```
MSP-Zero-Code-Studio-Jlink-Loader/
├── docs/                  # Screenshots and images
│   ├── Weact_Studio_MSPM0G3507_banner.png
│   ├── Weact_Studio_MSPM0G3507.png
│   └── msp_zero_code_studio.png
├── firmware/              # Demo firmware (clean ELF from workspace)
│   └── zero_code_start_ticlang.out
├── scripts/               # Flash and conversion utilities
│   ├── flash.sh           # Bash (Git Bash / WSL)
│   ├── flash.ps1          # PowerShell
│   ├── convert.sh         # Convert .out → .hex / .bin
│   └── convert.ps1        # PowerShell version
└── README.md
```

---

## Firmware: ADC Sample to UART Write

The `firmware/` folder contains a demo firmware from **MSP Zero Code Studio** — the **ADC Sample to UART Write** example project. The firmware is a clean ELF (`.out`) file taken directly from the compiler workspace, **not** the exported version (exported files are usually corrupted due to Unicode replacement characters):

```
<PATH_MSP_ZEROCODE_STUDIO>\workspace\zero_code_start_ticlang\Debug\zero_code_start_ticlang.out
```

Example:
```
C:\Users\<username>\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio\workspace\zero_code_start_ticlang\Debug\zero_code_start_ticlang.out
```

This demo reads ADC input and prints the result via UART — ideal for hardware validation before flashing your own firmware.

### Dependencies

To generate your own `.out` firmware, make sure the following tools are installed:

| Tool | Download |
|------|----------|
| **[MSP Zero Code Studio](https://www.ti.com/tool/MSP-ZERO-CODE-STUDIO)** | [ti.com/tool/MSP-ZERO-CODE-STUDIO](https://www.ti.com/tool/MSP-ZERO-CODE-STUDIO) |
| **[J-Link Software](https://www.segger.com/downloads/jlink/)** | [segger.com/downloads/jlink](https://www.segger.com/downloads/jlink/) |

With these two tools, you no longer need an XDS debugger board (LaunchPad) for flashing — simply connect J-Link to the SWD header on the board.

<p align="center">
  <img src="docs/msp_zero_code_studio.png" alt="MSP Zero Code Studio" width="600">
</p>

---

## Prerequisites

| Tool | Default Location |
|------|-----------------|
| **J-Link** | `C:\Program Files\SEGGER\JLink_V844\` |
| **GDB** | STM32CubeIDE `...\tools\bin\arm-none-eabi-gdb.exe` |
| **TI Tools** | `<PATH_MSP_ZEROCODE_STUDIO>\ti_cgt_arm_llvm\bin\` |

Find GDB location if not in PATH:
```powershell
where.exe arm-none-eabi-gdb
```

---

## Important Notes

### Why are exported `.out` files corrupted?

Files exported from MSP Zero Code Studio contain `0xEF 0xBF 0xBD` bytes (Unicode replacement characters), which corrupt the ELF header. Use the original file from the compiler workspace folder instead.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `Failed to open file` in JLink | Use a path without spaces, or copy the file to the repo root |
| `invalid e_shentsize in ELF header` | Exported file is corrupted. Copy from the workspace Debug folder |
| `loadfile` crash in tiarmhex | Use `tiarmobjcopy` to generate `.bin`, then flash via GDB |
| Port 2331 already in use | Change port: `PORT=2332 bash scripts/flash.sh` |
| GDB `load` fails without "Transfer rate" | Add `monitor halt` before `load` |
| `tiarmhex.exe` segmentation fault | ELF file is corrupt. Use the workspace Debug version or generate `.bin` with `tiarmobjcopy` |

---

## License

[MIT License](LICENSE)

---

<p align="center">
  Made with ❤️ for the MSPM0 community
</p>
