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


.ent step_west
.frame $fp, 8, $ra
.cprestore 0
step_west:  
  subu $sp, $sp, 24
  sw	$ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp

  sw $a0, 40($fp)
  sw $a1, 36($fp)
  sw $a2, 32($fp)
  sw $a3, 28($fp)

  sub $a0, $a0, 1

  sw $a0, 24($fp)
  sw $a3, 4($fp)

  la $t1, modxd
  j $t1

  lw	$ra, 32($sp)
  lw	$fp, 28($sp)
  add $sp, $sp, 40
  jr $ra

  .end step_west


.ent step_north
.frame $fp, 8, $ra
.cprestore 0
step_north:  
  subu $sp, $sp, 24
  sw	$ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp

  sw $a0, 40($fp)
  sw $a1, 36($fp)
  sw $a2, 32($fp)
  sw $a3, 28($fp)

  sub $a1, $a1, 1

  sw $a1, 24($fp)
  sw $a3, 4($fp)

  la $t1, modxd
  j $t1

  lw	$ra, 32($sp)
  lw	$fp, 28($sp)
  add $sp, $sp, 40
  jr $ra

  .end step_north

.ent step_south
.frame $fp, 8, $ra
.cprestore 0
step_south:  
  subu $sp, $sp, 24
  sw	$ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp

  sw $a0, 40($fp)
  sw $a1, 36($fp)
  sw $a2, 32($fp)
  sw $a3, 28($fp)

  add $a1, $a1, 1

  sw $a1, 24($fp)
  sw $a3, 4($fp)

  la $t1, modxd
  j $t1

  lw	$ra, 32($sp)
  lw	$fp, 28($sp)
  add $sp, $sp, 40
  jr $ra

  .end step_south

.ent step_east
.frame $fp, 8, $ra
.cprestore 0
step_east:  
  subu $sp, $sp, 24
  sw	$ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp

  sw $a0, 40($fp)
  sw $a1, 36($fp)
  sw $a2, 32($fp)
  sw $a3, 28($fp)

  add $a0, $a0, 1

  sw $a0, 24($fp)
  sw $a3, 4($fp)

  la $t1, modxd
  j $t1

  lw	$ra, 32($sp)
  lw	$fp, 28($sp)
  add $sp, $sp, 40
  jr $ra

  .end step_east


.ent step_west
.frame $fp, 8, $ra
.cprestore 0

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


relevant_bounds:  .word $a3, $a3, $t0, $t0
                  la $t1, relevant_bounds
                  add $t3, $t1, $a3
                  lw $t5, 0($t3)
                  sw $t5, 32($fp)

allowed_forward:  .word step_north, step_south, step_east, step_west
                  la $t2, allowed_forward
                  add $t4, $t2, $a3
                  lw $t6, 0($t4)
                  sw $t6, 28($fp)

                  lw	$ra, 32($sp)
                  lw	$fp, 28($sp)
                  add $sp, $sp, 40
                  jr $ra
                  .end move_forward
.end move_forward
