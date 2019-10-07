#include <sys/regdef.h>

    .text
    .align 2
    .globl new_orientation
    .ent new_orientation

    #define ON 0
    #define OS 1
    #define OE 2
    #define OW 3

    #define N_ORIENTATIONS 4
    #define RL 0
    #define RR 1

    //int neworientationmap[N_ORIENTATIONS][2] size, in bytes
    #define SZ_NEWORIENTATIONMAP (4 * 2 * N_ORIENTATIONS)
    #define SZ_FP 4
    #define SZ_GP 4

    //Stack size
    #define SS (SZ_NEWORIENTATIONMAP + SZ_FP + SZ_GP)

    //Offset to each argument in the ABA
    #define O_ARG0(sp) (SS + 0)(sp)
    #define O_ARG1(sp) (SS + 4)(sp)

    //Offset to fp and gp
    #define O_FP(sp) (SS-4)(sp)
    #define O_GP(sp) (SS-8)(sp)

    //Offset to the orientations array (orientation, rule, reg)
    #define O_NEWORIENTATIONMAP_START     (SS - SZ_NEWORIENTATIONMAP - SZ_FP - SZ_GP)
    #define O_NEWORIENTATIONMAP(o, r, sp) (O_NEWORIENTATIONMAP_START + (o * 8) + (4 * r))(sp)

new_orientation:
    
    subu   sp,sp,SS   //Create the stack frame

    sw  a0,O_ARG0(sp) //Store a0 in the ABA
    sw  a1,O_ARG1(sp) //Store a1 in the ABA

    //Store fp and gp
    sw	fp,O_FP(sp)		//Store fp in the ABA
    sw	gp,O_GP(sp)		//Store gp in the ABA

    //Build new_orientations array
    li  t1,ON
    li  t2,OS
    li  t3,OE
    li  t4,OW
    sw  t4,O_NEWORIENTATIONMAP(ON,RL,sp) //{ {WEST,
    sw  t3,O_NEWORIENTATIONMAP(ON,RR,sp) //   EAST},
    sw  t3,O_NEWORIENTATIONMAP(OS,RL,sp) //  {EAST,
    sw  t4,O_NEWORIENTATIONMAP(OS,RR,sp) //   WEST},
    sw  t1,O_NEWORIENTATIONMAP(OE,RL,sp) //  {NORTH,
    sw  t2,O_NEWORIENTATIONMAP(OE,RR,sp) //   SOUTH},
    sw  t2,O_NEWORIENTATIONMAP(OW,RL,sp) //  {SOUTH,
    sw  t1,O_NEWORIENTATIONMAP(OW,RR,sp) //   NORTH}}
    
    addiu  t5,a0,0              // Cargo argumento 1
    addiu  t6,a1,0              // Cargo argumento 2
    sll    t5,t5,3              // t5 = t5 * 8
    sll    t6,t6,2              // t6 = t6 * 4
    addu   sp,sp,t5             // sp = sp + t5
    addu   sp,sp,t6             // sp = sp + t6
    lw     t7,0(sp)             // Cargo la direccion nueva
    subu   sp,sp,t5             // Vuelvo a la posicion del SP
    subu   sp,sp,t6             // Vuelvo a la posicion del SP
    addiu  sp,sp,SS             // Destroy the stack frame  
    addiu  v0,t7,0              // Devuelvo la direccion nueva
    jr ra

.end new_orientation

// .text
// .align 2
// .globl move_forward
// .ent move_forward
// move_forward:
//     la a0, ime
//     jal doPanic
// .end move_forward
