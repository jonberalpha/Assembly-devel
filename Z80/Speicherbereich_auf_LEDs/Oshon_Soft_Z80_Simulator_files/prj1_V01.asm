Anfang:  IN A, (00C0H)
         AND 80H
         JP Z, Anfang
         LD DE, 0000H
         LD HL, 1900H
         LD A, (1900H)
         LD B, A
loop1:   INC DE
         CALL Leucht
         DEC B
         JP NZ, loop1
         JP Anfang

Leucht:  ADD HL, DE
         LD A, (HL)
         INC HL
         LD C, (HL)
         OUT (00C0H), A
         LD A, B
         LD (18FFH), A
loop2:   CALL Wait
         DEC C
         JP NZ, loop2
         LD A, (18FFH)
         LD B, A
         RET

Wait:    LD A, C
         LD (18FEH), A
         LD B, 05H
loopB:   LD A, 21H
loopA:   LD C, 00H
loopC:   DEC C
         JP NZ, loopC
         DEC A
         JP NZ, loopA
         DEC B
         JP NZ, loopB
         LD A, (18FEH)
         LD C, A
         RET
