.syntax unified

.cpu cortex-m3
.fpu softvfp

.equ USART1_BASE, 0x40013800
.equ RCC_BASE, 0x40021000
.equ GPIOA_BASE, 0x40010800
.equ GPIOA_CRH_OFF, 0x04

.section .text
    .align 2
    .global Reset_Handler
    .type Reset_Handler, %function
Reset_Handler:
    ldr     sp, =_estack

    // Enable USART1 and GPIOA clocks
    ldr     r0, =RCC_BASE
    ldr     r1, [r0, #0x18]   // RCC_APB2ENR
    orr     r1, r1, #(1 << 14) // USART1EN: enable USART1 clock
    str     r1, [r0, #0x18]

    // Configure GPIOA for USART1
    ldr     r0, =GPIOA_BASE
    ldr     r1, [r0, #GPIOA_CRH_OFF]
    and     r1, r1, #0xFFFFF00F  // Clear PA9 and PA10
    orr     r1, r1, #(0xB << 4)  // Set PA9 as AF push-pull output
    str     r1, [r0, #GPIOA_CRH_OFF]

    // Configure USART1
    ldr     r0, =USART1_BASE
    mov     r1, #0
    str     r1, [r0, #0x0C] // Baud rate = 9600 (APB2 clock = 72 MHz)
    mov     r1, #(1 << 3)  // Enable transmitter
    str     r1, [r0, #0x1C] // CR1 register

    // Send "Hello World" over UART1
    ldr     r0, =USART1_BASE
    ldr     r1, =HelloWorld
    mov     r2, #0
loop:
    ldrb    r3, [r1, r2]
    cmp     r3, #0
    beq     done
    strb    r3, [r0, #0x04] // Send character over UART1
    add     r2, r2, #1
    b       loop

done:
    // Loop forever
    b       done

.section .data
    .align 2
HelloWorld:
    .asciz "Hello World"

.section .bss
    .align 2
_estack:
