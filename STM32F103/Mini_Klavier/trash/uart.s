;******************************************************************************
;* C) Copyright HTL - HOLLABRUNN  2009-2011 All rights reserved. AUSTRIA      * 
;*                                                                            * 
;* File Name:   Uart.s                                                        *
;* Autor: 		Josef Reisinger                                               *
;* Version: 	V1.00                                                         *
;* Date: 		12/11/2011                                                    *
;* Description: Ausgabe eines Textes via Uart                                 *
;******************************************************************************
;* History: 	12.11.2011: REJ                                               *
;*  		 	creation V1.00	            			                      *
;******************************************************************************

        		AREA UART, CODE, READONLY
				INCLUDE STM32_F103RB_MEM_MAP.INC
				EXPORT __main

hello_txt 		DCB "Hello World\r\n",0	;null terminated hello

; -------------------------- MAIN Programm ------------------------------------
__main			PROC
				MOV      r0,#9600
				BL       uart_init
				
				LDR 	 R0,=hello_txt
				BL       uart_put_string

__main_endless	B		__main_endless				 ; Endlosschleife	
                ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_init                         *
;*                                                                            *
;* Aufgabe:   Initialisiert USART1                                            *
;* Input:     R0....Baudrate                                                  *
;* return:	 	                                                              *
;******************************************************************************
uart_init			PROC
					LDR      R1,=RCC_APB2ENR		  ; GPIOA mit einem Takt versorgen 
					LDR		 R1,[R1]
					ORR      R1,R1,#0x4
					LDR      R2,=RCC_APB2ENR
					STR      R1,[R2]
    
					LDR      R1,=GPIOA_CRH  ; loesche PA.9 (TXD-Leitung) configuration-bits  
					LDR		 R1,[R1]
					BIC      R1,R1,#0xF0
					LDR      R2,=GPIOA_CRH
					STR      R1,[R2]

					MOV      R1,R2	   ; TX (PA9) - alt. out push-pull 
					LDR      R1,=GPIOA_CRH
					LDR		 R1,[R1]
					ORR      R1,R1,#0xB0
					STR      R1,[R2]

					MOV      R1,R2		;loesche PA.10 (RXD-Leitung) configuration-bits  
					LDR      R1,=GPIOA_CRH
					LDR		 R1,[R1]
					BIC      R1,R1,#0xF00
					STR      R1,[R2]

					MOV      R1,R2		; Rx (PA10) - inut floating 
					LDR      R1,=GPIOA_CRH
					LDR		 R1,[R1]
					ORR      r1,r1,#0x400
					STR      R1,[R2]

					LDR      R1,=RCC_APB2ENR    ; USART1 mit einem Takt versrogen 
					LDR		 R1,[R1]
					ORR      r1,r1,#0x4000
					LDR      R2,=RCC_APB2ENR
					STR      R1,[R2]

					LDR      R1,=baudrate_const  ; Baudrate für USART festlegen  
					LDR	 	 R1,[R1]
					UDIV     r1,r1,r0
					LDR      R2,=USART1_BRR
					STRH     R1,[R2]

					LDR      R1,=USART1_CR1		   ; aktiviere RX, TX 
					LDR      R1,[R1]
					ORR      R1,R1,#0x0C		   ; USART_CR1_RE = 1, (= Receiver Enable Bit)
					LDR      R2,=USART1_CR1		   ; USART_CR1_TE = 1, (= Transmitter Enable Bit) 
					STR      R1,[R2]

					LDR      R1,=USART1_CR1		   ; aktiviere USART 
					LDR      R1,[R1]
					ORR      R1,R1,#0x2000		   ; USART_CR1_UE = 1  (= UART Enable Bit)
					LDR      R2,=USART1_CR1
					STR      R1,[R2]
					BX       LR
                    ENDP
					
baudrate_const		DCD		8000000


;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_put_char                     *
;*                                                                            *
;* Aufgabe:   Ausgabe eines Zeichens auf USART1                               *
;* Input:     R0....Zeichen                                                   *
;* return:	 	                                                              *
;******************************************************************************
uart_put_char	   PROC
				   LDR      R1,=USART1_SR		 ;Data Transmit Register leer? 
				   LDR      R1,[R1]
				   TST      R1,#0x80	 ; USART_SR_TXE = 1 (Last data already transferred ?)
				   BEQ		uart_put_char
				   LDR      R1,=USART1_DR
				   STR      r0,[r1]
				   BX       LR
				   ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_put_string                   *
;*                                                                            *
;* Aufgabe:   Ausgabe einer Zeichenkette (C Konvention) USART1                *
;* Input:     R0....Zeiger auf Sting                                          *
;* return:	                        	                                      *
;******************************************************************************
uart_put_string		PROC
					PUSH     {lr}
					MOV      r2,r0				 ; R2 = Anfangsadresse von String
					B        _check_eos
_next_char			LDRB     r0,[r2],#0x01
					BL       uart_put_char
_check_eos			LDRB     r0,[r2,#0x00]
					CMP      r0,#0x00	       ; '\0' Zeichen ? 
					BNE      _next_char
					POP      {PC}
					ENDP
					
					ALIGN

				END

