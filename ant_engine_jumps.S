#include <sys/regdef.h>

.text
.align 2
.ent modxd
.frame fp, 32, ra
.cprestore 0
modxd:
          # Creacion del stack
          subu sp, sp, 32
          sw fp, 28(sp)
          sw gp, 24(sp)
          move fp, sp

          # Guardo parametros en stack de padre
          sw a0, 32(fp)
          sw a1, 36(fp)

          
          lw t0, 16(fp)
          lw t1, 12(fp)

          # Guardo el contenido de t0 en t2 para poder
          # Ir decrementandolo sin perder el valor inicial
          move t0, t2
beggining:
          # Le resto el valor que esta en t1 a t2, que puede
          # tener el inicial o uno menor tras alguna iteracion
          sub t1, t2, t1
          # Si el resultado es mayor a cero vuelvo a iterar
          bgtz t1, beggining
          # Sumo el valor negativo o 0 a t1 para obtener el modulo
fin_mod:  add t0, t1

          # Deshago el stack
          lw fp, 28(sp)
          lw ra, 8(sp)
          addu sp, sp, 8
          jr ra

          lw	fp,28(sp)

          addiu	sp,sp,32
          jr	ra

          .end modxd

.text
.align 2
.globl move_forward
.ent move_forward
.frame fp, 32, ra
.cprestore 0
move_forward:
        # Creacion del stack
        subu sp, sp, 32
        sw	ra, 24(sp)
        sw fp, 28(sp)
        sw gp, 20(sp)
        move fp, sp

        # Guardo parametros en stack de padre
        sw a0, 32(fp)
        sw a1, 36(fp)

        # Se cargan x e y, asi como o
        lw t2, 0(a0)
        lw t3, 4(a0)
        lw t4, 8(a0)

        # Se hace un branch segun que orientacion tiene
        beq t4, 0, north
        beq t4, 1, south 
        beq t4, 2, east 
        beq t4, 3, west

        # Cada punto cardinal sabe con que parametros llamar a modulo,
        # si debe aumentar o decrementar y en que coordenada 
        # Voy a documentar solo west, el resto es analogo cambiando de
        # direccion o si es suma o resta
        # Aqui guardo el primer parametro, que es de lo que quiero sacar
        # el modulo para pasarle a modxd (en este caso x)
west:   sub t2, t2, 1
        sw t2, 16(fp)
        # Aqui hago lo mismo pero el numero con el que se saca el modulo
        # (en este caso width)
        sw a1, 12(fp)
        # Hago un load address de la direccion de modxd
        la t1, modxd
        # Con la direccion cargada hago un jump and link
        jalr t1
        # Guardo el resultado en t2
        move t2, v0
        # Voy a antes de deshacer el stack
        b fin
north:  sub t3, t3, 1
        sw t3, 16(fp)
        sw a2, 12(fp)
        la t1, modxd
        jalr t1
        move t3, v0
        b fin
south:  add t3, t3, 1
        sw t3, 16(fp)
        sw a2, 12(fp)
        la t1, modxd
        jalr t1
        move t3, v0
        b fin
east:   add t2, t2, 1
        sw t2, 16(fp)
        sw a1, 12(fp)
        la t1, modxd
        jalr t1
        move t2, v0
fin:    lw	ra, 32(sp)
      	lw	fp, 28(sp)
        add sp, sp, 40
        jr ra
        .end move_forward