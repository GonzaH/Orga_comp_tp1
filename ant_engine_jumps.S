#include <sys/regdef.h>

.text
.align 2
.ent adjust
.cprestore 0
adjust:
    div     a1, a2        # value div limit
    mfhi    t1            # t1 = value mod limit
    sw t1, 0(a0)
    jr ra

.end adjust
.text
.align 2
.globl move_forward
.ent move_forward
.cprestore 0
move_forward:
        # Creacion del stack
        subu sp, sp, 32
        sw	ra, 24(sp)
        sw fp, 28(sp)
        sw gp, 20(sp)

        move fp, sp
#         # Guardo parametros en stack de padre
         sw a0, 32(fp) # *ant
         sw a1, 36(fp) # width
         sw a2, 40(sp) #height
        
        sw s2, 20(fp) 
        sw s3, 16(fp)
        sw s4, 12(fp)
        sw s5, 8(sp)
        sw s6, 4(sp)
#         # Se cargan x e y, asi como o
        lw s2, 0(a0) #s2 -> x
        lw s3, 4(a0) #s3 -> y
        lw s4, 8(a0) #s4 -> orientation

        move s5, a1 # width
        move s6, a2 # height
#         # switch (orientation)
        beq s4, 0, north #case 0 jump to north
        beq s4, 1, south #case 1 jump to south
        beq s4, 2, east #case 2 jump to east
        beq s4, 3, west #case 3 jump to west

#         # Cada punto cardinal sabe con que parametros llamar a modulo,
#         # si debe aumentar o decrementar y en que coordenada 
#         # Voy a documentar solo west, el resto es analogo cambiando de
#         # direccion o si es suma o resta
#         # Aqui guardo el primer parametro, que es de lo que quiero sacar
#         # el modulo para pasarle a adjust (en este caso x)
west:   sub s2, s2, 1
        move a1, s2 # a1 -> (ant->x -1 )
        move a2, s5 #width

        jal adjust # adjust(a0, a1, a2) = adjust ( *ant, ant->x -1, width) 

        # Voy a antes de deshacer el stack
        b fin

north:  sub s3, s3, 1
        move a1, s3 # a1 -> (ant->y -1 )
        move a2, s6 #height
        # jal adjust # adjust(a0, a1, a2) = adjust ( *ant, ant->y -1, height) 

        b fin
south:  add s3, s3, 1
        move a1, s3 # a1 -> (ant->y + 1)
        move a2, s6 # height

        #jal adjust # adjust(a0, a1, a2) = adjust ( *ant, ant->y + 1, height) 
        b fin
east:   add s2, s2, 1
        move a1,s2 # a1 -> (ant -> x + 1)
        move a2, s5 # width

        jal adjust # adjust(a0, a1, a2) = adjust ( *ant, ant->s + 1, width)

fin:

        lw s2, 20(fp) 
        lw s3, 16(fp)
        lw s4, 12(fp)
        lw s5, 8(sp)
        lw s6, 4(sp)

        lw fp, 28(sp)
        lw ra, 24(sp)
        add sp, sp, 32
        move v0, a0
        jr ra
        .end move_forward


.text
.align 2
.globl new_orientation
.ent new_orientation
.cprestore 0
new_orientation:
     #.frame fp, 32, ra
     li v0, 2
     jr ra
.end new_orientation