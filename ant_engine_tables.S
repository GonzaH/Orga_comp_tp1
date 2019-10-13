#include <sys/regdef.h>
#define ON 0
#define OS 1
#define OE 2
#define OW 3

#define N_ORIENTATIONS 4
#define RL 0
#define RR 1

// Offset to ant_t structure
#define O_X(reg) (0)(reg)
#define O_Y(reg) (4)(reg)
#define O_O(reg) (8)(reg)

.text
.align 2
.globl new_orientation
.ent new_orientation
new_orientation:
    
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

.text
.align 2
.ent adjust
.cprestore 0
adjust:
    div     a1, a2        // value div limit
    mfhi    t1            // t1 = value mod limit
    bgt		t1, zero, store // if result is greater than zero, store it
    sub     t1, zero, t1        // else, get absolute value and then store it
store:    
    sw t1, 0(a0)
    jr ra
.end adjust

.text
.align 2
.ent step_north
.cprestore 0
step_north:  
    lw      a2,a1        // a2 = height
    lw      a1,O_Y(a0)   // a1 = ant->y
    subu    a1,a1,1      // a1 = ant->y - 1
    addiu   a0,a0,8      // a0 = &ant->y
    j     adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y -1, height) 
.end step_north

.text
.align 2
.ent step_south
.cprestore 0
step_south: 
    lw      a2,a1        // a2 = height
    lw      a1,O_Y(a0)   // a1 = ant->y
    addiu    a1,a1,1      // a1 = ant->y - 1
    addiu   a0,a0,8      // a0 = &ant->y
    j     adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y -1, height) 
.end step_south

.text
.align 2
.ent step_east
.cprestore 0
step_east:
    lw      a2,a1        // a2 = height
    lw      a1,O_X(a0)   // a1 = ant->x
    addiu    a1,a1,1      // a1 = ant->x + 1
    addiu   a0,a0,4      // a0 = &ant->x
    j     adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y -1, height) 
.end step_east

.text
.align 2
.ent step_west
.cprestore 0
step_west:

    lw      a2,a1        // a2 = height
    lw      a1,O_X(a0)   // a1 = ant->x
    subu    a1,a1,1      // a1 = ant->x - 1
    addiu   a0,a0,4      // a0 = &ant->x
    j     adjust # adjust(a0, a1, a2) = adjust ( &ant->y, ant->y -1, height) 
.end step_west

.text
.align 2
.globl move_forward
.ent move_forward
.cprestore 0
move_forward:

    #define SZ_RELEVANTBOUNDS (4 * 4)
    #define SZ_FP 4
    #define SZ_GP 4
    #define SZ_RA 4

    //Stack size
    #define SS (SZ_RELEVANTBOUNDS + SZ_FP + SZ_GP + SZ_RA)

    //Offset to each argument in the ABA
    #define O_ARG0(sp) (SS + 0)(sp)
    #define O_ARG1(sp) (SS + 4)(sp)
    #define O_ARG2(sp) (SS + 8)(sp)

    //Offset to fp and gp
    #define O_RA(sp) (SS-4)(sp)
    #define O_FP(sp) (SS-8)(sp)
    #define O_GP(sp) (SS-12)(sp)

    //Offset
    #define O_RELEVANTBOUNDS_START (SS - SZ_RELEVANTBOUNDS - SZ_FP - SZ_GP - SZ_RA)
    #define O_RELEVANTBOUNDS(pos, sp) (O_RELEVANTBOUNDS_START + (4 * pos))(sp)

    // Offset to ant_t structure
    #define O_X(reg) (0)(reg)
    #define O_Y(reg) (4)(reg)
    #define O_O(reg) (8)(reg)

    subu   sp,sp,SS   //Create the stack frame

    sw  a0,O_ARG0(sp) //Store a0 in the ABA
    sw  a1,O_ARG1(sp) //Store a1 in the ABA
    sw  a2,O_ARG2(sp) //Store a1 in the ABA

    //Store fp and gp and ra
    sw  ra,O_RA(sp)     //Store ra in the ABA
    sw	fp,O_FP(sp)		//Store fp in the ABA
    sw	gp,O_GP(sp)		//Store gp in the ABA

    //Build new_orientations array
    lw  t0,O_ARG0(sp) //ant
    lw  t1,O_ARG1(sp) //Height
    lw  t2,O_ARG2(sp) //Width
    sw  t1,O_RELEVANTBOUNDS(0,sp) //heigth
    sw  t1,O_RELEVANTBOUNDS(1,sp) //heigth
    sw  t2,O_RELEVANTBOUNDS(2,sp) //width
    sw  t2,O_RELEVANTBOUNDS(3,sp) //width
    
    lw  s0,O_X(a0)      //ant->x
    lw  s1,O_Y(a0)      //ant->y
    lw  s2,O_O(a0)      //ant->o

    sll s2,2                    //s2 = s2 * 4
    addu  sp,sp,s2      //sp = sp + s2  para agarrar el relevantBounds[ant->o]
    lw  t4,(sp)           //t4 = relevant_bounds[ant->o]
    la  t6,allowed_forward  //t6 = allowed_forward[0]
    addu t6,t6,s2           //t6 = allowed_forward[ant->o]
    lw  t5,(t6)             //t5 = function
    move  a1,t4             //a1= relevant_bound[ant->o]
    jalr t5
    subu sp,sp,s2
    lw  ra,O_RA(sp)
    addiu  sp,sp,SS             // Destroy the stack frame 
    addiu  v0,a0,0
    jr ra

.end move_forward
.data
allowed_forward: .word step_north, step_south, step_east, step_west
