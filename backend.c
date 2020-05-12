/**
 * This file is part of the MIT Scheme to C Foreign Function Interface
 * Copyright (C) 2020  Milo Cress, Robert Cunningham, Michael Silver

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 **/

#include <string.h>

#include "backend.h"
#include "macros.h"
#include "structs.h"
#include "includes.h"

// Feel free to define functions here to be accessed from Scheme
// Begin user defined functions

double mult(double a, double b) {
    return a*b;
}

int fib(int n) {
    if (n <= 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    }
    return fib(n-2) + fib(n-1);
}

test_struct do_test_op(test_struct a, int b) {
    a.a = 3;
    a.b = b;
    return a;
}

test_struct2 do_test_op2(test_struct2 a, int unused) {
    return a;
}

uint64_t clhash_demo(char* str, int len) { //Taken from CLHash docs.
    void * random = get_random_key_for_clhash(UINT64_C(0x23a23cf5033c3c81),UINT64_C(0xb3816f6a2c68e530));
    return clhash(random,str,len);
}

// End user defined functions

int main(int argc, char* argv[]) {
    char* f = argv[1];
    int idx = 1;

    #include "functions.h"

    return -1;
}
