# MSP Zero Code Studio — Flash `.out` ke MSPM0G3507 via J-Link

How-to flash file `.out` dari **MSP Zero Code Studio** (TI Clang toolchain) ke chip **MSPM0G3507** menggunakan **J-Link**.

**Target Board**: [WeAct Studio MSPM0G3507 Core Board](https://www.westar.cn/)

---

## Hardware

| Komponen | Spesifikasi |
|----------|-------------|
| **Target Board** | WeAct Studio MSPM0G3507 Core Board |
| **MCU** | TI MSPM0G3507 (Cortex-M0+, 512KB Flash, 128KB RAM) |
| **Programmer** | J-Link (SEGGER), interface SWD |

---

## Quick Start

```powershell
# Terminal 1
git clone https://github.com/Muhammad-Yunus/MSP-Zero-Code-Studio-Jlink-Loader.git
cd MSP-Zero-Code-Studio-Jlink-Loader

# Jalankan script flash
bash scripts/flash.sh

# Atau gunakan PowerShell
.\scripts\flash.ps1
```

---

## Cara Pakai Script

Semua script otomatis mendeteksi path toolchain TI, J-Link, dan GDB yang terinstall. Cukup jalankan dari root repo:

### Flash Firmware

```powershell
# Flash file default (firmware/zero_code_start_ticlang.out)
bash scripts/flash.sh
.\scripts\flash.ps1
```

```powershell
# Flash file custom
bash scripts/flash.sh firmware/my_app.out
.\scripts\flash.ps1 -Firmware firmware\my_app.out
```

### Konversi `.out` ke `.hex` atau `.bin`

```powershell
# Konversi ke HEX
bash scripts/convert.sh firmware/my_app.out hex
.\scripts\convert.ps1 -Format hex

# Konversi ke BIN
bash scripts/convert.sh firmware/my_app.out bin
.\scripts\convert.ps1 -Format bin
```

### Ubah Port GDB Server

```powershell
PORT=2332 bash scripts/flash.sh
```

---

## Prasyarat

Toolscript ini memerlukan tool berikut (semua sudah tersedia di sistem yang digunakan):

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
