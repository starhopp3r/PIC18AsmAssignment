		LIST P=18F97J60			; Directive to define processor
		#include <P18F97J60.INC>	; Processor specific variable definition
		config XINST = OFF              
		config FOSC = HS
		config WDT = OFF
				
		ORG		0x0000
ResetV	goto	MAIN				; Skip over interrupt vectors

		ORG		0x0008
HPISR						; High Priority Interrupt Service Routine
		retfie				
		ORG		0x0018
LPISR						; Low Priority Interrupt Service Routine
		retfie
		ORG		0x0100		; Suggest starting address for codes
		
MAIN					
		movlw 0x00			; TRISJ = 0x00	
		movwf TRISJ,0
		
		movlw 0xFF			; TRISB = 0xFF	
		movwf TRISB,0
		
		movlw 0x00			; PORTJ = 0x00
		movwf PORTJ,0
		
		movlw 0xFF			; PORTB = 0xFF
		movwf PORTB,0
		
		movlw b'01111111'		; T2CON = 0b01111111
		movwf T2CON,0			; Enable tmr2, prescaler=16, postscaler=16
		
		movlw d'244'			; PR2 = 244
		movwf PR2,0
				
		bra loop			; while (1)
		
blinkslow:	movlw d'100'			; Produce a long delay
		movwf 0x00,0			; Use memory location 00 as count
		return
		
blinkfast:	movlw d'10'			; Produce a short delay
		movwf 0x00,0			; Use memory location 00 as count
		return
		
loop		
		btfss PORTB,RB0,0		; Check if RB0 is 1, if yes skip next instruction
		bra loop
		
		btfss PIR1,TMR2IF,0		; while (PIR1bits.TMR2IF == 0);
		bra loop
		
		decf 0x00,1,0			; Decrement loop counter
		bcf PIR1,TMR2IF,0		; Clear the flag before using
		bnz loop			; Loop again if flag is zero
		
		btg PORTJ,RJ0,0			; Toogle RJ0 every 1 second
		
		btfss PORTB,RB1,0		; Check if RB1 is 1, if yes skip next instruction
		call blinkfast			; Blink fast if RB1 is 1
		
		btfsc PORTB,RB1,0		; Check if RB1 is 0, if yes skip next instruction
		call blinkslow			; Blink slow if RB1 is 0
		bra loop
		
		END
