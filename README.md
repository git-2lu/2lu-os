# MyOS — Bare-Metal RISC-V OS Kernel for ESP32-C3

A minimal bare-metal operating system kernel built from scratch for the **ESP32-C3** (RISC-V, RV32IMC architecture). This project boots directly from flash with a custom bootloader header — no ESP-IDF or external bootloader required.

## Features

- **Direct flash boot** with custom magic header (`0xaedb041d`)
- **Custom entry point** (`_start`) — sets up stack, clears BSS, copies `.data` from flash to RAM
- **Trap handler** — saves full CSR context on exceptions, prints trap info (mcause, mtval, mepc)
- **USB Serial JTAG console** — custom `printf` implementation via `USB_SERIAL_JTAG_EP1_REG`
- **Watchdog management** — disables RTC WDT, TimerGroup WDT, and Super WDT at boot
- **Custom memory layout** — IROM (code), DROM (rodata), SRAM (data/bss/stack)
- **Two log modes** — `WAIT` (blocking, safe) or `FORGET` (non-blocking, fire-and-forget)

## Architecture

| Component | Details |
|-----------|---------|
| **Target** | ESP32-C3 (RISC-V, RV32IMC) |
| **ISA** | RV32IMC + Zicsr |
| **ABI** | ilp32 |
| **Flash regions** | IROM @ `0x42000000`, DROM @ `0x3C000000` (4 MB each) |
| **SRAM** | `0x3FC80000`, 320 KB |
| **Boot** | Direct from flash offset 0x0 (custom header) |
| **Console** | USB Serial JTAG (EP1 registers) |

## Prerequisites (Arch Linux)

### 1. RISC-V Cross-Compiler

```bash
# Install the RISC-V ELF toolchain from the official repos
sudo pacman -S riscv64-elf-gcc riscv64-elf-newlib
```

This provides:
- `riscv64-elf-gcc` — the cross-compiler
- `riscv64-elf-objcopy` — ELF-to-binary conversion
- `riscv64-elf-objdump` — disassembly (optional, for debugging)

### 2. Python 3 and esptool.py

```bash
# Python 3 is usually pre-installed. Verify:
python3 --version

# Install esptool.py (ESP32 flash utility)
sudo pacman -S python-esptool
# Or via pip if the package is outdated:
pip install esptool
```

### 3. USB Serial Support

```bash
# Ensure your user is in the dialout group for serial port access
sudo usermod -aG dialout $USER

# You may need to log out and back in for the group change to take effect
```

### 4. Optional: GDB for debugging

```bash
sudo pacman -S riscv64-elf-gdb
```

## Project Structure

```
myos/
├── Makefile            # Build system (compile, link, flash)
├── common.ld           # Linker script: sections, entry point, memory layout
├── memory.ld           # Linker script: MEMORY region definitions (IROM/DROM/RAM)
├── hal/
│   ├── constants.h     # Hardware constants (e.g., watchdog keys)
│   └── registers.h     # Memory-mapped register addresses
├── kernel/
│   ├── kernel.c        # _start entry, data init, watchdog disable, kernel_main
│   ├── trap.c          # Trap handler (kernel_entry, handle_trap)
│   └── include/
│       ├── kernel.h    # Kernel header aggregation
│       ├── common.h    # Types, printf, memset, etc.
│       └── trap.h      # Trap frame struct, CSR macros
└── build/              # Output directory (auto-generated)
    ├── os_kernel.elf   # Final ELF image
    └── os_kernel.bin   # Raw binary for flashing
```

## Building

### Default build (WAIT log mode)

```bash
make build
```

This compiles all sources and produces `build/os_kernel.bin`.

### With FORGET log mode (non-blocking, faster)

```bash
make build USB_LOG_MODE=FORGET
```

### Clean

```bash
make clean
```

## Flashing to ESP32-C3

### Ensure the device is connected

```bash
ls /dev/ttyACM*
# or
dmesg | tail
```

### Default flash (uses /dev/ttyACM0 at 921600 baud)

```bash
make flash
```

### Custom port and baud rate

```bash
make flash PORT=/dev/ttyACM0 BAUD=921600
```

### Flashing notes

- The binary is written to flash offset **0x0** (direct boot, no bootloader).
- If the chip refuses to boot after flashing, hold **BOOT** button while resetting, then flash again.
- The ESP32-C3 Super Mini has a built-in LED on **GPIO8** that will blink during `kernel_main`.

## USB Console Output

Connect to the USB Serial JTAG console at **115200 baud**:

```bash
# Using screen
screen /dev/ttyACM0 115200

# Using minicom
minicom -D /dev/ttyACM0 -b 115200

# Using picocom
picocom -b 115200 /dev/ttyACM0
```

Press **RESET** on the board to see output.

## Configuration

Edit the Makefile or pass variables on the command line:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `/dev/ttyACM0` | Serial port for flashing |
| `BAUD` | `921600` | Flash baud rate |
| `USB_LOG_MODE` | `WAIT` | Log mode: `WAIT` (blocking) or `FORGET` (non-blocking) |

## Debugging

### Disassemble the ELF

```bash
riscv64-elf-objdump -d build/os_kernel.elf > os_kernel.lst
```

### Check binary size

```bash
riscv64-elf-size build/os_kernel.elf
```

### Verify the binary

```bash
riscv64-elf-objdump -h build/os_kernel.elf
```

## Hardware Notes

- **ESP32-C3** is a RISC-V MCU with 512 KB SRAM (320 KB usable after ROM/stack).
- Code executes from **IROM** (flash mapped to instruction cache at `0x42000000`).
- Read-only data lives in **DROM** (flash mapped to data cache at `0x3C000000`).
- `.data` is copied from flash to **SRAM** at boot; `.bss` is zeroed.
- The custom header at offset 0 (`0xaedb041d`) is recognized by the ESP32-C3 ROM to enable direct boot mode.
