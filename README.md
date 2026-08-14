# MSP Zero Code Studio — Flash `.out` ke MSPM0G3507 via J-Link

How-to flash file `.out` dari **MSP Zero Code Studio** (TI Clang toolchain) ke chip **MSPM0G3507** menggunakan **J-Link**.

**Target Board**: [WeAct Studio MSPM0G3507 Core Board](https://www.westar.cn/)

Panduan ini menggunakan **MSP Zero Code Studio** sebagai compiler dan **J-Link** sebagai programmer/debugger.

> Semua contoh menggunakan **PowerShell**. Untuk CMD, hapus backtick `` ` `` dan ganti baris baru dengan `^`.

---

## Hardware yang Digunakan

| Komponen | Spesifikasi |
|----------|-------------|
| **Target Board** | WeAct Studio MSPM0G3507 Core Board |
| **MCU** | TI MSPM0G3507 (Cortex-M0+, 512KB Flash, 128KB RAM) |
| **Debugger/Programmer** | J-Link (SEGGER) |
| **Interface** | SWD (2-pin: SWCLK, SWDIO) |
| **Toolchain** | MSP Zero Code Studio (TI ARM Clang) |

---

## Quick Start (Flash Langsung)

Jika kamu hanya ingin flash secepatnya dan sudah punya file `.out` bersih dari workspace Debug:

**Terminal 1**: Mulai JLinkGDBServer

````powershell
& "<PATH_JLINK>\JLinkGDBServer.exe" -device MSPM0G3507 -if SWD -speed auto -port 2331 -singlerun
````

**Terminal 2** (tunggu ~3 detik lalu jalankan):

````powershell
& "<PATH_GDB>\arm-none-eabi-gdb.exe" -q `
  --eval-command='set confirm off' `
  --eval-command='target extended-remote :2331' `
  --eval-command='file <path_ke_file>/<nama_project>.out' `
  --eval-command='load' `
  --eval-command='kill'
````

Output sukses akan terlihat seperti:

```
Loading section .intvecs, size 0xc0 lma 0x0
Loading section .text, size 0x728 lma 0xc0
Loading section .rodata, size 0x18 lma 0x7e8
Loading section .cinit, size 0x18 lma 0x800
Start address 0x00000744, load size 2072
Transfer rate: 1011 KB/sec, 518 bytes/write.
[Inferior 1 (Remote target) killed]
```

---

## Mengetahui File `.out` yang Bisa Dipakai

File `.out` hasil **export** dari MSP Zero Code Studio adalah format TI-specific ELF yang **korup** — byte `0xEF 0xBF 0xBD` (Unicode replacement character) tersebar di seluruh file sehingga tools standar tidak bisa membacanya.

### Sumber file asli yang valid

File ELF asli yang bersih ada di folder workspace compiler bawaan MSP Zero Code Studio:

```
<PATH_MSP_ZEROCODE_STUDIO>\workspace\<nama_project>\Debug\<nama_project>.out
```

> Ganti `<PATH_MSP_ZEROCODE_STUDIO>` dengan lokasi instalasi MSP Zero Code Studio kamu.
> Contoh di Windows: `C:\Users\<username>\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio`

---

## Konversi `.out` ke `.hex` atau `.bin`

Jika perlu convert ke format lain (misalnya untuk dicatat atau dipakai tool lain):

### Carilah tool converter bawaan TI

Tool ini berada di folder toolchain TI dalam MSP Zero Code Studio:

```
<PATH_MSP_ZEROCODE_STUDIO>\ti_cgt_arm_llvm\bin\
```

Tool yang tersedia:
- `tiarmhex.exe` — ELF ke Intel HEX
- `tiarmobjcopy.exe` — ELF ke berbagai format (termasuk raw binary)

Cari di sistem jika lokasinya tidak diketahui:
````powershell
Get-ChildItem "C:\" -Recurse -Filter "tiarmhex.exe" -ErrorAction SilentlyContinue | Select-Object -First 3 FullName
Get-ChildItem "C:\" -Recurse -Filter "tiarmobjcopy.exe" -ErrorAction SilentlyContinue | Select-Object -First 3 FullName
````

### Konversi ke Intel HEX

```bash
<PATH_TOOLCHAIN>\tiarmhex.exe \
  <PATH_WORKSPACE>/workspace/<nama_project>/Debug/<nama_project>.out \
  -o <nama_project>.hex
```

### Konversi ke Raw Binary

```bash
<PATH_TOOLCHAIN>\tiarmobjcopy.exe \
  -O binary \
  <PATH_WORKSPACE>/workspace/<nama_project>/Debug/<nama_project>.out \
  <nama_project>.bin
```

---

## Flash ke MSPM0G3507 via J-Link

### Persiapan

Pastikan J-Link terhubung dan device terdeteksi di JLink Commander:

- **Device**: `MSPM0G3507`
- **Interface**: `SWD`
- **License**: `FlashDL`

### Cara 1 — GDB (paling reliable)

Lihat **Quick Start** di atas.

### Cara 2 — Script JLink Commander

Buat file `flash.cmd`:

```
device MSPM0G3507
speed auto
h
loadfile <path_ke_file>/<nama_project>.out
exit
```

Jalankan:

````powershell
& "<PATH_JLINK>\JLink.exe" -CommandFile flash.cmd
````

> **Catatan**: `loadfile` bisa gagal jika file `.out` exportan korup. Gunakan file dari workspace Debug.

### Cara 3 — Menggunakan File HEX

````powershell
& "<PATH_JLINK>\JLink.exe" -device MSPM0G3507 -if SWD -speed auto -autoconnect 1 -h
````

Lalu di prompt interaktif J-Link:

```
loadfile <path_ke_file>/<nama_project>.hex
```

---

## Variable Path yang Digunakan

| Variable | Keterangan | Contoh |
|----------|-----------|--------|
| `<PATH_MSP_ZEROCODE_STUDIO>` | Lokasi instalasi MSP Zero Code Studio | `C:\Users\<user>\guicomposer\runtime\gcruntime.v13\MSPZeroCodeStudio` |
| `<PATH_TOOLCHAIN>` | Sama dengan di atas | — |
| `<PATH_JLINK>` | Lokasi instalasi J-Link | `C:\Program Files\SEGGER\JLink_V844` |
| `<PATH_GDB>` | Lokasi ARM GCC / GNU ARM Embedded Toolchain | `C:\...\STM32CubeIDE\...\bin` atau `$env:PATH` |

**Tips**: Cari lokasi GDB dengan: `where.exe arm-none-eabi-gdb` (Windows) atau `which arm-none-eabi-gdb` (WSL/Linux).

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `Failed to open file` di JLink | Gunakan path tanpa spasi, atau copy file ke direktori root (mis. Desktop) |
| `invalid e_shentsize in ELF header` | File `.out` exportan korup. Gunakan file asli dari folder `workspace/*/Debug/` |
| `loadfile` crash di tiarmhex | Gunakan `tiarmobjcopy` untuk generate `.bin`, lalu flash via GDB |
| `Target does not support this command` saat `monitor erasechip` | Lewati erase manual — perintah `load` di GDB sudah otomatis erase sector yang diperlukan |
| Port 2331 sudah dipakai | Tambahkan `-port <nomor>` berbeda pada JLinkGDBServer |
| JLink tidak mengenali file ELF | Konversi dulu ke `.hex` atau `.bin` menggunakan tool TI |
| GDB `load` gagal — "Transfer rate" tidak muncul | J-Link mungkin belum halt CPU. Tambahkan `monitor halt` sebelum `load` |
| Script file J-Link tidak bisa run `interface SWD` | Gunakan flag `-if SWD` di command line, jangan di script |
| `tiarmhex.exe` segmentation fault | File ELF corrupt. Gunakan workspace Debug version atau `tiarmobjcopy` untuk generate `.bin` |
