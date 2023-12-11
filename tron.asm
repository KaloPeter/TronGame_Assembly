
data 	SEGMENT public		
	delay 	DW 	0
	
	P1_color1 	DB	0
	P1_exCol1  	DB  0
	P1_dirX1	DB	0;P1_direction X
	P1_dirY1	DB	0;P1_direction Y
	P1_color_head DB 0
	
	P2_color2	DB	0
	P2_exCol2	DB	0
	P2_dirX2	DW	0;di P2_direction X
	P2_dirY2	DW	0;si P2_direction Y
	P2_color_head DB 0

	borderColor DB 0; can be modified from parameter
	Background DB 0; has to be modified at 3 places
	
	x_p1 DB 0
	y_p1 DB 0
	
data 	ENDS

code    SEGMENT
assume CS:Code, DS:Data, SS:Stack
jmp Menu

Menu:
	CALL SetForMenu
	
	mov ax,03h
	int 10h
	
	mov ah,02h
	mov bh,0
	mov dh,0
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Memu_Title
	int 21h
	
	mov ah,02h
	mov bh,0
	mov dh,0
	mov dl,0
	int 10h
	
	
Input:
	mov ah,02h
	mov bh,0
	mov dh,1
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_Start
	int 21h
	
	mov ah,02h
	mov bh,0
	mov dh,2
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_Exit
	int 21h
	
	mov ah,02h
	mov bh,0
	mov dh,3
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_UserInter
	int 21h
	
	xor ax,ax
	int 16h
	
	cmp al,49
	jz Start_Programm
	
	cmp al,50
	jz JumpEnd_Everything
	
	jmp Input

SetForMenu:
	mov ax, Code
	mov ds,ax
RET
	
;***************************************************************************
JumpEnd_Everything:
jmp Exit_Programm
;***************************************************************************
; graphic mode
Start_Programm:
; mode to display content
MOV AL, 13h
MOV AH, 0
INT 10h

xor dx,dx
xor cx,cx
;***********************************************************************************************;BORDER
	mov borderColor,10;-------------------------------------------------------------BorderColor(LightGreen)
	mov dx,0;Y
	mov cx,0;X

LeftBorder:;From Top Left to Bottom Left
	cmp dx,199;to see the bottom pixel border line
	jz BottomBorder
	MOV AH, 0Ch
	MOV AL, borderColor
	INT 10h
	inc dx
	
	jmp LeftBorder

BottomBorder:;From bottom left to bottom right
	cmp cx,255
	jz RightBorder
	MOV AH, 0Ch
	MOV AL, borderColor
	INT 10h
	inc cx
	
	jmp BottomBorder

RightBorder:;From bottom right to Top Right
	cmp dx,0
	jz TopBorder
	MOV AH, 0Ch
	MOV AL, borderColor
	INT 10h
	dec dx
	jmp RightBorder

TopBorder:;From Top right to top left
	cmp cx,0
	jz SetBackground;Initialize
	MOV AH, 0Ch
	MOV AL, borderColor
	INT 10h
	dec cx
	jmp TopBorder
;***************************************************
SetBackground:
	mov Background,0;---------------------------------------------------BACKGROUND
	mov dx,1;go from 1 to 198 down(Y)
	mov cx,1;go from 1 to 255 right(X)
	mov bx,cx; storing start position for background draw each row
GoRight:
		cmp cx,255;if the row is filled
		jz GoDown;go to next row, and start from the beginning(left side)
		MOV AH, 0Ch;put down pixel
		MOV AL, Background;put down pixel
		INT 10h;put down pixel

		inc cx;in row, put down the next pixel by goind right
		jmp GoRight;reat until row is filled
GoDown:
	cmp dx,198;we are the the bottom
	jz Initialize;we are at the bottom means, we filled the game area, go initilize players,etc...
	inc dx;next row
	mov cx,bx;to start from the left side again
	jmp GoRight;repeat the filling process, until another row is filled
	
Initialize:
;****************************************************
xor dx,dx
xor cx,cx

xor di,di
xor si,si

MOV BL, 100;Player_1 X
MOV BH, 20;Player_2 Y

mov di,150;Player_2 X
mov si,20;Player_2 Y
;PLAYER_1;*************************************************************************
MOV P1_dirX1, 0 ; (+1-> go right, -1=> go left)
MOV P1_dirY1, 1 ; go down(+1), go up(-1)
MOV P1_exCol1, 0
MOV P1_color1, 42;orange
MOV P1_color_head,12;red
;PLAYER_2;*************************************************************************
mov P2_dirX2,0	
mov P2_dirY2,1
mov P2_exCol2,0
mov P2_color2,11;light blue
MOV P2_color_head,1;dark blue

JMP mainLoop 
;**********************************************************************************
Set_P1_Head:	
	MOV AH, 0Ch
	MOV AL, P1_color_head;12;P1_color1
	INT 10h
	RET

Set_P2_Head:
	MOV AH, 0Ch
	MOV AL, P2_color_head;1;P2_color2
	INT 10h
	RET
	
P1_fReadPxl:
	MOV AH, 0Dh
	INT 10h
	CMP P1_dirX1, 0
	JZ P1_withExColor
	CMP P1_dirY1, 0
	JNZ P1_withOutExColor 
	P1_withExColor:
	MOV P1_exCol1, AL
	P1_withOutExColor:
	
	RET
	
P2_fReadPxl:
	MOV AH, 0Dh
	INT 10h
	CMP P2_dirX2, 0
	JZ P2_withExColor
	CMP P2_dirY2, 0
	JNZ P2_withOutExColor 
	P2_withExColor:
	MOV P2_exCol2, AL
	P2_withOutExColor:

	RET
	
;***************************************************************
fCheckCollision:
;Here we check if player left the area-> specifying the right-left-top-bottom border positions
	CMP CL, 0 ;CMP posX1, 0 left side of area
	JZ common_yes_collision
	CMP DL, 0 ;CMP posY1, 0 top side of area
	JZ common_yes_collision
	CMP CL, 255 ;CMP posX1, right side of area
	JZ common_yes_collision
	CMP DL, 200 ;CMP posY1, bottom of area
	JZ common_yes_collision	
RET
common_yes_collision:;Check which player left the map, so the other player won.
	cmp si,0;P2
		jz JumpToPlayer1_WON
	cmp si,200;P2
		jz JumpToPlayer1_WON
	
	cmp di,0;P2
		jz JumpToPlayer1_WON
	
	cmp di,255;P2
		jz JumpToPlayer1_WON
	
	cmp bl,0;P1
		jz JumpToPlayer2_WON
		
	cmp bl,255;P1
		jz JumpToPlayer2_WON
		
	cmp bh,0;P1
		jz JumpToPlayer2_WON
	
	cmp bh,200;P1
		jz JumpToPlayer2_WON

JumpToPlayer1_WON:	
	jmp P1_WON_endProgram
JumpToPlayer2_WON:
	jmp P2_WON_endProgram
;***************************************************************
Check_P1_SelfHit:
	push bx;store value of bx in stack, so we can put put background color code into bx
	mov bl,Background
	
	CMP P1_exCol1, bl;background color(black)---------------------------------------------------BACKGROUND
	JZ P1_no_collision
	
	pop bx; we put back original bx value from stack to bx
	
	jmp P2_WON_endProgram;endProgram
P1_no_collision:	
	pop bx
RET

Check_P2_SelfHit:
	push bx
	mov bh,Background
	
	CMP P2_exCol2, bh;background color(black)----------------------------------------------------BACKGROUND
	JZ P2_no_collision
	
	pop bx
	
	jmp P1_WON_endProgram
P2_no_collision:
	pop bx
RET
;***************************************************************
P1_updateData proc
		add bl, P1_dirX1
		mov Cl, bl
	
		add bh, P1_dirY1
		MOV Dl,bh
		
		push ax; I am putting pressed key code into stack, because ax regsiter gonna be used to draw Player_1 pixel
		
		CALL P1_fReadPxl 
		CALL Set_P1_Head
		xor ax,ax; after the drawings happend, i am clearing ax regsiter to put back pressed key code from stack
		pop ax; putting back pressed key code to ax register from stack so I can check it in Player_2
		jmp P1_AfterUpdate
P1_updateData endp
;***************************************************************
P2_updateData proc
		add di,P2_dirX2
		mov cx,di
		
		add si,P2_dirY2
		mov dx,si
		
		CALL P2_fReadPxl
		CALL Set_P2_Head
	
	JMP AfterP1P2Update
P2_updateData endp
;***************************************************************
mainLoop:
	xor ax,ax
	mov ah,01h
	int 16h
	JZ P1_AfterKeyb;If no key was pressed, we simply call Player_1 update, if not empty, we start handling it in P1_handleKeyBoard
	CALL P1_handleKeyBoard
	P1_AfterKeyb:
	JMP UpdateP1
	P1_AfterUpdate:
	CALL fCheckCollision;Check player1 left map-> Here DX,CX caontain P1 position data
	CALL Check_P1_SelfHit
	CALL P2_handleKeyBoard
	AfterP1P2Update:
	CALL fCheckCollision;check player2 left map-> Here DX,CX caontain P2 position data
	CALL Check_P2_SelfHit

	
	mov x_p1,BL
	mov y_p1,BH
	xor cx,cx
	xor dx,dx
	xor ax,ax
	xor bx,bx
	;https://programmersheaven.com/discussion/229386/delay-using-int-1ah
	mov bx,0;with 18 it is going to be 1 seconds

	INT 1ah ; took out subint because you only need this
	add bx, dx ; now bx holds the desired num. of ticks
	
	WaitMore:
	
	INT 1ah ; took out subint because you only need this
	
	cmp dx, bx ; compare DX and BX
	jg Draw ; if DX is greater then BX exit loop
	jmp WaitMore ;loop

	Draw:
	xor dx,dx
	xor ax,ax
	xor cx,cx
	xor bx,bx
	
	mov bl,x_p1
	mov bh,y_p1

;	MOV delay, 64000;32768 ; speed of game/tron players
;	loopDelay:
;		DEC delay
;		JNZ loopDelay
	
CALL SET_P1_LINE;Draw line after player_1
CALL SET_P2_LINE;Draw line after player_2
	
	JMP mainLoop

UpdateP1:
	JMP P1_updateData

SET_P1_LINE:
	mov Cl, bl
	MOV Dl,bh

	MOV AH, 0Ch
	MOV AL, P1_color1
	INT 10h
	
RET		
SET_P2_LINE:
	mov cx,di
	mov dx,si
	
	MOV AH, 0Ch
	MOV AL, P2_color2
	INT 10h
	
	
RET
;**************************************************************************Player_1 Direction
P1_NLeft:
	CMP P1_dirX1, 0
	JNE P1_jumpToUpdateData
	MOV P1_dirX1, -1
	MOV P1_dirY1, 0
	JMP P1_jumpToUpdateData
P1_NRight:
	CMP P1_dirX1, 0		
	JNE P1_jumpToUpdateData
	MOV P1_dirX1, 1
	MOV P1_dirY1, 0
	JMP P1_jumpToUpdateData
P1_NUp:
	CMP P1_dirY1, 0		
	JNE	P1_jumpToUpdateData
	MOV P1_dirX1, 0
	MOV P1_dirY1, -1
	JMP P1_jumpToUpdateData
P1_NDown:
	CMP P1_dirY1, 0
	JNE P1_jumpToUpdateData
	MOV P1_dirX1, 0
	MOV P1_dirY1, 1
	JMP P1_jumpToUpdateData
	
P1_jumpToUpdateData:
		jmp P1_updateData

;**************************************************************************Player_2 Direction
P2_NLeft:
	CMP P2_dirX2, 0	
	JNE P2_backToMainLoop
	MOV P2_dirX2, -1
	MOV P2_dirY2, 0
	JMP P2_backToMainLoop
P2_NRight:
	CMP P2_dirX2, 0		
	JNE P2_backToMainLoop
	MOV P2_dirX2, 1
	MOV P2_dirY2, 0
	JMP P2_backToMainLoop
P2_NUp:
	CMP P2_dirY2, 0		
	JNE	P2_backToMainLoop
	MOV P2_dirX2, 0
	MOV P2_dirY2, -1
	JMP P2_backToMainLoop
P2_NDown:
	CMP P2_dirY2, 0
	JNE P2_backToMainLoop
	MOV P2_dirX2, 0
	MOV P2_dirY2, 1
	JMP P2_backToMainLoop

P2_backToMainLoop:
	JMP P2_updateData
;**************************************************************************
;**************************************************************************
P1_handleKeyBoard proc
	MOV AH, 00h  ;get key
	INT 16h
	P1_pressed:
		CMP AH, 4Bh		; narrow left
		JE JumpTo_P1_NLeft
		CMP AH, 4Dh		; narrow right
		JE JumpTo_P1_NRight
		CMP AH, 48h		; narrow up
		JE JumpTo_P1_NUp
		CMP AH, 50h		; narrow down
		JE JumpTo_P1_NDown
	
	jmp P1_AfterKeyb
P1_handleKeyBoard endp

JumpTo_P1_NLeft:
	jmp P1_NLeft
JumpTo_P1_NRight:
	jmp P1_NRight
JumpTo_P1_NUp:
	jmp P1_NUp
JumpTo_P1_NDown:
	jmp P1_NDown

;****************************************************************************
P2_handleKeyBoard proc	

;Concept:we go into Player_1 handleKeyboard to check movement, if not found(wasd), we chek it here, if not found here either, we just update data
	P2_pressed:
		CMP AL, "a"		;left
		JE JumpTo_P2_NLeft
		CMP Al, "d"		;right
		JE JumpTo_P2_NRight
		CMP Al, "w"		;up
		JE JumpTo_P2_NUp
		CMP Al, "s"		;down
		JE JumpTo_P2_NDown
	
	jmp P2_updateData
P2_handleKeyBoard endp

JumpTo_P2_NLeft:
	jmp P2_NLeft
JumpTo_P2_NRight:
	jmp P2_NRight
JumpTo_P2_NUp:
	jmp P2_NUp
JumpTo_P2_NDown:
	jmp P2_NDown
;*****************************************************************************
endProgram:
jmp Exit_Programm
;*************************END/EXIT********************************************
P1_WON_endProgram:
	CALL SetForMenu
	mov AX, 3	
	int 10h
	
	mov ah,09h
	mov dx, offset Player1_WON
	int 21h
	jmp END_MENU
	
P2_WON_endProgram:
	CALL SetForMenu
	mov AX, 3
	int 10h
	
	mov ah,09h
	mov dx, offset Player2_WON
	int 21h
	jmp END_MENU

END_MENU:
Input2:
	mov ah,02h
	mov bh,0
	mov dh,1
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_Restart
	int 21h
	
	mov ah,02h
	mov bh,0
	mov dh,2
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_Exit
	int 21h
	
	mov ah,02h
	mov bh,0
	mov dh,3
	mov dl,0
	int 10h
	
	mov ah,09h
	mov dx, offset Menu_UserInter
	int 21h
	
	xor ax,ax
	int 16h
	
	cmp al,49
	jz JumpTo_StarProgramm
	
	cmp al,50
	jz Exit_Programm
	
	jmp Input2
	
JumpTo_StarProgramm:
jmp Start_Programm


Exit_Programm:
	mov AX, 3		
	int 10h
	mov AH, 4Ch		
	mov AL, 00h
	int 21h


Memu_Title: DB "**TRON**$"
Menu_Start: DB "1-Start Game$"
Menu_Exit: DB "2-Exit$"
Menu_Restart: DB "1-Restart Game$"
Menu_UserInter: DB "Please select menu:$"
Player1_WON: DB "Player1 Won!(Orange)$"
Player2_WON: DB "Player2 Won!(Blue)$"

code    ENDS

Stack Segment

Stack Ends

END
