addi x2, x0, 15      # x2 = 15
sh   x2, 0(x0)       # memória[0] = 15

addi x3, x0, 100     # x3 = 100
sh   x3, 2(x0)       # memória[2] = 100

lh   x4, 0(x0)       # x4 = 15
lh   x5, 2(x0)       # x5 = 100

sub  x6, x5, x4      # x6 = x5 - x4 = 85
or   x7, x5, x4      # x7 = x5 | x4 = 111
andi x8, x6, 0xF     # x8 = x6 & 0xF = 85 & 15 = 5
srl  x9, x7, x4      # x9 = x7 >> x4 = 0

beq  x4, x5, fim     # se x4==x5, desvia
addi x10, x0, 1      # se não desviar, x10 = 1

fim:
nop
