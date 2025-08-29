section .data

align 64
t1: dd 1, 2, 3, 4, 5
t2: dd 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
t3: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
t4: dd 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
t5: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

section .text

calc:
	mov eax, 1
	kmovd k1, eax
	vpbroadcastd zmm1, eax
	xor eax, eax
	xor r10, r10
.loop:
	mov ebx, 1
	mov edx, 16
	mov rcx, rsi
	sub rcx, r10
	cmp rcx, 16
	cmovg ecx, edx
	shl ebx, cl
	dec ebx
	kmovd k1, ebx
	vpxord zmm0, zmm0, zmm0
	vmovdqu32 zmm0 {k1}, [rdi+r10]

	vptestmd k2, zmm0, zmm1
	knotw k2, k2
	vpcompressd zmm2 {k2}, zmm0
	vphaddd ymm2, ymm2, ymm2
	vphaddd ymm2, ymm2, ymm2
	vextracti128 xmm8, ymm2, 0
	vextracti128 xmm9, ymm2, 1
	pextrd ebx, xmm8, 0
	pextrd edx, xmm9, 0
	add eax, ebx
	add eax, edx

	add r10, 16
	cmp r10, rsi
	jge .done
	jmp .loop
.done:
	ret
	
global _start
_start:
	xor r12, r12

	inc r12
	mov rdi, t3
	mov rsi, 16
	call calc
	cmp eax, 72
	jne .err

	inc r12
	mov rdi, t4
	mov rsi, 16
	call calc
	cmp eax, 72
	jne .err

	inc r12
	mov rdi, t5
	mov rsi, 32
	call calc
	cmp eax, 144
	jne .err

	inc r12
	mov rdi, t1
	mov rsi, 5
	call calc
	cmp eax, 6
	jne .err

	jmp .exit
.err:
	ud2
.exit:
	mov eax, 1
	xor rbx, rbx
	int 0x80
