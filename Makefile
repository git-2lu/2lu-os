# --- Compiler and Toolchain Configuration ---
CC      = riscv64-elf-gcc
OBJCOPY = riscv64-elf-objcopy
ESPTOOL = esptool.py

# --- Hardware Target Options ---
PORT    = /dev/ttyACM0
BAUD    = 921600

# --- Log Mode Configuration Option ---
# Modes available: 
#   WAIT   - Timeout check mechanism (safe from locks, slower if host missing)
#   FORGET - Old style (print-and-forget, fast, completely non-blocking)
USB_LOG_MODE ?= WAIT

# --- Compilation Architecture Flags for ESP32-C3 ---
CFLAGS  = -march=rv32imc_zicsr -mabi=ilp32 -Og -Wall -nostdlib -ffreestanding \
          -Ikernel/include -Idrivers/include -Ihal

# Inject the configuration macro into CFLAGS dynamically
ifeq ($(USB_LOG_MODE), FORGET)
    CFLAGS += -DLOG_MODE_FORGET
else
    CFLAGS += -DLOG_MODE_WAIT
endif

# --- Directories ---
BUILD_DIR = build
OBJ_DIR   = $(BUILD_DIR)/obj

# --- Source Files Discovery ---
SRCS_S = $(wildcard boot/*.S)
SRCS_C = $(wildcard kernel/*.c) $(wildcard drivers/*.c)

# --- Object Files Translation ---
OBJS   = $(patsubst %.S, $(OBJ_DIR)/%.o, $(SRCS_S)) \
         $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS_C))

TARGET  = $(BUILD_DIR)/os_kernel

# Default target just runs the compilation
all: build

# 1. Main build pipeline (Does NOT flash)
build: $(TARGET).bin

# 2. Creates the flashable binary from the ELF image
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

# 3. Links all object files together into the final ELF image
$(TARGET).elf: $(OBJS) common.ld memory.ld
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -T memory.ld -T common.ld $(OBJS) -o $(TARGET).elf

# 4. Pattern rule to compile raw C files into Object files
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# 5. Pattern rule to compile assembly (.S) files into Object files
$(OBJ_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# 6. SEPARATED FLASH TARGET
# This will execution only if build/os_kernel.bin physically exists. 
# It will NOT auto-recompile your code if you change files.
flash:
	@if [ ! -f $(TARGET).bin ]; then \
		echo "Error: $(TARGET).bin not found! Run 'make build' first."; \
		exit 1; \
	fi
	$(ESPTOOL) --chip esp32c3 --port $(PORT) --baud $(BAUD) write_flash 0x0 $(TARGET).bin

# 7. Cleans up the directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all build flash clean
