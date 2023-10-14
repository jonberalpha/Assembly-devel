all: riscv/test x64/test

riscv/test: main.c
	mkdir -p riscv && cd riscv && riscv64-linux-gnu-gcc -march=rv64g -o test -g -O0 -Wall -Werror -pedantic -Wa,-adhln ../main.c > test.lst

x64/test: main.c
	mkdir -p x64 && cd x64 && gcc -o test -g -O0 -Wall -Werror -pedantic -masm=intel -Wa,-adhln ../main.c > test.lst

dis.riscv: riscv/test
	riscv64-linux-gnu-objdump -d riscv/test

dis.x64: x64/test
	objdump -M intel -d x64/test

clean:
	rm -rf riscv x64
