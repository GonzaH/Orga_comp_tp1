.text
.align 2

.ent modxd
.frame $fp, 8, $ra
.cprestore 0
modxd:
beggining:  
          subu $sp, $sp, 32
          sw $fp, 28($sp)
          sw $gp, 24($sp)
          move $fp, $sp

          sw $a0, 32($fp)
          sw $a0, 16($fp)
          sw $a1, 12($fp)

          lw $t0, 16($fp)
          lw $t1, 12($fp)

          sub $t1, $t2, $t1
          bgtz $t1, beggining
          bne $t0, 0, fin_mod
          and $t0, $t0, 0
fin_mod:  add $t0, $t1

          lw $fp, 28($sp)
          lw $ra, 8($sp)
          addu $sp, $sp, 8
          jr $ra

          lw	$fp,28($sp)

          addiu	$sp,$sp,32
          jr	$ra

          .end modxd

.globl move_forward
.ent move_forward
.frame $fp, 8, $ra
.cprestore 0
move_forward:
        subu $sp, $sp, 40
        sw	$ra, 32($sp)
        sw $fp, 28($sp)
        move $fp, $sp

        sw $a0, 40($fp)
        sw $a1, 36($fp)
        sw $a2, 32($fp)
        sw $a3, 28($fp)
        sw $t0, 24($fp)

        beq $a2, 0, north
        beq $a2, 1, south 
        beq $a2, 2, east 
        beq $a2, 3, west

west:   sub $a0, $a0, 1
        sw $a0, 24($fp)
        sw $a3, 8($fp)
        b fin
north:  sub $a1, $a1, 1
        sw $a1, 24($fp)
        sw $t0, 4($fp)
        b fin
south:  add $a1, $a1, 1
        sw $a1, 24($fp)
        sw $a3, 4($fp)
        b fin
east:   add $a0, $a0, 1
        sw $a0, 24($fp)
        sw $t0, 8($fp)
fin:    la $t1, modxd
        jalr $t1

      	lw	$ra, 32($sp)
      	lw	$fp, 28($sp)
        add $sp, $sp, 40
        jr $ra
        .end move_forward
