#include "print.h"

void kernel_main()
{
    print_clear(); //Clears screen
    print_set_color(PRINT_COLOR_YELLOW, PRINT_COLOR_BLACK); //Changes foreground and background colors
    print_str("Welcome to my 64-bit kernel! :3"); //print some text
}