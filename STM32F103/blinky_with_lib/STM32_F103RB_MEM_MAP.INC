//*****************************************************************************
// * @file    STM32_F103RB_MEM_MAP.INC
// * @author  Jonas Berger
// * @version V2.0
// * @date    22-December-2022
// * @brief   CMSIS Cortex-M3 Device Peripheral Access Layer Include File. 
// *          This file contains the most important peripheral register's 
// *          definitions and memory mapping for STM32F10x Performance line
//******************************************************************************

.equ PERIPH_BB_BASE,   0x42000000        

.equ PERIPH_BASE,      0x40000000 
.equ APB1PERIPH_BASE,  PERIPH_BASE      
.equ APB2PERIPH_BASE,  PERIPH_BASE + 0x10000
.equ AHBPERIPH_BASE,   PERIPH_BASE + 0x20000

.equ GPIOA_BASE,       APB2PERIPH_BASE + 0x0800
.equ GPIOA_CRL,        GPIOA_BASE
.equ GPIOA_CRH,        GPIOA_BASE+0x04
.equ GPIOA_IDR,        GPIOA_BASE+0x08
.equ GPIOA_ODR,        GPIOA_BASE+0x0c
.equ GPIOA_BSRR,       GPIOA_BASE+0x10
.equ GPIOA_BRR,        GPIOA_BASE+0x14
.equ GPIOA_LCKR,       GPIOA_BASE+0x18


.equ GPIOB_BASE,       APB2PERIPH_BASE + 0x0C00
.equ GPIOB_CRL,        GPIOB_BASE
.equ GPIOB_CRH,        GPIOB_BASE+0x04
.equ GPIOB_IDR,        GPIOB_BASE+0x08
.equ GPIOB_ODR,        GPIOB_BASE+0x0c
.equ GPIOB_BSRR,       GPIOB_BASE+0x10
.equ GPIOB_BRR,        GPIOB_BASE+0x14
.equ GPIOB_LCKR,       GPIOB_BASE+0x18


.equ GPIOC_BASE,       APB2PERIPH_BASE + 0x1000
.equ GPIOC_CRL,        GPIOC_BASE
.equ GPIOC_CRH,        GPIOC_BASE+0x04
.equ GPIOC_IDR,        GPIOC_BASE+0x08
.equ GPIOC_ODR,        GPIOC_BASE+0x0c
.equ GPIOC_BSRR,       GPIOC_BASE+0x10
.equ GPIOC_BRR,        GPIOC_BASE+0x14
.equ GPIOC_LCKR,       GPIOC_BASE+0x18


.equ USART1_BASE,      APB2PERIPH_BASE + 0x3800
.equ USART1_SR,        USART1_BASE 
.equ USART1_DR,        USART1_BASE+0x04
.equ USART1_BRR,       USART1_BASE+0x08
.equ USART1_CR1,       USART1_BASE+0x0C
.equ USART1_CR2,       USART1_BASE+0x10
.equ USART1_CR3,       USART1_BASE+0x14
.equ USART1_GTPR,      USART1_BASE+0x18

.equ USART2_BASE,      APB1PERIPH_BASE + 0x4400
.equ USART2_SR,        USART2_BASE 
.equ USART2_DR,        USART2_BASE+0x04
.equ USART2_BRR,       USART2_BASE+0x08
.equ USART2_CR1,       USART2_BASE+0x0C
.equ USART2_CR2,       USART2_BASE+0x10
.equ USART2_CR3,       USART2_BASE+0x14
.equ USART2_GTPR,      USART2_BASE+0x18


.equ RCC_BASE,         AHBPERIPH_BASE + 0x1000
.equ RCC_CR,           RCC_BASE
.equ RCC_CFGR,         RCC_BASE+0x04
.equ RCC_CIR,          RCC_BASE+0x08
.equ RCC_APB2RSTR,     RCC_BASE+0x0C
.equ RCC_APB1RSTR,     RCC_BASE+0x10
.equ RCC_AHBENR,       RCC_BASE+0x14
.equ RCC_APB2ENR,      RCC_BASE+0x18
.equ RCC_APB1ENR,      RCC_BASE+0x1C
.equ RCC_BDCR,         RCC_BASE+0x20
.equ RCC_CSR,          RCC_BASE+0x24
.equ RCC_AHBRSTR,      RCC_BASE+0x28
.equ RCC_CFGR2,        RCC_BASE+0x2C

.equ RCC_APB2ENR_IOPAEN,      0x0004           
.equ RCC_APB2ENR_IOPBEN,      0x0008           
.equ RCC_APB2ENR_IOPCEN,      0x0010           
.equ RCC_APB2ENR_USART1EN,    0x4000
