[org 0x0100] 
jmp start

clrscr:                       ; clear screen subroutine
push es
push ax
push cx
push di
push si

mov ax,0xB800
mov es,ax
mov di,0

mov ax,0x7420
mov cx ,2000

cld
rep stosw

pop si
pop di
pop cx
pop ax
pop es
ret

sleep:
push cx
mov cx, 0xFFFF
delay: 
loop delay
pop cx
ret


scroll:
 push bp 
 mov bp,sp 
 push ax 
 push cx 
 push si 
 push di 
 push es 
 push ds
 push bx
 
mov ah,06h
mov al,1
mov bh,0x74
mov cx,0x0019
mov dx,0x2545  
int 10h
 
 
mov dx,50  
l1: 
call sleep
dec dx
jnz l1
 
 pop bx
 pop ds 
 pop es 
 pop di 
 pop si 
 pop cx 
 pop ax 
 pop bp 
 ret  


location:                             ; location subroutine
push bp
push ax
push bx
push dx

mov byte al,80
mul byte bl                               
add ax,dx                       
shl ax,1
mov di,ax

pop dx
pop bx
pop ax
pop bp
ret

horizontal_line:                      ;horizontal line subroutine
push bp
push dx
push cx
push ax
push si

mov dx,[bp-14]
sub dx,[bp-18]
mov cx,dx
mov ah,[bp+28]

nextch1:                        
mov al,0x2A
stosw
loop nextch1

pop si
pop ax
pop cx
pop dx
pop bp
ret

vertical_line:                       ;verticle line subroutine
push bp                    
push dx
push cx
push ax
push si

mov dx,[bp-16]
sub dx,[bp-20]
mov cx,dx
mov ah,[bp+28]

nextch2:                        
mov al,0x2A
mov[es:di],ax
add di,160
loop nextch2

pop si
pop ax
pop cx
pop dx
pop bp
ret

random_number1:
push di
push bx
push dx 
push cx

mov ax,0
xor ax,ax
int 1Ah

mov ax,dx

xor dx,dx
mov bx,26
div bx
inc dx

add dx,1
mov ax,dx
add ax,0x40
mov ah,0x74

pop cx
pop dx
pop bx
pop di
ret

random_number2:
push di
push bx
push dx 

jmp main
check:
mov al,5Ah
jmp exit2
main:
mov ax,0
xor ax,ax
int 1Ah

mov ax,dx

xor dx,dx
mov bx,26
div bx
inc dx

add dx,5
mov ax,dx
add ax,0x40
mov ah,0x74
cmp al,5Ah
jg check

exit2:
pop dx
pop bx
pop di
ret

random_number3:
push di
push bx
push dx 
jmp main1
check1:
mov al,5Ah
jmp exit3
main1:
mov ax,0
xor ax,ax
int 1Ah

mov ax,dx

xor dx,dx
mov bx,26
div bx
inc dx

add dx,3
mov ax,dx
add ax,0x40
mov ah,0x74
cmp al,5Ah
jg check1

exit3:
pop dx
pop bx
pop di
ret

pop dx
pop bx
pop di
ret



create_balloon:                        ;balloon subroutine
push bp 
push es 
push di
push si
push bx
push dx
push ax
push cx


mov bx,[bp-20]
mov dx,[bp-18]

call location                  ; gives the location of top left co-ordinate on screen

mov [bp-2],di
add di,2

call horizontal_line
mov [bp-4],di

add di,160
call vertical_line

mov di,[bp-2]
add di,160
call vertical_line
mov [bp-6],di

mov di,[bp-6]
add di,2
call horizontal_line

; writing letter in the centre of balloon

mov si,[bp-16]        
sub si,[bp-20]
mov ax,si
shr ax,1
add ax,1
add ax,[bp-20]
mov bx,ax                  ;x co-ordinate of letter location on screen

mov si,[bp-14]
sub si,[bp-18]
mov ax,si
shr ax,1
add ax,1
add ax,[bp-18]
mov dx,ax                  ;y co-ordinate of letter location on screen

call location               ; gives location of random number in the balloon 
   
pop cx

cmp cx,0
je loop_1

cmp cx,1
je loop_2

call random_number3
mov [es:di],ax
jmp end

loop_2:
call random_number2
mov [es:di],ax
jmp end

loop_1:
call random_number1
mov word [es:di],ax

end:
pop ax
pop dx
pop bx
pop si
pop di
pop es
pop bp
ret


timer:
push bp
push es
push si
push di
push ax
push bx
push cx 

mov ax,0xb800
mov es,ax

mov bx,0
mov dx,11
call location
mov [bp-8],di

mov si,[bp-10]         

calculate_time:
mov ax,si

mov bx,10
mov cx,0

nextdigit:
mov dx,0                     ;dx stores the remainder
div bx                       ;divide ax by bx (base 10)
add dx,0x30                  ;convert remainder into its ascii value
push dx                      ;push remiander on stack 
inc cx
cmp ax,0
jnz nextdigit

cmp si,99
jle loop1

l2:
mov di,[bp-8]
jmp nextpos

loop1:
mov di,[bp-8]
cmp si,9
jle l3
mov word [es:26],0x7420
jmp nextpos

l3:
mov word [es:24],0x7420

nextpos:
pop dx                       ;takes remainder in reverse order from stack
mov dh,0x74                  ;attribute byte
mov [es:di],dx                 
add di,2
loop nextpos

scrl:
call scroll
call sleep

dec si
cmp si,[bp-12]
jnz calculate_time



pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret


display_score:
push bp
push es
push si
push di
push ax
push bx
push cx 

mov ah,13h
mov al,0
mov bh,0
mov bl,0x74
mov dx,0x0046
mov cx,7
push cs
pop es
mov bp,msg1
int 10h

pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret

display_time:

push bp
push es
push si
push di
push ax
push bx
push cx 

mov ah,13h
mov al,0
mov bh,0
mov bl,0x74
mov dx,0x0000
mov cx,11
push cs
pop es
mov bp,msg2
int 10h

pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret


display_time_up:

push bp
push es
push si
push di
push ax
push bx
push cx 

mov ah,13h
mov al,0
mov bh,0
mov bl,0x74
mov dx,0x0020
mov cx,15
push cs
pop es
mov bp,msg5
int 10h

pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret


balloon_float:
push ax
push bx

mov bx,120
loop2:

mov ax,[bp+10]
mov [bp-20],ax

mov ax,[bp+8]
mov [bp-18],ax

mov ax,[bp+6]
mov [bp-16],ax

mov ax,[bp+4]
mov [bp-14],ax

mov cx,0
call create_balloon                   

mov ax,[bp+18]
mov [bp-20],ax

mov ax,[bp+16]
mov [bp-18],ax

mov ax,[bp+14]
mov [bp-16],ax

mov ax,[bp+12]
mov [bp-14],ax

mov cx,1
call create_balloon

mov ax,[bp+26]
mov [bp-20],ax

mov ax,[bp+24]
mov [bp-18],ax

mov ax,[bp+22]
mov [bp-16],ax

mov ax,[bp+20]
mov [bp-14],ax

mov cx,2
call create_balloon


mov [bp-10],bx
sub bx,15
cmp bx,0
je l6
jmp l5 
l6:
mov bx,-1
l5:
mov [bp-12],bx
call timer
cmp byte [bp-12],-1
jne loop2 



pop bx
pop ax
ret


page1:
push bp
push es
push si
push di
push ax
push bx
push cx 

mov ah,13h
mov al,1
mov bh,1
mov bl,0x74
mov dx,0X0819
mov cx,30
push cs
pop es
mov bp,msg3
int 10h

mov ah,13h
mov al,1
mov bh,1
mov bl,0x74
mov dx,0X0B13
mov cx,41
push cs
pop es
mov bp,msg4
int 10h

mov ah,2            ; setting cursor position outside the screen
mov dh,0x26
mov dl,0x82
mov bh,1
int 10h

mov ch,32           ; hides the cursor
mov ah,1
int 10h

mov ah,05h          ;display page 1
mov al,1
int 10h

input:
mov ah,1            ;takes input to start game
int 21h

cmp al,0x20         ;checks whether user inputs space or not to start the game
jne input

pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret

page2:
push ax

mov ah,05h
mov al,0
int 10h

call display_score
call display_time
call balloon_float
call display_time_up

mov ah,2            ; setting cursor position outside the screen
mov dh,0x26
mov dl,0x82
mov bh,1
int 10h

mov ch,32           ; hides the cursor
mov ah,1
int 10h

inputt:
mov ah,1            ;takes input to start game
int 21h

cmp al,0x20         ;checks whether user inputs space or not to start the game
jne inputt

pop ax
ret

page3:

push bp
push es
push si
push di
push ax
push bx
push cx 

mov ah,13h
mov al,1
mov bh,2                  ;page no
mov bl,0x74
mov dx,0X0819
mov cx,22
push cs
pop es
mov bp,msg6
int 10h


mov ah,2            ; setting cursor position outside the screen
mov dh,0x26
mov dl,0x82
mov bh,2
int 10h

mov ah,05h          ;display page 3
mov al,2
int 10h

pop cx
pop bx
pop ax
pop di
pop si
pop es
pop bp
ret

balloon_game:                  ; game subroutine
push bp
mov bp,sp
sub sp,20
push es 
push ax
push si
push dx
push bx
push cx

mov ax,0xB800
mov es,ax


call page1
call page2 
call page3

pop cx
pop bx
pop dx
pop si
pop ax
pop es
add sp,20
pop bp

ret 10

start:
call clrscr

mov ax,0x44                  ;balloon color attribute
push ax
;balloon1
mov word ax,13               ;top left (x)
push ax
mov word ax,25               ;top left (y)
push ax
mov word ax,16               ;bottom right (x)
push ax
mov word ax,28               ;bottom right(y)
push ax
;ballon2
mov word ax,13               ;top left (x)
push ax
mov word ax,53               ;top left (y)
push ax
mov word ax,16               ;bottom right (x)
push ax
mov word ax,56               ;bottom right(y)
push ax
;balloon3
mov word ax,20               ;top left (x)
push ax
mov word ax,39               ;top left (y)
push ax
mov word ax,23               ;bottom right (x)
push ax
mov word ax,42               ;bottom right(y)
push ax

call balloon_game

mov ax, 0x4c00 
int 0x21

msg1:db 'Score: '
msg2:db 'Time Left: '
msg3:db '!!!  BUBBLES POPPING GAME  !!!' 
msg4:db 'Press  SPACE  BAR  to  START  the  game !'
msg5:db '!!! TIME UP !!!'
msg6:db 'YOUR TOTAL SCORE IS : '