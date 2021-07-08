#INCLUDE<P16F887.INC> ; Liberia utilizada
__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
__CONFIG _CONFIG2, _WRT_OFF & _BOR21V

CBLOCK 0X20 							; Dirección de memoria para las variables
T1, T2, T3 								; Variables usadas en retardo
W_RES, STATUS_RES 						; Variables usadas en interrupción
CONT, PTA
ENDC

CBLOCK 0X30
UNIDAD, DECENA, CENTENA, MILLAR 		; Variables del programa principal
ENDC 

ORG 0X00 								; Origen del programa
GOTO CONFIGURAR							; Ir a la etiqueta configurar
ORG 0X04 								; Directiva de interrupción
GOTO INTERRUPCION 						; Ir a la etiqueta configurar

CONFIGURAR 
	CLRW 								; Limpiar a W
	BSF STATUS, RP0 					; RP0=1 del registro STATUS
	MOVLW 0X00 							; Cargar el valor a W
	MOVWF TRISB 						; Mover lo de W a TRISB
	MOVLW 0XF0 							; Cargar el valor a W
	MOVWF TRISA 						; Mover lo de W a TRISA
	BCF STATUS, RP0 					; RP0=0 del registro STATUS
	CLRF PORTA 							; Limpia PORTA
	CLRF PORTB 							; Limpia PORTB
	BSF PTA, 0 							; Poner el bit 0 de la variable PTA en 0

CONFI_TMR0 
	BSF STATUS, RP0
	MOVLW B'10100000' 					; Asignación de valores a las banderas del registro INTCON
	MOVWF INTCON
	BSF STATUS, RP0
	MOVLW B'10000101' 					; Asignación de valores a las banderas del registro OPTION_REG
	MOVWF OPTION_REG
	BCF STATUS, RP0
	MOVLW 0X00 							; Inicialización de la variable CONT MOVWF CONT

INICIO 
	MOVLW 0X00 								; Inicialización de la variable UNIDAD
	MOVWF UNIDAD
	MOVLW 0X00								; Inicialización de la variable DECENA
	MOVWF DECENA
	MOVLW 0X00
	MOVWF CENTENA 							; Inicialización de la variable CENTENA
	MOVLW 0X00
	MOVWF MILLAR		 					; Inicialización de la variable MILLAR

UNI 
	CALL RETARDO 	; Llama a la subrutina RETARDO
	INCF UNIDAD, 1 	; Incrementa la variable UNIDAD en 1
	MOVF UNIDAD, 0 	; Mueve el valor de UNIDAD a W
	SUBLW 0X09 		; Le resta el valor de 10 a W
	BTFSS STATUS, Z ; Testea la bandera Z
	GOTO UNI
	GOTO DECE		 ; Salto en caso de que el bit testeado es igual a 1

DECE 				; Etiqueta para las decenas
	CLRF UNIDAD 	; Limpia la variable UNIDAD
	INCF DECENA, 1	 ; Incrementa la variable DECENA en 1
	MOVF DECENA, 0	 ; Mueve el valor de DECENA a W
	SUBLW 0X06 		; Le resta el valor de 6 a W
	BTFSS STATUS, Z ; Testea la bandera Z
	GOTO UNI
	GOTO CENTE		 ; Salto en caso de que el bit testeado es igual a 1

CENTE			 	; Etiqueta para las centenas
	CLRF UNIDAD 	; Limpia la variable UNIDAD
	CLRF DECENA 	; Limpia la variable DECENA
	INCF CENTENA, 1 ; Incrementa la variable CENTENA en 1
	MOVF CENTENA, 0 ; Mueve el valor de CENTENA a W
	SUBLW 0X09 		; Le resta el valor de 9 a W
	BTFSS STATUS, Z ; Testea la bandera Z
	GOTO UNI
	GOTO MILL 		; Salto en caso de que el bit testeado es igual a 1

MILL 				; Etiqueta para los millares
	CLRF UNIDAD 	; Limpia la variable UNIDAD
	CLRF DECENA 	; Limpia la variable DECENA
	CLRF CENTENA 	; Limpia la variable CENTENA
	INCF MILLAR, 1 	; Incrementa la variable MILLAR en 1
	MOVF MILLAR, 0 	; Mueve el valor de la variable MILLAR a W
	SUBLW 0X06 		; Le resta el valor de 6 a W
	BTFSS STATUS, Z ; Testea la bandera Z
	GOTO UNI
	GOTO INICIO 	; Salto en caso de que el bit testeado es igual a 1

;********RUTINAS**********

INTERRUPCION 		; Etiqueta para la interrupción
	MOVWF W_RES 	; Mueve lo de W en la variable W_RES
	SWAPF STATUS, W ; Intercambia lo de STATUS y lo guarda en W
	MOVWF STATUS_RES ; Mueve lo de W en la variable STATUS_RES
	MOVF CONT, 0 	; Mueve lo de la variable CONT en W
	SUBLW 0X04 		; Resta 4 a W
	BTFSS STATUS, Z ; Testea la bandera Z
	GOTO CICLO
	CLRF CONT 		; Salto en caso de que el bit testeado es igual a 1
	CLRF PTA 		; Limpia la variable PTA
	BSF PTA, 0 		; Pone el bit 0 de la variable PTA en 0

CICLO 				; Etiqueta para ciclo
	MOVF CONT, 0 	; Mueve lo de la variable CONT en W
	ADDLW 0X30 		; Suma el valor de 30 a W
	MOVWF FSR 		; Mueve lo de W a la RAM
	MOVF INDF, 0 	; Mueve lo del registro INDF a W
	CALL TABLA 		; Llama a la subrutina tabla
	MOVWF PORTB 	; Mueve lo de W al registro PORTB
	MOVF PTA,0 		; Mueve lo de la variable PTA a W
	MOVWF PORTA
	INCF CONT, 1 	; Incrementa CONT y lo guarda en si mismo
	RLF PTA 		; Multiplica lo de W por 2
	SWAPF STATUS_RES, W
	MOVWF STATUS 	; Mueve lo de W a STATUS
	SWAPF W_RES, W_RES ; Intercambia lo de la variable W_RES
	SWAPF W_RES, W
	BCF INTCON, T0IF ; Limpia el bit T0IF del registro INTCON
	RETFIE 			; Return de la interrupción

TABLA 				; Tabla del 0 al 9 en hexadecimal
	ADDWF PCL,1 	; Suma PCL <- W+PCL
	RETLW B'0000001' ; 0
	RETLW B'1001111' ; 1
	RETLW B'0010010' ; 2
	RETLW B'0000110' ; 3
	RETLW B'1001100' ; 4
	RETLW B'0100100' ; 5
	RETLW B'0100000' ; 6
	RETLW B'0001111' ; 7
	RETLW B'0000000' ; 8
	RETLW B'0000100' ; 9

RETARDO 		; Etiqueta para el retardo
	MOVLW D'15' ; Retraso de 1 milisegundo
	MOVWF T1 	; Mueve a la variable T1
LOOP1
	MOVLW D'130' ; Carga el valor en decimal de 40 ciclos
	MOVWF T2	 ; Lo mueve a la variable T2
LOOP2
	MOVLW D'7'	 ; Carga el valor en decimal de 30 ciclos
	MOVWF T3 	; Lo mueve a la variable T3
LOOP3
	DECFSZ T3, 1 ; Decrementa el registro y salta si es cero
	GOTO LOOP3 	; Lo envía al loop3
	DECFSZ T2, 1 ; Decrementa el registro y salta si es cero
	GOTO LOOP2 	; Si no lo envía al loop2
	DECFSZ T1, 1 ; Decrementa si es cero salta
	GOTO LOOP1 	; Si no lo envía al loop1
	RETURN 		; Repite la instrucción

END