# mini_klavier
ASM_SRC=main

all: build

build:
	arm-none-eabi-as -mcpu=cortex-m3 -mfloat-abi=soft -mthumb -o main.o $(ASM_SRC).s
	arm-none-eabi-ld -T linker.ld -o main.elf main.o
	arm-none-eabi-objcopy -O binary main.elf main.bin

flash: main.bin
	st-flash --reset write main.bin 0x8000000