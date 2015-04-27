[ORG 0x7c00]		; en 0x7C00 se carga el contenido del primer sector
[BITS 16]		; 16 bits

;********************************************************************
;Información valida del sector de arranque de un disco de 1.44 Mb   * 
;Formateado en FAT12, esta información esta dada en Sistema Decimal *
;******************************************************************** 
	jmp iniboot
	db 'MSDOS5.0'
	dW 512		
	db 1		; Sectores por cluster
	dw 2		; Sectores reservados al principio
	db 2
	dw 224		; Número de entradas al directorio
	dw 2880
	db 240
	dw 9
	dw 18
	dw 2
	dd 0
	dd 0
	db 0
	db 0
	db 41
	dd 3705501369
	db 'NO NAME    '
	db 'FAT12   '

;Fin del sector de arranque información valida
;********************************************************************

;Inicio del resto del booteador que aconpaña el sector de arranque del
;disco

iniboot:
	
	push cs
	mov ax,0x9000
	cli
	pop ds
	mov ss,ax
	mov sp,0xFFFF
	sti
	
	mov ax,0x201		; Cargar el segundo sector
	mov bx,0x7e00		; que contiene el resto del booteador
	mov cx,0x2
	xor dx,dx
	int 13h 

	mov ax,0x3		; Seleccionar un modo de video
	int 10h 		

	mov si,creditos		; cargamos el mensaje
	call print		; llamamos a la funcion
	mov si,mQ
	call print
keypres:	
	mov ah,0		; Función para esperar un 
	int 16h			; tecla del usuario
	cmp ah,0x01		; Comparar si la tecla presionada es [ESC]
	je fin			; si es igual salta
	cmp ah,0x1c		; Comparar si la tecla presionada es [ENTER]
	je cargar		; si es igual salta
	mov si,mErrorKey	; si no ha sido ninguna de las anteriores	
	call print		; entonces imprimir Msm de Error
	jmp keypres		; Saltar

cargar:
	mov si,mloading		; Msm de carga del sistema
	call print
	call LeerDir		

fin:	
	mov si,mOff
	call print
	mov ah,0
	int 16h
	int 19h

;**********************************************************************
;Este bloque contiene las rutinas necesarias para cargar el DIRECTORIO*
;del Disquete, la FAT/12 y los cluster que contienen el KERNEL        *
;**********************************************************************
LeerDir:
	mov ax,0x020E		; Función para leer sector a memoria con 14 sectores  
	mov bx,0x8000		; Colocar sectores a partir de DS:BX
	mov cx,0x0003		; Cilindro (0) apartir del (2) sector valido
	mov dx,0x0100		; Cabezal (01) dispositivo (0)
	int 13h			
	
	call SearchKernel	; Llamada al bloque en busqueda del kernel en
				; los 14 sectores del directorio

MountFAT:
	mov ax,0x209		; Lo mismo que el anterior pero esta vez leer 9 sectores
	mov bx,0x8000		; correspondientes a la primera copia de la FAT
	mov cx,0x3		
	xor dx,dx
	int 13h

IniCluster:
	mov ax,[FAT]
	call ReadFAT
	call MountCluster
	cmp dx,0xFFF
	je controlKernel
	mov [FAT],dx
	jmp IniCluster	


SearchKernel:
	push bx

StarKernel:
	mov al,[bx]
	cmp al,0xE5		; Comparar si la fichero ha sido borrado
	je Incrementar		
	cmp al,0x0		; Comparar si el directorio esta vacio
	je NotFile

ReadName:
	mov cx,0x0006
	mov si,Nucleo

StarName:
	push ax
	push dx
	mov al,[bx]	
	
	mov dl,[si]
	cmp al,dl
	pop dx
	pop ax
	
	jnz Incrementar
	inc bx
	inc si
	dec cx
	cmp cx,0
	jnz StarName		; Si cx no es cero seguir leyendo

ReadIn:
	pop bx
	add bx,0x1a		; Incremento para leer entrada en la FAT posteriormente
	push dx
	mov dx,[bx]
	mov [FAT],dx
	pop dx
	ret

	
Incrementar:
	pop bx
	add bx,0x20
	push bx
	jmp StarKernel

NotFile:
	mov si,mNotfile
	call print
	mov ax,0
	int 16h
	jmp 0xFFFF:0x0000	; saltamos a FFFF:0000
	ret			; en realidad nunca va a volver pero...



controlKernel:
	mov si,mStarkernel	;borrar
	call print		;borrar
	jmp 0x1000:0x0000       ; saltamos a donde cargamos el Kernel

;************************************
; DX al final tendrá información    *
; sobre el cluster en donde se      *
; encuentra el KERNEL, ejmeplo FFF  *
;************************************

ReadFAT:
	push ax
	push bx
	add bx,ax
	shr ax,0x1
	pushf
	add bx,ax
	mov dx,[bx]
	popf
	jnc peek_fat_par
	push cx
	mov cl,0x4
	shr dx,cl
	pop cx

peek_fat_par:
	and dh,0x0F
	pop bx
	pop ax
	ret
	

;************************************
; Convierte sectores lógicos en BIOS*
; donde:    			    *
; AH - Sector			    *
; AL - Cara			    *
; DL - Cilindro			    *
;************************************

MountCluster:
	push ax			; Conserva los registros	
	push bx
	push dx
	
	sub ax,0x1
	add ax,0x21
	
	mov cl,0x12		; Para el sector BIOS
	div cl
	add ah,0x1
	mov dl,al		; Conserva en DL el cociente del resultado anterior

	push ax
	xor ax,ax
	mov al,dl
	mov cl,2
	div cl
	mov dl,ah
	pop ax
	mov al,dl
	
	push ax
	mov ax,[FAT]		; Para el cilindro
	sub ax,0x1
	add ax,0x21
	mov cl,0x24
	div cl
	mov dl,al		; Salva el cilindro
	pop ax

;************************************
; Las siguiente instruciones son    *
; para montar de los cluster el     *
; Kernel		 	    *
;************************************
	mov ch,dl		; Cilindro
	mov cl,ah		; Sector
	mov dh,al		; Cabeza
	mov dl,0		; Dispositivo
	mov ax,0x201		; Función para leer solo un sector
	mov bx,[OffSet]
	mov es,bx
	mov bx,[SegM]		
	int 13h
	add bx,0x200
	mov [SegM],bx
	pop dx
	pop bx
	pop ax
	ret		

;*********************************************************************

print:				; funcion print
	push ax
	mov ah,0x0E		; funcion 0E de la BIOS que pone un caracter (int 10)
start:
	lodsb			; carga en al lo que hay en ds:si e incrementa si
	cmp al,0		; compara al con 0 ( fin de cadena )
	jz end			; si es cero termina
	int 10h			; llama a la funcion que pone el caracter
	jmp start		; vuelve a start
end:
	pop ax
	ret			; vuelve al que lo llamo

OffSet		dw 4096
SegM		dw 0
creditos 	db 13,10,'Sistema Operativo v 0.01.'
		db 13,10,'Dise',164,'ado por: Carlos Arturo Lopera'
		db 13,10,'Monter',161,'a - C',162,'rdoba'
		db 13,10,'Colombia 2006',0
mQ		db 13,10,'Presione [Enter] para cargar el sistema, [ESC] para cancelar',0
mloading	db 13,10,'Cargando espere...',0
mErrorKey	db 13,10,'Tecla no valida, intente nuevamente',0
FAT		dw 0
mNotfile	db 13,10,'No se ha podido encontrar NUCLEO'
		db 13,10,'Retire cualquier disco de la unidad y presione una tecla',0
Nucleo 		db 'KERNO'
mStarkernel	db 13,10,'Activaci',162,'n del NUCLEO',0
mOff		db 13,10,'Retire cualquier disco y presione una tecla, el sistema seguira con otra unidad',0

