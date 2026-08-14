# MSP Zero Code Studio — Flash `.out` ke MSPM0G3507 via J-Link

![WeAct MSPM0G3507 Banner](docs/Weact_Studio_MSPM0G3507_banner.png)

How-to flash file `.out` dari **MSP Zero Code Studio** (TI Clang toolchain) ke chip **MSPM0G3507** menggunakan **J-Link**.

**Target Board**: [WeAct Studio MSPM0G3507 Core Board](https://github.com/WeActStudio/WeActStudio.MSPM0G3507CoreBoard/)

---

## Hardware

| Komponen | Spesifikasi |
|----------|-------------|
| **Target Board** | WeAct Studio MSPM0G3507 Core Board |
| **MCU** | TI MSPM0G3507 (Cortex-M0+, 512KB Flash, 128KB RAM) |
| **Programmer** | J-Link (SEGGER), terhubung via SWD (2-pin: SWCLK, SWDIO) |

![WeAct MSPM0G3507 Board](docs/Weact_Studio_MSPM0G3507.png =500)

---

## Quick Start

```powershell
git clone https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader.git
cd MSP-Zero-Code-Studio-Jlink-Loader

# Flash firmware default
bash scripts/flash.sh
# Atau PowerShell
.\scripts\flash.ps1
```

---

## Cara Pakai Script

Semua script otomatis mendeteksi path toolchain TI, J-Link, dan GDB.

### Flash Firmware

```powershell
bash scripts/flash.sh                    # default firmware
bash scripts/flash.sh firmware/my_app.out
.\scripts\flash.ps1 -Firmware firmware\my_app.out
```

### Konversi `.out` ke `.hex` atau `.bin`

```powershell
bash scripts/convert.sh firmware/my_app.out hex
bash scripts/convert.sh firmware/my_app.out bin
.\scripts\convert.ps1 -Format hex
.\scripts\convert.ps1 -Format bin
```

### Ubah Port GDB Server

```powershell
PORT=2332 bash scripts/flash.sh
```

---

## Firmware: ADC Sample to UART Write

Folder `firmware/` berisi firmware demo dari **MSP Zero Code Studio** — contoh proyek **ADC Sample to UART Write**. Firmware ini adalah file ELF (`.out`) bersih yang diambil langsung dari folder workspace compiler, bukan hasil export (exportan biasanya korup karena byte Unicode replacement character).

Demo ini menggambarkan cara membaca input ADC dan mengirim hasilnya via UART, cocok untuk validasi hardware sebelum flash firmware sendiri.

### Dependencies

Untuk menghasilkan firmware `.out` sendiri, pastikan tool berikut sudah terinstall:

- **[MSP Zero Code Studio](https://www.ti.com/tool/MSP-ZERO-CODE-STUDIO)** — IDE visual dari TI untuk mem CONFIG dan generate code untuk MCU MSPM0
- **[J-Link Software](https://www.segger.com/downloads/jlink/)** — Debugger/programmer dari SEGGER (dipakai: **V8.44**)

Dengan kombinasi kedua tool ini, kamu tidak lagi perlu board debugger XDS (LaunchPad) untuk flashing — cukup konek J-Link ke header SWD di board.

![MSP Zero Code Studio](docs/msp_zero_code_studio.png)

---

## Prasyarat

| Tool | Lokasi Bawaan |
|------|--------------|
| **J-Link** | `C:\Program Files\SEGGER\JLink_V844\` |
| **GDB** | STM32CubeIDE `...\tools\bin\arm-none-eabi-gdb.exe` |
| **TI Tools** | `<PATH_MSP_ZEROCODE_STUDIO>\ti_cgt_arm_llvm\bin\` |

Cari lokasi GDB jika tidak di PATH:
```powershell
where.exe arm-none-eabi-gdb
```

---

## Pengetahuan Penting

### Kenapa file `.out` hasil export korup?

File `.out` yang di-export dari MSP Zero Code Studio mengandung byte `0xEF 0xBF 0xBD` (Unicode replacement character) yang membuat header ELF rusak. Gunakan file asli dari folder workspace compiler:

```
<PATH_MSP_ZEROCODE_STUDIO>\workspace\<nama_project>\Debug\<nama_project>.out
```

Contoh:
```
C:\Users\<username>\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio\workspace\<nama_project>\Debug\<nama_project>.out
```

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `Failed to open file` di JLink | Gunakan path tanpa spasi, atau copy file ke root repo |
| `invalid e_shentsize in ELF header` | File exportan korup. Salin dari folder workspace Debug |
| `loadfile` crash di tiarmhex | Gunakan `tiarmobjcopy` untuk generate `.bin`, lalu flash via GDB |
| Port 2331 sudah dipakai | Ubah port: `PORT=2332 bash scripts/flash.sh` |
| GDB `load` gagal tanpa "Transfer rate" | Tambahkan `monitor halt` sebelum `load` |
| `tiarmhex.exe` segmentation fault | File ELF corrupt. Gunakan versi dari workspace Debug |
