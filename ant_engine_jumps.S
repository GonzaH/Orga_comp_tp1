#include <sys/regdef.h>
#define NORTH 0
#define SOUTH 1 
#define EAST 2
#define WEST 3
#define LEFT 0

.text
.align 2
.ent adjust
.cprestore 0
adjust:
    subu sp,sp, 8
    sw fp, 0(sp)
    sw gp, 4(sp)

    sw a0, 8(sp) # Save Aba in caller stack
    sw a1, 12(sp)
    sw a2, 16(sp)

    div     a1, a2        # value div limit
    mfhi    t1            # t1 = value mod limit
    bgt		t1, zero, store # if result is greater than zero, store it
    sub t1, zero, t1        # else, get absolute value and then store it
store:    
    sw t1, 0(a0)
    lw fp, 0(sp)
    lw gp, 4(sp)
    addu sp, sp, 8
    jr ra

.end adjust
.text
.align 2
.globl move_forward
.ent move_forward
.cprestore 0
move_forward:
        # Creacion del stack
        subu sp, sp, 48
        sw	ra, 40(sp)
        sw fp, 44(sp)
        sw gp, 40(sp)

        move fp, sp
#         # Guardo parametros en stack de padre
         sw a0, 48(fp) # *ant
         sw a1, 52(fp) # width
         sw a2, 56(sp) #height
        
        sw s2, 36(fp) 
        sw s3, 32(fp)
        sw s4, 28(fp)
        sw s5, 24(sp)
        sw s6, 20(sp)
        sw s0, 16(sp)
#         # Se cargan x e y, asi como o
        move s0, a0
        lw s2, 0(a0) #s2 -> x
        lw s3, 4(a0) #s3 -> y
        lw s4, 8(a0) #s4 -> orientation

        move s5, a1 # width
        move s6, a2 # height
#         # switch (orientation)
        beq s4, NORTH, north #case 0 jump to north
        beq s4, SOUTH, south #case 1 jump to south
        beq s4, EAST, east #case 2 jump to east
        beq s4, WEST, west #case 3 jump to west

#         # Cada punto cardinal sabe con que parametros llamar a modulo,
#         # si debe aumentar o decrementar y en que coordenada 
#         # Voy a documentar solo west, el resto es analogo cambiando de
#         # direccion o si es suma o resta
#         # Aqui guardo el primer parametro, que es de lo que quiero sacar
#         # el modulo para pasarle a adjust (en este caso x)
west:   sub s2, s2, 1
        move a0, s0  # a0 -> &ant->x
        move a1, s2 # a1 -> (ant->x -1 )
        move a2, s5 #width

        jal adjust # adjust(a0, a1, a2) = adjust ( &ant->x, ant->x -1, width) 

        # Voy a antes de deshacer el stack
        b fin

north:  sub s3, s3, 1
        add s0, s0, 4
        move a0, s0 # a1 -> &ant->y
        move a1, s3 # a1 -> (ant->y -1 )
        move a2, s6 #height
        jal adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y -1, height) 

        b fin
south:  addu s3, s3, 1
        addu s0, s0, 4
        move a0, s0 # a1 -> &ant->y
        move a1, s3 # a1 -> (ant->y + 1)
        move a2, s6 # height

        jal adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y + 1, height) 
        b fin
east:   add s2, s2, 1
        move a0, s0 # a0 -> &ant->x
        move a1,s2 # a1 -> (ant -> x + 1)
        move a2, s5 # width

        jal adjust # adjust(a0, a1, a2) = adjust ( &ant->x, ant->x + 1, width)

fin:
        lw s2, 36(fp) 
        lw s3, 32(fp)
        lw s4, 28(fp)
        lw s5, 24(sp)
        lw s6, 20(sp)
        lw s0, 16(sp)
        
        lw fp, 28(sp)
        lw ra, 24(sp)
        add sp, sp, 32
        lw v0, 0(sp) # return the same a0 (*ant) value received as parameter.
        jr ra
        .end move_forward

.text
.align 2
.ent decide
decide:
    subu sp,sp, 8
    sw fp, 0(sp)
    sw gp, 4(sp)
    beq a0, LEFT , return_left
    b return_right
return_left:
    move v0, a1
    jr ra
return_right:
    move v0, a2

    lw fp, 0(sp)
    lw gp, 4(sp)
    addu sp, sp, 8
    jr ra
.end decide

.text
.align 2
.globl new_orientation
.ent new_orientation
.cprestore 0
# norte, sur , east, weast
new_orientation:
     sub sp, sp, 32
     sw ra, 28(sp)
     move t0, a0
     move s1, a1

     beq t0, NORTH , d_north #case 0 jump to north
     beq t0, SOUTH , d_south #case 1 jump to south
     beq t0, EAST , d_east #case 2 jump to east
     beq t0, WEST , d_west #case 3 jump to west
d_west:
    move a0, s1
    li a1, SOUTH
    li a2, NORTH
    jal decide
    b end
d_south:
    move a0, s1
    li a1, EAST
    li a2, WEST
    jal decide
    b end
d_north:
    move a0, s1
    li a1, WEST
    li a2, EAST
    jal decide
    b end
d_east:
    move a0, s1
    li a1, NORTH
    li a2, SOUTH
    jal decide
    b end

end:
     lw ra, 28(sp)
     add sp, sp, 32
     jr ra
.end new_orientation

