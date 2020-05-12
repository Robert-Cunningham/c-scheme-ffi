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

#ifndef BACKEND_H
#define BACKEND_H

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

typedef char* string;

static inline double parse_double(char* argv[], int* idx) {
    return strtod(argv[++(*idx)], NULL);
}

static inline void print_double(double d) {
    printf("%f ", d);
}

static inline int parse_int(char* argv[], int* idx) {
    return (int) strtol(argv[++(*idx)], NULL, 10);
}

static inline char* parse_string(char* argv[], int* idx) {
    return argv[++(*idx)];
}

static inline void print_int(int i) {
    printf("%d ", i);
}

static inline void print_uint64_t(uint64_t i) {
    printf("%lu ", i);
}

#endif  // BACKEND_H
