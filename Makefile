# --- Compiler and Toolchain Configuration ---
CC      = riscv64-elf-gcc
OBJCOPY = riscv64-elf-objcopy
ESPTOOL = esptool.py

# --- Hardware Target Options ---
PORT    = /dev/ttyUSB0
BAUD    = 921600

# --- Compilation Architecture Flags for ESP32-C3 ---
CFLAGS  = -march=rv32imc -mabi=ilp32 -Og -Wall -nostdlib -ffreestanding

# --- Build Targets ---
TARGET  = os_kernel

all: build

# Explicit build target
build: $(TARGET).bin

# New line:
$(TARGET).elf: kernel.c common.ld memory.ld
	$(CC) $(CFLAGS) -T memory.ld -T common.ld kernel.c -o $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

# Flash target now depends explicitly on the build target
flash: build
	$(ESPTOOL) --chip esp32c3 --port $(PORT) --baud $(BAUD) write_flash 0x0 $(TARGET).bin

clean:
	rm -f $(TARGET).elf $(TARGET).bin

.PHONY: all build flash clean
