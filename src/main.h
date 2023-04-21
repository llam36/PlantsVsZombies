#ifndef MAIN_H
#define MAIN_H

#include "gba.h"

// TODO: Create any necessary structs

/*
* For example, for a Snake game, one could be:
*
* struct snake {
*   int heading;
*   int length;
*   int row;
*   int col;
* };
*
* Example of a struct to hold state machine data:
*
* struct state {
*   int currentState;
*   int nextState;
* };
*
*/
#define MAXPLANT 4

struct bullet {
    /* data */
    int row;
    int col;
    int cd;
    u16 color;
};

struct plant {
    /* data */
    int row;
    int col;
    int rd;
};

struct zombie {
    /* data */
    int row;
    int col;
    int cd;
    int rd;
};

struct gameState {
    struct plant plant[MAXPLANT];
    struct zombie zombie;
    struct bullet bullets[MAXPLANT];
};

#endif
