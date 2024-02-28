.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
includelib emu8086.inc
extern exit: proc
extern printf: proc
extern scanf: proc 
extern strlen: proc 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
msg db "Introduceti expresia:", 0
n_line DB 0AH, 0   ;afisare linie noua

numere dd 50 dup(0)    ;AICI VOM RETINE NUMERELE
aux dd 0
rez_final dq 0
format db "%s", 0
format1 db "%d", 0 
format2 db "%c", 0  
format3 db "%f", 0     
format4 db "%lf", 0   

semn db 50 dup(0)        ;AICI RETINEM SEMNELE DIN EXPRESIA CITITA

.code
start:
	push offset msg
	call printf 
	add ESP, 4
	
	push offset n_line
	call printf
	add ESP, 4
	
	mov ESI, 0
	mov EDI, -1
	
	citire_cifra:
	
	mov EAX, offset numere
	add EAX, ESI
	push EAX
	push offset format3  ;citire expresie
	call scanf
	add ESP, 4*2
	cmp numere[ESI], 10  
	je outside
	
	add ESI, 4
	
	citire_semn:
	inc EDI
	mov EBX, offset semn
	add EBX, EDI
	push EBX
	push offset format2
	call scanf
	add ESP, 4*2
	
	cmp semn[EdI], '='  
	jne citire_cifra

	mov ESI, 0
	mov EDI, 0
	calcul_prio:
		comp:
		cmp numere[ESI], 0
		je final_calcul
		cmp numere[ESI], '?'
		je next_nr1
		cmp semn[EDI], '0' ; inmultire/impartire primele
		je next_nr1
		cmp semn[EDI], '*' 
		je inmultire
		cmp semn[EDI], '/'
		je impartire
		jmp next_nr1
		inmultire:
	;2.2+6*4+5-4.2/2=
			finit   ; initializeaza co-procesorul
			fld numere[ESI]  ; pun prima valoare pe stiva
			fld numere[ESI+4] ;pun al doilea nr pe stive, +4 pt ca numere e dd
			fmul	; inmultire
			fstp numere[ESI+4] ; stocare in al doilea nr
			mov numere[ESI], '?' ; marcat ca gol
			mov semn[EDI], '0'
			inc EDI
			add ESi, 4 ; trec la urm nr
			jmp comp
		impartire:
			finit
			fld numere[ESI]
			fld numere[ESI+4]
			fdiv
			fstp numere[ESI+4]
			mov numere[ESI], '?'
			mov semn[EDI], '0'
			inc EDI
			add ESi, 4
			jmp comp
		next_nr1:
			add ESI, 4
			inc EDI
			jmp comp	
		final_calcul:
		
		
		
		mov ESI, 0
		mov EDI, 0
		comp2:
		cmp numere[ESI], 0
		je outside
		cmp numere[ESI], '?'
		je next_nr2
		cmp semn[ESI], '='
		je outside
		cmp semn[EDI], '+'
		je adunare
		cmp semn[EDI], '-'
		je scadere
		jmp next_nr2
		adunare:
			push numere[ESI]  ; nu mai sunt 2 nr invecinate tot timpul, tinem minte primul nr valid
			mov numere[ESI], '?'
			mov semn[EDI], '0'
			nr_2:
				add ESI, 4
				inc EDI  				;cautam un al nr valid
				cmp numere[ESI], '?'
			je nr_2
			pop aux ; o valoare auxiliara unde stocam primul nr valid
			finit
			fld aux  ; load primul nr
			fld numere[esi] ; load nr gasit
			fadd ; adunare
			fstp numere[esi] ;stocare in al doilea nr gasit
			
			jmp comp2
		scadere:
			push numere[ESI]
			mov numere[ESI], '?'
			mov semn[EDI], '0'
			nr_3:
			add ESI, 4
			inc EDI
			cmp numere[ESI], '?'
			je nr_3
			pop aux
			finit
			fld aux
			fld numere[esi]
			fsub
			fstp numere[esi]
			
		
		jmp comp2
		
		next_nr2:
			add ESI, 4
			inc EDI
			jmp comp2
		
	outside:
		finit 
		fld numere[ESI-4]
		fstp rez_final
		
		push dword ptr [rez_final+4]
		push dword ptr [rez_final]
		push offset format4
		call printf
		add ESP, 12
	
	push 0
	call exit
end start