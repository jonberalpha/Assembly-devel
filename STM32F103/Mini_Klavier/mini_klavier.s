;******************************************************************************
;* File Name:   mini_klavier.s                                                *
;* Autors:      Berger Jonas, Geyer Markus                                    *
;* Version:     V01                                                           *
;* Time-period: 14/12/2017 - 17/12/2017                                       *
;* Description: UEber die "Klaviertasten" (Schalter PA0-PA7), soll            *
;*              auf dem Piezo (PB0) die Tonleiter (c-c') wiedergegeben werden.*
;*              Zusaetzlich sollen Informationen und Einstellungen            *
;*              in Form eines Textes ueber die RS232 uebertragen und          *
;*              auf ein Terminal-Programm angezeigt werden.                   *
;* ADD-ON: Um den betaetigten Schalter deutlich anzuzeigen                    *
;*         wird die darueber liegende Led eingeschaltet.                      *
;******************************************************************************
;* Abgabedatum: 21/12/2017                                                    *
;* creation V01                                                               *
;******************************************************************************
AREA mini_klavier, CODE, READONLY
INCLUDE STM32_F103RB_MEM_MAP.INC
EXPORT __main

;----------------------- U A R T - D E F I N I T I O N E N ----------------------
welc_txt  DCB "Mini-Klavier V01\r\n\r\n",0  ; beim Programmstart ausgegeben
c_txt     DCB "Schalter 1 wurde gedrueckt\r\nDer Piezo spielt den Ton c mit einer Frequenz von 523Hz\r\n\r\n",0    ;wenn Schalter 1 gedrueckt wird ausgeben
d_txt     DCB "Schalter 2 wurde gedrueckt\r\nDer Piezo spielt den Ton d mit einer Frequenz von 587Hz\r\n\r\n",0    ;wenn Schalter 2 gedrueckt wird ausgeben
e_txt     DCB "Schalter 3 wurde gedrueckt\r\nDer Piezo spielt den Ton e mit einer Frequenz von 660Hz\r\n\r\n",0    ;wenn Schalter 3 gedrueckt wird ausgeben
f_txt     DCB "Schalter 4 wurde gedrueckt\r\nDer Piezo spielt den Ton f mit einer Frequenz von 698Hz\r\n\r\n",0    ;wenn Schalter 4 gedrueckt wird ausgeben
g_txt     DCB "Schalter 5 wurde gedrueckt\r\nDer Piezo spielt den Ton g mit einer Frequenz von 784Hz\r\n\r\n",0    ;wenn Schalter 5 gedrueckt wird ausgeben
a_txt     DCB "Schalter 6 wurde gedrueckt\r\nDer Piezo spielt den Ton a mit einer Frequenz von 880Hz\r\n\r\n",0    ;wenn Schalter 6 gedrueckt wird ausgeben
h_txt     DCB "Schalter 7 wurde gedrueckt\r\nDer Piezo spielt den Ton h mit einer Frequenz von 988Hz\r\n\r\n",0    ;wenn Schalter 7 gedrueckt wird ausgeben
cs_txt    DCB "Schalter 8 wurde gedrueckt\r\nDer Piezo spielt den Ton c' mit einer Frequenz von 1046Hz\r\n\r\n",0  ;wenn Schalter 8 gedrueckt wird ausgeben

; -------------------------- D E F I N I T I O N E N ---------------------------
Piezo     EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+0*4   ; Bit Band Adresse PB0 (Leitunung PB0)
LED0      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+8*4   ; Bit Band Adresse PB8 (Leitunung LED0)
LED1      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+9*4   ; Bit Band Adresse PB9 (Leitunung LED1)
LED2      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+10*4  ; Bit Band Adresse PB10 (Leitunung LED2)
LED3      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+11*4  ; Bit Band Adresse PB11 (Leitunung LED3)
LED4      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+12*4  ; Bit Band Adresse PB12 (Leitunung LED4)
LED5      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+13*4  ; Bit Band Adresse PB13 (Leitunung LED5)
LED6      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+14*4  ; Bit Band Adresse PB14 (Leitunung LED6)  
LED7      EQU   PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+15*4  ; Bit Band Adresse PB15 (Leitunung LED7)


;******************************************************************************
;*                          M A I N  P r o g r a m m:                         *
;******************************************************************************

__main        PROC
              MOV    R0,#9600    ; Baudrate auf 9600 setzen
              BL     uart_init
              LDR    R0,=welc_txt
              BL     uart_put_string
              
              MOV    R6,#00          ; Output value auf PB0 = 0
              BL     init_ports
              
              MOV    R7,#0x00    ; Vergleichsregister fuer Textausgabe
        
_main_again   LDR    R0,=GPIOA_IDR
              LDR    R0,[R0]          ; Load PAO - PA15
              AND    R5,R0,#0x0FF
        
              LDR    R0,=GPIOB_ODR
              LDR    R0,[R0]
              AND    R0,R0,#0x00
              LDR    R1,=GPIOB_ODR
              STR    R0,[R1]
        
              BL     calc_inits    ; verarbeite Schalterstellung
              CBNZ   R4,again    ; Abfrage ob kein Schalter gedrueckt wurde
              
              CMP    R5,R7      ; Abfrage ob R5 = R7
              BEQ    jp_sound    ; wenn gleich gib keinen Text aus
              BL     out_txt
        
jp_sound      BL     do_sound
again         B      _main_again
              ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    out_txt                           *
;*                                                                            *
;* Aufgabe:   Auswahl der Textausgabe                                         *
;* Input:     R5...welcher Schalter wurde gedrueckt                           *
;* return:    R7...fuer die Abfrage im Main-Programm                          *
;******************************************************************************
out_txt   PROC
          push  {R0,R1,R2,LR}     ; save link register to Stack
      
          MOV   R7,R5       ; fuer die Abfrage im Main-Programm: R7 nun gesetzt
      
          SUB   R1,R7,#0x5EC
          CBNZ  R1,d_jp
          LDR   R0,=c_txt    ; Ausgabe c_txt
          BL    uart_put_string
      
d_jp      SUB   R1,R7,#0x546
          CBNZ  R1,e_jp
          LDR   R0,=d_txt    ; Ausgabe d_txt
          BL    uart_put_string
        
e_jp      SUB   R1,R7,#0x4B0
          CBNZ  R1,f_jp
          LDR   R0,=e_txt    ; Ausgabe e_txt
          BL    uart_put_string

f_jp      SUB   R1,R7,#0x460
          CBNZ  R1,g_jp
          LDR   R0,=f_txt    ; Ausgabe f_txt
          BL    uart_put_string

g_jp      SUB   R1,R7,#0x3F0
          CBNZ  R1,a_jp
          LDR   R0,=g_txt    ; Ausgabe g_txt
          BL    uart_put_string

a_jp      SUB   R1,R7,#0x382
          CBNZ  R1,h_jp
          LDR   R0,=a_txt    ; Ausgabe a_txt
          BL    uart_put_string

h_jp      SUB   R1,R7,#0x325
          CBNZ  R1,cs_jp
          LDR   R0,=h_txt    ; Ausgabe h_txt
          BL    uart_put_string
        
cs_jp     SUB   R1,R7,#0x300
          CBNZ  R1,ende
          LDR   R0,=cs_txt    ; Ausgabe cs_txt
          BL    uart_put_string
        
ende      POP   {R0,R1,R2,PC}      ;restore link register to Programm Counter and return
          ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    init_ports                        *
;*                                                                            *
;* Aufgabe:   Initialisiert Portleitungen f�r LED / Schalterplatine u. USART  *
;* Input:     keine                                                           *
;* return:    keine                                                           *
;******************************************************************************
init_ports    PROC
              push {R0,R1,R2,LR}     ; save link register to Stack      
              
              ;Clock GPIOB
              MOV  R2, #0x08        ; enable clock for GPIOB  (APB2 Peripheral clock enable register)
              LDR  R1,  =RCC_APB2ENR
              LDR  R0, [R1]
              ORR  R0,  R0, R2
              STR  R0, [R1]
              ;Clock GPIOA
              MOV  R2, #0x4          ; enable clock for GPIOA (APB2 Peripheral clock enable register)
              LDR  R1,  =RCC_APB2ENR 
              LDR  R0, [R1]
              ORR  R0,  R0, R2
              STR  R0, [R1]
              ;Schalter Config
              LDR  R1,  =GPIOA_CRL     ; set Port Pins PA0-PA7 to Pull Up/Down Input mode (50MHz) - Schalter S0-S7
              LDR  R0, =0x88888888
              STR  R0, [R1]

              ;Pull-Up fuer Schlter aktivieren
              LDR  R1,  =GPIOA_ODR     ; GPIOA Output Register auf "1" sodass Input Pull Up aktiviert ist!!  
              LDR  R0, =0xFFFFFFFF
              STR  R0, [R1]
              ;LED config
              LDR  R1,  =GPIOB_CRH     ; set Port Pins PB8-PB15 (LED0) to Push Pull Output Mode (50MHz)
              LDR  R0, [R1]
              LDR  R2, =0x00000000   
              AND  R0,  R0, R2       ;set config to null
              MOV  R2, #0x33333333     ;mit 3333... ganzes CRH Register auf -> Output Push Pull
              ORR  R0,  R0, R2
              STR  R0, [R1]
              ;Piezo (PB0) config
              LDR  R1,  =GPIOB_CRL     ; set Port Pins PB8 (LED0) to Push Pull Output Mode (50MHz)
              LDR  R0, [R1]
              LDR  R2, =0x00000000   
              AND  R0,  R0, R2       ;set config to null
              MOV  R2, #0x03         ;mit 3333... ganzes CRL Register auf -> Output Push Pull
              ORR  R0,  R0, R2
              STR  R0, [R1]       ;finished config CRH

              POP  {R0,R1,R2,PC}     ;restore link register to Programm Counter and return
              ENDP        

;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_init                         *
;*                                                                            *
;* Aufgabe:   Initialisiert USART1                                            *
;* Input:     R0....Baudrate                                                  *
;* return:                                                                   *
;******************************************************************************
uart_init       PROC
                LDR      R1,=RCC_APB2ENR  ; GPIOA mit einem Takt versorgen 
                LDR      R1,[R1]
                ORR      R1,R1,#0x4
                LDR      R2,=RCC_APB2ENR
                STR      R1,[R2]
            
                LDR      R1,=GPIOA_CRH    ; loesche PA9 (TXD-Leitung) configuration-bits  
                LDR      R1,[R1]
                BIC      R1,R1,#0xF0
                LDR      R2,=GPIOA_CRH
                STR      R1,[R2]

                MOV      R1,R2           ; TX (PA9) - alt. out push-pull 
                LDR      R1,=GPIOA_CRH
                LDR      R1,[R1]
                ORR      R1,R1,#0xB0
                STR      R1,[R2]

                MOV      R1,R2        ; loesche PA10 (RXD-Leitung) configuration-bits  
                LDR      R1,=GPIOA_CRH
                LDR      R1,[R1]
                BIC      R1,R1,#0xF00
                STR      R1,[R2]

                MOV      R1,R2        ; RX (PA10) - input floating 
                LDR      R1,=GPIOA_CRH
                LDR      R1,[R1]
                ORR      r1,r1,#0x400
                STR      R1,[R2]

                LDR      R1,=RCC_APB2ENR    ; USART1 mit einem Takt versrogen 
                LDR      R1,[R1]
                ORR      R1,R1,#0x4000
                LDR      R2,=RCC_APB2ENR
                STR      R1,[R2]

                LDR      R1,=baudrate_const ; Baudrate f�r USART festlegen  
                LDR      R1,[R1]
                UDIV     R1,R1,R0
                LDR      R2,=USART1_BRR
                STRH     R1,[R2]

                LDR      R1,=USART1_CR1    ; aktiviere RX, TX 
                LDR      R1,[R1]
                ORR      R1,R1,#0x0C    ; USART_CR1_RE = 1, (= Receiver Enable Bit)
                LDR      R2,=USART1_CR1    ; USART_CR1_TE = 1, (= Transmitter Enable Bit) 
                STR      R1,[R2]

                LDR      R1,=USART1_CR1    ; aktiviere USART 
                LDR      R1,[R1]
                ORR      R1,R1,#0x2000    ; USART_CR1_UE = 1  (= UART Enable Bit)
                LDR      R2,=USART1_CR1
                STR      R1,[R2]
                BX       LR
                ENDP
          
baudrate_const  DCD    8000000

;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_put_char                     *
;*                                                                            *
;* Aufgabe:   Ausgabe eines Zeichens auf USART1                               *
;* Input:     R0....Zeichen                                                   *
;* return:                                                                   *
;******************************************************************************
uart_put_char   PROC
                LDR      R1,=USART1_SR     ;Data Transmit Register leer? 
                LDR      R1,[R1]
                TST      R1,#0x80        ; USART_SR_TXE = 1 (Last data already transferred ?)
                BEQ      uart_put_char
                LDR      R1,=USART1_DR
                STR      R0,[R1]
                BX       LR
                ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    uart_put_string                   *
;*                                                                            *
;* Aufgabe:   Ausgabe einer Zeichenkette (C Konvention) USART1                *
;* Input:     R0....Zeiger auf Sting                                          *
;* return:                                                                  *
;******************************************************************************
uart_put_string   PROC
                  PUSH     {LR}
                  MOV      R2,R0         ; R2 = Anfangsadresse von String
                  B        _check_eos
_next_char        LDRB     R0,[R2],#0x01
                  BL       uart_put_char
_check_eos        LDRB     R0,[R2,#0x00]
                  CMP      R0,#0x00            ; '\0' Zeichen ? 
                  BNE      _next_char
                  POP      {PC}
                  ENDP
                  
                  ALIGN
          
      
;******************************************************************************
;*            U N T E R P R O G R A M M:    calc_inits                        *
;*                                                                            *
;* Aufgabe:   verarbeitet die IN-Ports                                        *
;* Input:     R5...Schalterstellung                                           *
;* return:    R5...Periodendauer des Rechtecksignals                          *
;******************************************************************************
calc_inits    PROC
              push   {R0-R3,LR}       ; save link register to Stack

              MOV    R4,#0x00
              
              MOV    R0,#0x00    ; -> Kein Schalter gesetzt
              SUB    R1,R0,R5
              CBZ    R1, b_0
              
              MOV    R0,#0x080    ;-> C
              SUB    R1,R0,R5
              CBZ    R1, b_523
              
              MOV    R0,#0x040    ;-> D
              SUB    R1,R0,R5
              CBZ    R1, b_587
              
              MOV    R0,#0x020    ;-> E
              SUB    R1,R0,R5
              CBZ    R1, b_660
              
              MOV    R0,#0x010    ;-> F
              SUB    R1,R0,R5
              CBZ    R1, b_698
              
              MOV    R0,#0x08    ;-> G
              SUB    R1,R0,R5
              CBZ    R1, b_784
              
              MOV    R0,#0x04    ;-> A
              SUB    R1,R0,R5
              CBZ    R1, b_880_1
              
              MOV    R0,#0x02    ;-> H
              SUB    R1,R0,R5
              CBZ    R1, b_988_1
              
              MOV    R0,#0x01    ;-> C'
              SUB    R1,R0,R5
              CBZ    R1, b_1046_1
        
b_0           MOV    R4,#0x01
              B      exit

b_523         MOV    R5,#0x5EC
              MOV    R3,#01      ; fuer LED7
              LDR    R2,=LED7
              STR    R3, [R2]
              B      exit
        
b_587         MOV    R5,#0x546
              MOV    R3,#01      ; fuer LED6
              LDR    R2,=LED6
              STR    R3, [R2]  
              B      exit
        
b_660         MOV    R5,#0x4B0
              MOV    R3,#01      ; fuer LED5
              LDR    R2,=LED5
              STR    R3, [R2]
              B      exit

b_880_1       B      b_880_2      ;Zwischenspruenge
b_988_1       B      b_988_2
b_1046_1      B      b_1046_2
        
b_698         MOV    R5,#0x460
              MOV    R3,#01      ; fuer LED4
              LDR    R2,=LED4
              STR    R3, [R2]
              B      exit        
        
b_784         MOV    R5,#0x3F0
              MOV    R3,#01      ; fuer LED3
              LDR    R2,=LED3
              STR    R3, [R2]
              B      exit
        
b_880_2       MOV    R5,#0x382
              MOV    R3,#01      ; fuer LED2
              LDR    R2,=LED2
              STR    R3, [R2]
              B      exit        
        
b_988_2       MOV    R5,#0x325
              MOV    R3,#01      ; fuer LED1
              LDR    R2,=LED1
              STR    R3, [R2]
              B      exit
        
b_1046_2      MOV    R5,#0x300
              MOV    R3,#01      ; fuer LED0
              LDR    R2,=LED0
              STR    R3, [R2]
              B      exit
        
        
            
exit          POP   {R0-R3,PC}      ;restore link register to Programm Counter and return
              ENDP
            
              ALIGN
          
;******************************************************************************
;*            U N T E R P R O G R A M M:    do_sound                          *
;*                                                                            *
;* Aufgabe:   einen Ton ausgeben                                              *
;* Input:     R6...Im Hauptprogramm auf 0 initialisiert                       *
;* return:                                                                   *
;******************************************************************************
do_sound    PROC
            push   {R1,LR}         ; save link register to Stack
            
            LDR    R1,=Piezo       ; Ausgabe Bit0 von value auf LED0
            STR    R6,[R1]
            BL     wait_Xms      ; Warte 500ms
            MVN    R6,R6
                
            POP    {R1,PC}         ;restore link register to Programm Counter and return
            ENDP
            
            ALIGN



;******************************************************************************
;*            U N T E R P R O G R A M M:    wait_Xms                          *
;*                                                                            *
;* Aufgabe:   Wartet Xms                                                      *
;* Input:     R5...Periodendauer des Rechtecksignals                          *
;* return:                                                                   *
;******************************************************************************
wait_Xms        PROC
                push   {R0-R2,LR}     ; save link register to Stack
                MOV    R0,#0x01     ; dauerhaft auf 1
                MOV    R1,#0
wait_ms_loop    MOV    R2,R5       ; R5 calculated in UP calc_inits
wait_ms_loop1   SUB    R2,R2,#1
                CMP    R2,R1
                BNE    wait_ms_loop1
                SUB    R0,R0,#1
                CMP    R0,R1
                BNE    wait_ms_loop
                POP    {R0-R2,PC}     ;restore link register to Programm Counter and return
                ENDP
                
                ALIGN

                END
