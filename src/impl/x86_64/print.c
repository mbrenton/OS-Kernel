#include "print.h"

const static size_t NUM_COLS = 80;
const static size_t NUM_ROWS = 25;

//Printing works by holding an array of characters, so create a character struct with ASCII char, and color code.
struct Char 
{
    uint8_t character;
    uint8_t color;
};

struct Char* buffer = (struct Char*) 0xb8000; //Buffer, cast to point to custom char type
size_t col = 0;
size_t row = 0;
uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4; //Keep track of what current color should be while printing. First 4 bits are foreground, next are background.

void clear_row(size_t row)
{
    //print an empty space character
    struct Char empty = (struct Char) {
        character: ' ',
        color: color,
    };

    //For each col in the row, print character
    for (size_t col = 0; col < NUM_COLS; col++) {
        buffer[col + NUM_COLS * row] = empty;
    }
}

void print_clear() 
{
    //Loop though all rows startign at 0, until number of rows, call clear row per row.
    for (size_t i = 0; i < NUM_ROWS; i++) {
        clear_row(i);
    }
}

void print_newline()
{
    //When go to a new line, reset col to 0
    col = 0;

    //Check if not at last row
    if (row < NUM_ROWS - 1) {
        row++;
        return;
    }

    //If on last row, scroll text up
    for (size_t row = 1; row < NUM_ROWS; row++) {
        for (size_t col = 0; col < NUM_COLS; col++) {
            struct Char character = buffer[col + NUM_COLS * row];
            buffer[col + NUM_COLS * (row -1)] = character;
        }
    }
    clear_row(NUM_COLS - 1); //When move row up, have to clear before doing any printing on it.
}

void print_char(char character)
{
    //Check if character is a newline
    if (character == '\n') {
        print_newline();
        return;
    }

    //Print a newline if col exceeds num of colms in rows
    if (col > NUM_COLS) {
        print_newline();
    }

    buffer[col + NUM_COLS * row] = (struct Char) {
        character: (uint8_t) character,
        color: color,
    };

    col++;
}

void print_str(char* str) {
    //Take in null temrinated char array, make conditiion always true, incr i
    for (size_t i = 0; 1; i++) {
        char character = (uint8_t) str[i];

        //return if come across null char
        if (character == '\0') {
            return;
        }

        print_char(character);

    }
}

void print_set_color(uint8_t foreground, uint8_t background)
{
    //Just changing colors, foreground first 4 bits, bitshift by 4 bits for background
    color = foreground + (background << 4);
}