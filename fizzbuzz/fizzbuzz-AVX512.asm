; nasm -f elf64 -g fizzbuzz-AVX512.asm
; ld fizzbuzz-AVX512.o
; ./a.out 21

section .rodata:
	usage:
	db "Usage: fizzbuzz <N>", 10
	db "Prints fizzbuzz starting at 1 and ending at N", 10
	db "Handles N up to 255", 10
	usage_len: equ $-usage

section .rodata:
	fizz: db "fizz", 10
	buzz: db "buzz", 10
	fizzbuzz: db "fizzbuzz", 10

section .data: write
	align 64
	iota: db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64
	incr: times 64 db 64

section .bss
	buf: resb 64
	str: resb 5

section .text
global _start

; exit with a failure code N
; Fail N
%macro Fail 1
    mov     rdi, %1
    jmp fail
%endmacro

; byte to string
; in al input byte
; out rax points to buffer with string
; out rdx length of output string
btos:
	mov dl, 10
	mov byte[str+3], 10
	xor ah, ah
	div dl ; ah - rem al - quotient
	add ah, '0'
	mov [str+2], ah
	xor ah, ah
	div dl ; ah - rem al - quotient
	add ah, '0'
	mov [str+1], ah
	xor ah, ah
	div dl ; ah - rem al - quotient
	add ah, '0'
	mov [str+0], ah

	xor dx, dx
	lea rax, byte[str]
	cmp byte[eax], '0'
	sete dl
	add ax, dx
	cmp byte[eax], '0'
	sete dl
	add ax, dx
	cmp byte[eax], '0'
	sete dl
	add ax, dx
	mov rdx, str+4
	sub rdx, rax
	ret

; string to byte
; in rsi input string
; out al output byte
stob:
	xor rax, rax
	mov rdi, rsi
	cmp byte[rdi], 0
	setne al
	add rdi, rax
	cmp byte[rdi], 0
	setne al
	add rdi, rax
	cmp byte[rdi], 0
	setne al
	add rdi, rax
	cmp rsi, rdi
	je .done

	mov cl, 10
	xor ax, ax
	; mul cl
	mov ch, byte[rsi]
	sub ch, '0'
	cmp ch, 9
	ja .err
	add al, ch
	inc rsi
	cmp rdi, rsi
	je .done
	mul cl
	mov ch, byte[rsi]
	sub ch, '0'
	cmp ch, 9
	ja .err
	add al, ch
	inc rsi
	cmp rdi, rsi
	je .done
	mul cl
	mov ch, byte[rsi]
	sub ch, '0'
	cmp ch, 9
	ja .err
	add al, ch
	; inc rsi
	; cmp rdi, rsi
	; je .done
.done:
	ret
.err:
	Fail 1

; prints buffer in rsi to stdout
; Sys_write0
%macro Sys_write0 0
    mov     rax, 1 ; sys_write
    mov     rdi, 1 ; stdout
    syscall
%endmacro

; prints given buffer to stdout
; Sys_write2 buffer, length
%macro Sys_write2 2
    mov     rsi, %1 ; buffer
    mov     rdx, %2 ; length
    Sys_write0
%endmacro

help:
	Sys_write2 usage, usage_len
	jmp exit

_start:
	mov rdi, [rsp]    ; argc
	cmp rdi, 2
	jne help
	mov rsi, [rsp+16]    ; argv[1]=limit
	call stob
	movzx r12, al

	mov al, 0
	vpbroadcastb zmm0, al
	mov al, 1
	vpbroadcastb zmm1, al

	vmovdqu8 zmm10, [iota] ; dividend
	vmovdqu8 zmm11, [incr]
	mov al, 3
	vpbroadcastb zmm3, al ; divisor
	mov al, 5
	vpbroadcastb zmm5, al ; divisor

; long division by 3 and 5 using AVX512
; http://0x80.pl/notesen/2024-12-21-uint8-division.html
.batch:
	; extract dividend bits into zmm12:19
	vpsrld zmm12, zmm10, 0
	vpandd zmm12, zmm12, zmm1
	vpsrld zmm13, zmm10, 1
	vpandd zmm13, zmm13, zmm1
	vpsrld zmm14, zmm10, 2
	vpandd zmm14, zmm14, zmm1
	vpsrld zmm15, zmm10, 3
	vpandd zmm15, zmm15, zmm1
	vpsrld zmm16, zmm10, 4
	vpandd zmm16, zmm16, zmm1
	vpsrld zmm17, zmm10, 5
	vpandd zmm17, zmm17, zmm1
	vpsrld zmm18, zmm10, 6
	vpandd zmm18, zmm18, zmm1
	vpsrld zmm19, zmm10, 7
	vpandd zmm19, zmm19, zmm1

	; div by 3 remainders are in zmm23
	; div by 5 remainders are in zmm25
	vmovdqu8 zmm23, zmm19
	vmovdqu8 zmm25, zmm19

	; 7th bit
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 6th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm18
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm18
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 5th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm17
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm17
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 4th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm16
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm16
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 3th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm15
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm15
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 2th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm14
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm14
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 1th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm13
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm13
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	; 0th bit
	vpaddd zmm23, zmm23
	vpord zmm23, zmm12
	vpcmpleub k3, zmm3, zmm23
	vpsubb zmm23 {k3}, zmm23, zmm3
	vpaddd zmm25, zmm25
	vpord zmm25, zmm12
	vpcmpleub k5, zmm5, zmm25
	vpsubb zmm25 {k5}, zmm25, zmm5

	vpcmpeqb k3, zmm23, zmm0
	vpcmpeqb k5, zmm25, zmm0
	kandb k7, k3, k5
	korb k1, k3, k5
	knotb k1, k1

	vmovdqu8 zmm4, zmm0
	vpaddb zmm4 {k5}, zmm1
	vpsllw zmm4, zmm4, 1
	vpaddb zmm4 {k3}, zmm1

	vmovdqu8 [buf], zmm4
	mov ecx, 0
.print:
	mov dl, [buf+ecx]
	cmp dl, 0b00
	je .num
	cmp dl, 0b01
	je .fizz
	cmp dl, 0b10
	je .buzz
	cmp dl, 0b11
	je .fizzbuzz
	ud2
.num:
	mov al, [iota+ecx]
	call btos
	mov rsi, rax
	push rcx
	Sys_write0
	pop rcx
	jmp .next
.fizz:
	push rcx
	Sys_write2 fizz, 5
	pop rcx
	jmp .next
.buzz:
	push rcx
	Sys_write2 buzz, 5
	pop rcx
	jmp .next
.fizzbuzz:
	push rcx
	Sys_write2 fizzbuzz, 9
	pop rcx
	jmp .next
.next:
	inc ecx
	dec r12
	jz .done
	cmp ecx, 64
	jne .print

	vpaddd zmm10, zmm11
	vmovdqu8 [iota], zmm10
	jmp .batch
.done:

; Exit successfully
exit:
	xor rdi, rdi
; exit with error code in rdi
fail:
	mov rax, 60
	syscall
