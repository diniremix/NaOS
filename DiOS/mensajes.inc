saludo 	db 13,10,'Bienvenido a diOS v 0.01'
	db 13,10,'El unico sistema operativo, los otros son herejes'
	db 13,10,'Buscando Dios: Dios encontrado'
	db 13,10,'Buscando pecados del usuario: demasiados pecados'
	db 13,10,'escriba oh Dios! para ver los deseos disponibles',13,10,0

;######################## cadenas de SHELL.ASM ##############################

prompt	db 13,10,'Dios# ',0
cmd1	db 'oh Dios!',0
mCmd1	db 13,10,'Deseos disponibles:'
	db 13,10,' oh Dios!: muestra esta ayuda'
	db 13,10,' halt:     apaga el sistema'
	db 13,10,' reboot:   reinicia el sistema'
	db 13,10,' exit:     cierra el prompt'
	db 13,10,0

cmd2	db 'halt',0
mCmd2	db 'Apagando el sistema garacias por creer en DiOS',0

cmd3	db 'reboot',0
mCmd3	db 'reiniciando el sistema garacias por creer en DiOS',0

cmd4	db 'exit',0
mCmd4	db 'cerrando linea de comando',0

cmd5	db 'oh dios!',0
mCmd5	db 'Dios se escribe con mayuscula HEREJE!',0

mUnkCmd	db 'Deseo desconocido formulelo de nuevo o pida una se',164,'al',0

;####################### fin cadenas de SHELL.ASM ##########################