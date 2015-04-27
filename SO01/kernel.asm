[ORG 0x0000]		
[BITS 16]
	
	cli
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ax,0x9000
	mov ss,ax
	mov sp,0xFFFF	
	sti
	
	mov si,info
	call print
	mov ax,0x0
	int 16h
	int 19h

print:				; funcion print
	mov ah,0x0E		; funcion 0E de la BIOS que pone un caracter (int 10)
start:
	lodsb			; carga en al lo que hay en ds:si e incrementa si
	cmp al,0		; compara al con 0 ( fin de cadena )
	jz end			; si es cero termina
	int 10h			; llama a la funcion que pone el caracter
	jmp start		; vuelve a start
end:
	ret			; vuelve al que lo llamo

info	db 13,10,'NUCELO activado y funcionando, culaquier tecla para salir',0