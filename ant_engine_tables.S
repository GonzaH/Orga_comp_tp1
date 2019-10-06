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
    #define ORIENTATION_1 0
    #define ORIENTATION_2 1

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

    //Offset to the increments array (offset, coordinate, reg)
    #define O_NEWORIENTATIONMAP_START     (SS - SZ_NEWORIENTATIONMAP - SZ_FP - SZ_GP)
    #define O_NEWORIENTATIONMAP(o, c, sp) (O_NEWORIENTATIONMAP_START + (o * 4) + (4 * c))(sp)

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
    sw  t4,O_NEWORIENTATIONMAP(ON,ORIENTATION_1,sp) //{ {WEST,
    sw  t3,O_NEWORIENTATIONMAP(ON,ORIENTATION_2,sp) //   EAST},
    sw  t3,O_NEWORIENTATIONMAP(OS,ORIENTATION_1,sp) //  {EAST,
    sw  t4,O_NEWORIENTATIONMAP(OS,ORIENTATION_2,sp) //   WEST},
    sw  t1,O_NEWORIENTATIONMAP(OE,ORIENTATION_1,sp) //  {NORTH,
    sw  t2,O_NEWORIENTATIONMAP(OE,ORIENTATION_2,sp) //   SOUTH},
    sw  t2,O_NEWORIENTATIONMAP(OW,ORIENTATION_1,sp) //  {SOUTH,
    sw  t1,O_NEWORIENTATIONMAP(OW,ORIENTATION_2,sp) //   NORTH}}
    
    lw  t1,O_ARG0(sp)
    lw  t2,O_ARG1(sp)
    li  t3,O_NEWORIENTATIONMAP(t1,t2,sp)
    addiu  v0,t3,0
    addiu  sp,sp,SS              //  Destroy the stack frame  
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
