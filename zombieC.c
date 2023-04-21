#include "main.h"

#include <stdio.h>
#include <stdlib.h>

#include "gba.h"

#include "images/zombie.h"
#include "images/plant.h"
#include "images/garden.h"
#include "images/startScreen.h"

void moveZombie(struct gameState *cs, u32 currentButtons, u32 previousButtons, enum gba_state *state)
{
    struct zombie *zp = &cs->zombie;
    if (KEY_JUST_PRESSED(BUTTON_LEFT, currentButtons, previousButtons))
    {
        zp->col -= zp->cd;
        if (zp->col <= 10)
        {
            *state = WIN;
        }
    }
    if (KEY_JUST_PRESSED(BUTTON_RIGHT, currentButtons, previousButtons))
    {
        zp->col += zp->cd;
        if (zp->col >= WIDTH - ZOMBIE_WIDTH - 10)
        {
            zp->col = WIDTH - ZOMBIE_WIDTH - 10;
        }
    }
    if (KEY_JUST_PRESSED(BUTTON_DOWN, currentButtons, previousButtons))
    {
        zp->row += zp->rd;
        if (zp->row >= HEIGHT - ZOMBIE_HEIGHT - 5)
        {
            zp->row = HEIGHT - ZOMBIE_HEIGHT - 5;
        }
    }
    if (KEY_JUST_PRESSED(BUTTON_UP, currentButtons, previousButtons))
    {
        zp->row -= zp->rd;
        if (zp->row <= 10)
        {
            zp->row = 10;
        }
    }
}