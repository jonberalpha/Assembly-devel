.syntax	unified
.arch	armv7-m

.global	__StackTop

.section .isr_vector
.align	2
.global _isr_vector
_isr_vector:
	.long	__StackTop /* we will need this later */
	.long	Reset_Handler
	.long	Default_Handler
	.long	Default_Handler
	.long	Default_Handler
	.long	Default_Handler
	.long	Default_Handler
	.long	0
	.long	0
	.long	0
	.long	0
	.long	Default_Handler
	.long	Default_Handler
	.long	0
	.long	Default_Handler
	.long	Default_Handler


.text
.thumb
.thumb_func
.include "STM32_F103RB_MEM_MAP.INC"
.align	2
.global	Reset_Handler
.type	Reset_Handler, %function
Reset_Handler:
	/* enable the GPIOC clock in RCC_APB2ENR register */
	ldr	r0, =RCC_APB2ENR
	ldr	r1, =(1 << 4)
	str	r1, [r0]

	/* set PC13 as output in GPIOC_CRH */
	ldr	r0, =GPIOC_CRH
	ldr	r1, =(1 << 20)
	str	r1, [r0]

loop:
	/* set PC13 in GPIOC_BSRR register */
	ldr	r0, =GPIOC_BSRR
	ldr	r1, =(1 << 13)
	str	r1, [r0]

	/* loop as a delay */
	ldr	r0, =0
	ldr	r1, =200000
delay1:
	add	r0, r0, #1
	cmp	r0, r1
	bne	delay1

	/* reset PC13 in GPIOC_BRR reister */
	ldr	r0, =GPIOC_BRR
	ldr	r1, =(1 << 13)
	str	r1, [r0]

	/* loop as delay */
	ldr	r0, =0
	ldr	r1, =200000
delay2:
	add	r0, r0, #1
	cmp	r0, r1
	bne	delay2

	b	loop


Default_Handler:
	b	.
