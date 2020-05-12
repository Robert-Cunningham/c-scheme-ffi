#| -*-Scheme-*-

This file is part of the MIT Scheme to C Foreign Function Interface
Copyright (C) 2020  Milo Cress, Robert Cunningham, Michael Silver

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
|#

;; Demo of how to use the Scheme-C FFI

;; Frontend must be loaded
(load "frontend")

;; Import C libraries:
;;
;; See Makefile for details on where to put src and header files, as
;; well as changes that must be make to the Makefile.
(include "clhash.h")

;; Declare C foreign functions:
;;
;; C functions may be either directly from imported libraries, or
;; defined in backend.c. See backend.c for examples.
(define-c-function cfib "fib" '("int") "int")
(define-c-function chash "clhash_demo" '("string" "int") "uint64_t")

(define (parse-test-struct str)
  (list
   'test-struct
   (string->number (substring str 0 1))
   (string->number (substring str 2 3))))
(define-c-struct test-struct "test_struct" '("int" "a" "int" "b") parse-test-struct)

(define (parse-test-struct2 str) 'test-struct-2)
(define-c-struct test-struct2 "test_struct2" '("int" "a" "test_struct" "ts") parse-test-struct2)

(define-c-function c-do-test-op "do_test_op" '("test_struct" "int") "test_struct")

#|
DEMO
In either the REPL or another .scm file:

1 ]=> (load "./demo.scm")

1 ]=> (write-c-files)
Wrote C files.

1 ]=> (compile-c)
cc -fPIC -std=c99 -O3 -msse4.2 -mpclmul -march=native -funroll-loops -Wstrict-overflow -Wstrict-aliasing -Wall -Wextra -pedantic -Wshadow -c ./libs/clhash.c -Ilibs
cc  -g backend.c -lm -Ilibs clhash.o -o backend

1 ]=> (display (cfib 10))
55

1 ]=> (display (chash "hashme" 6))
14849275164233673913

1 ]=> (display (c-do-test-op (test-struct 1 2) 3))
(test-struct 3 3)
|#
