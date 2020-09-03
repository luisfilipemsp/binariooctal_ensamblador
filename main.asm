section .data  ; Datos inicializados y constantes.
	ESC_Borrar db 27, "[2J"
	L_ESC_Borrar equ $ - ESC_Borrar    ; Declaro para usar en la funcion Clear (borra la pantalla)
	
	ESC_Intro    db 27, "[02;02H"
	L_ESC_Intro  equ $ - ESC_Intro     ; Posición de donde voy imprimir el primer texto. Longitud.
	
	Introducion db "Introduce 0 para salir", 0h              ; Cadena de caracteres, que es la información al usuario que puede
	L_Cad_Intro  equ $ - Introducion						 ; salir al introducir 0.  Longitud del texto.
	
	Posicion_PregC db 27, "[04;02H"            ; Posición del próximo texto, que es la pregunta de que tipo de conversión quiere.
	L_ESC_PreguntaC equ $ - Posicion_PregC	   ; Longitud.
	
	PreguntaConversion db "Introduce tipo de conversación (1.-D a B, 2.-D a O): ", 0h  ; Pregunta del tipo de conversión
	L_PreguntaC		equ $ - PreguntaConversion                         				   ; Longitud del texto 
	
	PosicionPConver db 27, "[04;55H"  			; Posición de donde yo voy a introducir el número que deseo (la opción, el tipo 
	L_PosicionPConver equ $ - PosicionPConver	; de conversión). Longitud de la cadena.
	
	PosicionInNu  db 27, "[06;02H"          ; Posición del próximo texto, que es sú numero y que debe ser menor que "9999"
	L_PosicionInNu 	equ $ - PosicionInNu    ; Longitud
	
	InNumeroDec db "Introduce número en décimal (< 9999): ", 0h  ; Pregunta del número en decimal menor que "9999"
	L_InNumeroDec 	equ $ - InNumeroDec		; Longitud del texto.
	
	PosicionNumeroMenorQue9999 db 27, "[06;40H"		; Posición de donde yo voy a introcir el número en decimal
	L_PNMQ9999 equ $ - PosicionNumeroMenorQue9999   ; Longitud
	
	ESC_NumeroResultante db 27, "[10;02H"	; Posición del próximo texto, número resultante
	L_ESC_NumeroResultante equ $ - ESC_NumeroResultante   ; Longitud
	
	NumeroResultante db "Número resultante: ", 0h  ; Texto de donde voy a poner el número resultante de la opción binaria o octal.
	L_NumeroResultante equ $ - NumeroResultante	   ; Longitud
	
	Posicion_MError db 27, "[14;02H"      ; Posición del próximo texto, error
	L_PosicionError equ $ - Posicion_MError	; Longitud
	
	MError db "******** E R R O R ********", 0h  ; Texto que me sale al introducir una opción que no existe.
	L_MError equ $ - MError	; Longitud del texto
	
	Posicion_OtraOp db 27, "[12;02H"   ; Posición que voy usar para preguntar si quiere otra operación.
	L_POtraOp equ $ - Posicion_OtraOp ; Longitud
	
	OtraOp db "¿Otra operación (S/N)?:", 0h  ; Texto que pregunta si quiere otra operación después que termina una.
	L_OtraOp equ $ - OtraOp ; Longitud del texto
	
	CaptarOp db 27, "[12;26H"     ; Posición de donde voy a introducir el caracter S/s o N/n, si quiere otra operación o no.
	L_CaptarOp equ $ - CaptarOp	; Longitud
	
	Posicion_Tipo db 27, "[08;02H"    ; Posición del tipo de operación actual. Binaria o Octal.
	L_PNB equ $ - Posicion_Tipo
	
	Num_B db "      ********** Número BINARIO **********", 0h; Texto del tipo de operación, Binaria.
	L_Num_B equ $ - Num_B ; Longitud del texto
	
	Num_O db "      ********** Número OCTAL **********", 0h  ;  Texto del tipo de operación, Octal.
	L_Num_O equ $ - Num_O	; Longitud del texto
	
	Potencia dw 1000, 100, 10, 1    ; Usamos para pasar cada byte (cada número) de forma correcta a "Valor" con multiplicación.
	Valor dw 0			; Donde guardaremos nuestro número introducido al principio.
	Numero1 times 16 db "0"		; Uso para guardar los resultados de las divisiones en binario.
	Numero2 times 5 db "0"      ; Uso para guardar los resultados de las divisiones en octal. 
	
timeval:	; Para uso del "sleep" en el error.
	tv_sec dd 0  ; 32 bit seconds
	tv_usec dd 0 ; 32 bit nanoseconds
	
section .bss ; Variables definidas por el programador.
    Numero_A resb 2    ; Numero que recibo en caracter + enter. Para eligir que operación quiero.
    Numero_C resb 5    ; Variable para el numero que desea converter el usuario.
    Numero_E resb 5    ; Variable para el numero en octal.
    Numero_F resb 16   ; Variable para el numero en binario.    
    
section .text
	global _start ; Donde comienza la ejecución del programa

_start: ; 'main'
	Call Clear  ; Llamo a la función 'Clear'
	
											; Pongo a cero todo lo que voy a usar 
											; por cuenta de que podemos volver a 
    mov DWORD[Numero_A], 0					; hacer otra operación, así no habrá				
                                            ; conflictos caso haya más de una operación.
    mov esi, 0    ; Esi a 0 para auxiliar en el vector.
    Call Cincos_aCero   ; Pongo a cero variables en común.
    		  		
	mov ecx, ESC_Intro 	; Posicion de la primera mensaje
	mov edx, L_ESC_Intro   ; Longitud
	Call Imprimir    ; Llamo al procedimiento 'Imprimir'

	mov ecx, Introducion ; Escribe la primera línea "Introduce 0 para salir"
	mov edx, L_Cad_Intro ; Longitud
	Call Imprimir ; Llamo al procedimiento 'Imprimir'
	
	mov ecx, Posicion_PregC  ; Posicion de la primera mensaje, si quiere decimal o octal
	mov edx, L_ESC_PreguntaC  ; Longitud
	Call Imprimir ; Llamo al procedimiento 'Imprimir'
	
	mov ecx, PreguntaConversion  ; La pregunta si quiere decimal o octal
	mov edx, L_PreguntaC      ; Longitud
	Call Imprimir ; Llamo al procedimiento 'Imprimir'
	
	mov ecx, PosicionPConver
	mov edx, L_PosicionPConver   ; Posicion de donde va pillar el numero de la respuesta.
	Call Imprimir  ; Llamo al procedimiento 'Imprimir'
	
	mov ecx, Numero_A    ; Introduce el numero(caracter) en ecx
	mov edx, 2    ; Dos bytes, el numero + enter
	Call Leer ; Llamo a la función 'Leer'
	
	
	mov al, BYTE[Numero_A]    ; Muevo el caracter a al
	sub al, 48     ; Transformo en numero
	
Switch:  ; Caso donde la operacion eligida es decimal a binario

	cmp al, 1  ; Comparo al con 1 
	jne Case2  ; Salto si no igual a 1 al Case2
	
	mov ecx, PosicionInNu
	mov edx, L_PosicionInNu ; Posiciona la cadena de caracteres
	Call Imprimir 			
	
	mov ecx, InNumeroDec
	mov edx, L_InNumeroDec            ; Imprime el texto para pedir el numero
	Call Imprimir
	
	mov ecx, PosicionNumeroMenorQue9999
	mov edx, L_PNMQ9999     ; Posiciona para coger el número introducido por el Usuario
	Call Imprimir 
	
	mov ecx, Numero_C
	mov edx, 5        ; Lleva el numero a Numero_E y a edx, de 5 posiciones con 4 numeros + enter
	Call Leer 
	
	mov esi, 0     ; esi y edi auxilia a percorrer los 'vectores'.
	
	mov edi, 0
	
	Call ConverteANumero  ; LLamo a 'ConverteANumero'
;FinConversion:	
	mov esi, 0   ; Esi a 0 para auxliar en el vector.
	
Cero:    ; Pongo a cero ("0") Numero_1 y Numero_F
	 cmp esi, 15 ; Comparo esi con 15
	 ja Salir_Cero ; Si superior a 15 salto a Salir_Cero
	 mov BYTE[Numero1 + esi], "0"
	 mov BYTE[Numero_F + esi], "0"
	 inc esi  ; esi+1
	 jmp Cero ; Salto incondicional a Cero
Salir_Cero:

	mov ax, WORD[Valor]
	mov bx, 2   ; Pongo bx a 2.
	mov esi, 0  ; esi a 0.

	Call DivisionBinaria  ; Llamo a DivisionBinaria
;PrepararVector  
	mov esi, 0  ; Pongo esi a 0
	mov edi, 15 ; edi a 15, para hacer el recorrido al revés. 
	
	Call Paso_Numero_aVariable ; LLamo a Paso_Numero_aVariable
;Salir_PSN:      
	mov ecx, Posicion_Tipo
	mov edx, L_PNB  ; Posicionamos para imprimir el tipo actual de operación.
	Call Imprimir
	
	mov ecx, Num_B 
	mov edx, L_Num_B  ; Imprimimos la mensaje informando el tipo de operación (que es binaria).
	Call Imprimir
	
	mov ecx, ESC_NumeroResultante
	mov edx, L_ESC_NumeroResultante   ; Posicionamos la mensaje del número resultante en pantalla.
	Call Imprimir

	mov ecx, NumeroResultante 
	mov edx, L_NumeroResultante ; Imprimimos en pantalla el texto para informar el número convertido de decimal a binario.
	Call Imprimir 
	
	mov ecx, Numero_F   ; El número ya en binario, lo imprimo en pantalla.
	mov edx, 16
	Call Imprimir
	
	Call Fin  ; Llamo a Fin.
	 
	mov al, BYTE[Numero_A]    ; Muevo el caracter a al.
	cmp al, "S"   ; Comparo al con S.
	je _start  ; Si es igual, salto al principio del programa pues el usuario desea hacer más una operación.
	cmp al, "s"   ; Comparo al con s.
	je _start   ; Si es igual, salto al principio del programa pues el usuario desea hacer más una operación.
	;Si al no es igual a S o s acaba el progama.
	Call Exit
	
Case2:
	cmp al, 2 ; Comparo al 
	jne Case3 ; Salto si no igual a 2 al Case3
	
	mov ecx, PosicionInNu
	mov edx, L_PosicionInNu ; Posiciona la cadena de caracteres
	Call Imprimir 
	
	mov ecx, InNumeroDec
	mov edx, L_InNumeroDec       ; Imprime el texto para pedir el numero
	Call Imprimir
	
	mov ecx, PosicionNumeroMenorQue9999
	mov edx, L_PNMQ9999     ; Posiciona para coger el numero introducido por el Usuario
	Call Imprimir 
	
	mov ecx, Numero_C    ; El número que quiero que va de decimal a octal.
	mov edx, 5
	Call Leer
	
	mov esi, 0     ; Pongos esi y edi a cero para me axuliar en el recorrido del 'vector'.
	mov edi, 0
	
	Call ConverteANumero2  ; LLamo a ConverteANumero2
	
;FinConversion2: ; Cargo en ax la dirección de Valor.
	mov ax, WORD[Valor]
	mov bx, 8 ; Cargo bx con 8
	mov esi, 0  ; esi con 0.
	
	Call DivisionO  ; Llamo DivisionO
;PrepararVector2:  
	mov esi, 0     ; Pongo esi a 0 y edi a 4, para auxiliar en los vectores.
	mov edi, 4
	
	Call Pasar_Numero_aVariableO ; Llamo Pasar_Numero_aVariableO
;Salir_PSNo:
	mov ecx, Posicion_Tipo
	mov edx, L_PNB    ; Posiciono el tipo de operacción actual, que es octal.
	Call Imprimir
	
	mov ecx, Num_O
	mov edx, L_Num_O  ; Imprimo de pantalla la información de que es una operación octal.
	Call Imprimir
	
	mov ecx, ESC_NumeroResultante
	mov edx, L_ESC_NumeroResultante   ; Posiciono donde voy escribir el texto del número resultante.
	Call Imprimir

	mov ecx, NumeroResultante 
	mov edx, L_NumeroResultante  ; Imprimo el texto del número resultante.
	Call Imprimir 
	
	mov ecx, Numero_E   ; Imprimo el número resultante, el número ya en octal.
	mov edx, 5
	Call Imprimir
	
	Call Fin ; Llamo a Fin.
	
	mov al, BYTE[Numero_A]    ; Muevo el caracter a al.
	cmp al, "S"   ; Comparo al con S.
	je _start  ; Si es igual, salto al principio del programa pues el usuario desea hacer más una operación.
	cmp al, "s"   ; Comparo al con s.
	je _start   ; Si es igual, salto al principio del programa pues el usuario desea hacer más una operación.
	;Si al no es igual a S o s acaba el progama.
	Call Exit
	
Case3:   ; Caso donde la elicción es salir.
	cmp al, 0
	jne Default_Case  ; Si no es igual a 0.
	Call Exit ; Si es, acaba el progama.
	
Default_Case:  ; Si no es ninguna opción.
	mov ecx, Posicion_MError
	mov edx, L_PosicionError   ; Posiciono la mensaje de error.
	Call Imprimir
	
	mov ecx, MError
	mov edx, L_MError    ; Imprimo la mensaje de error.
	Call Imprimir
	
	mov dword [tv_sec], 2      ; espera 2 segundos y vuelve al principio 	
	mov dword [tv_usec], 0
	mov eax, 162               ; sys_nanosleep	
	mov ebx, timeval	
	mov ecx, 0
	int 80h
	
	jmp _start  ; Salto al comienzo, pues un error no es ninguna opción...
	
Fin:
	mov DWORD[Numero_A], 0	; Pongo las variable a cero para que yo pueda usarla de nuevo.
    
	mov ecx, Posicion_OtraOp
	mov edx, L_POtraOp   ; Posiciono donde voy imprimir la pregunta de otra operación.
	Call Imprimir
	
	mov ecx, OtraOp
	mov edx, L_OtraOp    ; Imprimo en pantalla el texto, preguntando si el usuario quiere hacer otra operación. 
	Call Imprimir
	
	mov ecx, CaptarOp
	mov edx, L_CaptarOp  ; Posiciono en pantalla para poder introducir la elección del usuario.
	Call Imprimir
	
	mov ecx, Numero_A  ; Pongo la elección en Numero_A.
	mov edx, 2   ; Elección + Enter.
	Call Leer  ; Llamo al procedimiento 'Leer'.
	
	ret 
		
					; **** PROCEDIMENTOS *****
	
Clear:  ; Borra la pantalla
	mov ecx, ESC_Borrar
	mov edx, L_ESC_Borrar
	Call Imprimir 
	ret 

Exit: ; Encerra el progama
	mov ebx, 0 ; Llama a la funcion exit (sys_exit)
	mov eax, 1 ; Código de Retorno (0 = Sin errores)
	int 80h ;  Llamos al Sistema Operativo.
		
Imprimir:  ; Imprime en pantalla
	mov ebx, 1 	  ;stdout
	mov eax, 4	  ;LLama al sistema (sys_write).
	int 80h		  ; Llamamos al Sistema Operativo.
	ret

Leer:    ; Leer 'algo' introducido por teclado.
	mov ebx, 0
	mov eax, 3
	int 80h
	ret

 Cincos_aCero:               ; Pongo a cero variables en común. Que sus posiciones van de 0 a 4.
	cmp esi, 4     ; Comparo esi a 4
	ja Salir_aC	   ; Si es superior a 4 salto a Salir_aC
		
	mov BYTE[Numero_C + esi], 0
	mov BYTE[Numero_E + esi], 0
	mov BYTE[Valor + esi], 0
	mov BYTE[Numero2 + esi], "0"
	inc esi
	Call Cincos_aCero
	Salir_aC:	
	ret
	
					; **** BINARIO ****
					
ConverteANumero:  ; Aqui converte los caractes a número y pasar a 'Valor'.
	cmp esi, 3    ; Salto si esi es superior a 3, compara esi que empieza a 0.
	ja FinConversion ; A la etiqueta 'FinConversion'.
	
	xor ax, ax   ; ax a cero, para siempre poder almacenar un nuevo número.
	mov al, BYTE[Numero_C + esi]     ; En la posición que tiene esi, muevo el BYTE a al.
	sub al, 48   ; Le resto 48, para tonarle un número, por cuenta del código ASCII.
	mov bx, WORD[Potencia + edi]  ; Multiplico el contenido que tengo en Potencia que es determinado por edi
	mul bx						  ; que es bx*ax. 
	add WORD[Valor], ax   ; Muevo el valor de la multiplicación que esta en ax a Valor.
	add esi, 1    ; Añado +1 a esi.
	add edi, 2    ; Añado +1 a edi.
	Call ConverteANumero ; Vuelvo a la etiqueta actual.
	FinConversion: ; Cargo en ax la dirección de Valor.
	ret 
	
DivisionBinaria:  ; Aqui hago la division para salir mi resultado final, mi número decimal a binario.
	xor dx, dx ; Pongo dx a cero para que siempre sea posible tener un número nuevo.
	div bx     ; División; dx = ax/bx. El resto va a dx, consciente a ax.
	add dl, 48	; Añado + 48 para que sea el respectivo número en código ASCII entonces así sea imprimible.
	mov BYTE[Numero1 + esi], dl ; Paso el 'caracter' que representa el número en ASCII.
	inc esi  ; Incremento esi en una unidad.
	cmp ax, 0  ; Compara ax con cero.
	je PrepararVector   ; Salto si igual a 'PrepararVector'.
	Call DivisionBinaria ; Si no, vuelve a la etiqueta actual.
	PrepararVector: ; Preparo para poner el resultado en mi vector para imprimirlo en pantalla.
	ret
	
Paso_Numero_aVariable: ; Paso el número a la variable hecha para recibir su valor binario
	cmp esi, 15   ; Comparo si esi tiene el valor de 15.
	ja Salir_PSN  ; Si hay salto a la etiqueta donde imprimo en pantalla el resultado final esperado por el usuario.
	; Si no...
	mov al, BYTE[Numero1 + esi]  ; Muevo lo que hay en Numero1, en la posición determinado por esi a al.
	mov BYTE[Numero_F + edi], al ; Lo que hay en al paso a Numero_F, la variable determinada por el programador para recibir el resultado final de la operación binaria.
	inc esi  ; Incremento esi en una unidad.
	dec edi  ; Decremento edi en una unidad.
	Call Paso_Numero_aVariable  ; Vuelvo a la etiqueta actual.
	Salir_PSN: ; Imprimos el resultado, nuestro número ya en binario en pantalla del terminal.
	ret
	

				; ***** OCTAL *****

ConverteANumero2:   ; Aquí donde yo hago la conversión de caracter a número.
	cmp esi, 3     ; Comparo y veo si es 3
	ja FinConversion2 ; Si es mayor que 3 salto a 'FinConversion2'.
	
	xor ax, ax    ; ax a cero, para siempre poder almacenar un nuevo nuevo.
	mov al, BYTE[Numero_C + esi] ; En la posición que tiene esi, muevo el BYTE a al.
	sub al, 48			; Le resto 48, para tonarle un número, por cuenta del código ASCII.
	mov bx, WORD[Potencia + edi]  ; Multiplico el contenido que tengo en Potencia que es determinado por edi
	mul bx						  ; que es bx*ax.
	add WORD[Valor], ax		; Muevo el valor de la multiplicación que esta en ax a Valor.
	add esi, 1		; Añado +1 a esi.
	add edi, 2		; Añador +1 a edi.
	Call ConverteANumero2	; Vuelvo a la etiqueta actual.
	FinConversion2:
	ret

DivisionO:  ; Donde hago la división binaria.
	xor dx, dx ; Pongo dx a cero para que siempre sea posible tener un número nuevo.
	div bx	; División; dx = ax/bx. El resto va a dx, conciente a ax.
	add dl, 48 ; Añado + 48 para que sea el respectivo número en código ASCII entonces así sea imprimible.
	mov BYTE[Numero2 + esi], dl ; Paso el 'caracter' que representa el número en ASCII.
	inc esi ; Añado +1 a esi.
	cmp ax, 0   ; Comparo ax con 0.
	je PrepararVector2 ; Salto si igual a 'PrepararVector'.
	Call DivisionO  ; Si no es, vuelvo a la misma etiqueta.
	PrepararVector2: ; Preparo el vector para pasar mi resultado final, mi número ya en octal.
	ret

Pasar_Numero_aVariableO:  ; Paso el resultado a mi variable para imprimirla en pantalla.
	cmp esi, 4  ; Comparo esi con 4
	ja Salir_PSNo ; Si hay salto a la etiqueta donde imprimo en pantalla el resultado final esperado por el usuario.
	; Si no...
	mov al, BYTE[Numero2 + esi] ; Muevo lo que hay en Numero2, en la posición determinado por esi a al.
	mov BYTE[Numero_E + edi], al ; Lo que hay en al paso a Numero_F, la variable determinada por el programador para recibir el resultado final de la operación binaria.
	inc esi ; Incremento esi en una unidad.
	dec edi  ; Decremento edi en una unidad.
	Call Pasar_Numero_aVariableO ; Salto incodicional a la etiqueta actual.
	Salir_PSNo:  ; Salgo a imprimir el resultado...
	ret
