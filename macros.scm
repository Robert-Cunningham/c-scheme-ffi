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

;;;;;;;;;;;;;;;;;;;
;; Helper Functions
;;;;;;;;;;;;;;;;;;;

;; Returns a list of integers from a to b in increments of 1.
(define (range_ a b)
  (if (eqv? a b) '() (cons a (range_ (+ a 1) b))))

;; Returns a list of integers from 0 to b in increments of 1
(define (range b) (range_ 0 b))

;;;;;;;;;;;;;;;;;;;;;;;;
;; Macro Code Generation
;;;;;;;;;;;;;;;;;;;;;;;;

;; Builds the DEFINE_F{n} macro, where n is the arity of some
;; function we may wish to define.
(define (make-define-f n)
  (define (n_ x) (number->string (+ x 1)))
  (define ins
    (comma-separated-string
     (map
      (lambda (n) (string-append "IN_" (n_ n)))
      (range n))))
  (define (construct-varget n)
    (string-append "IN_" (n_ n) " __in" (n_ n) " = parse_ ## IN_" (n_ n) " (argv, &idx); "))
  (define vargets
    (space-separated-string
     (map construct-varget (range n))))
  (define vars
    (comma-separated-string
     (map
      (lambda (n) (string-append "__in" (n_ n)))
      (range n))))
  (string-append
   "#define DEFINE_F"
   (n_ (- n 1))
   "("
   "FUNC, OUT_TYPE, "
   ins
   ")"
   "if (strcmp(f, #FUNC) == 0) { "
   vargets
   "OUT_TYPE __out = FUNC (" vars "); "
   "print_ ## OUT_TYPE (__out); "
   "} \n"))

;; Builds the DEFINE_STRUCT{n} macro, where n is the number of
;; member variables contained in the macro we may wish to define.
(define (make-define-struct n)
  (define (n_ x) (number->string (+ x 1)))
  (define ins
    (comma-separated-string
     (map
      (lambda (n) (string-append "TYPE_" (n_ n) ", PARAM_" (n_ n)))
      (range n))))
  (define ins2 (apply string-append
                      (map
                       (lambda (n) (string-append "TYPE_" (n_ n) " PARAM_" (n_ n) ";"))
                       (range n))))
  (define (construct-varget n)
    (string-append "__out->PARAM_" (n_ n) " = parse_ ## TYPE_" (n_ n) "(argv, idx); "))
  (define vargets
    (space-separated-string
     (map construct-varget (range n))))
  (define (construct-varprint n)
    (string-append "print_ ## TYPE_" (n_ n) "(to_print.PARAM_" (n_ n) "); "))
  (define varprints
    (space-separated-string
     (map construct-varprint (range n))))
  (string-append
   "#define DEFINE_STRUCT"
   (n_ (- n 1))
   "("
   "NAME, "
   ins
   ")"
   "typedef struct { " ins2 "} NAME; "
   "NAME parse_ ## NAME(char* argv [], int* idx) { "
   "NAME* __out = malloc(sizeof(NAME)); "
   vargets
   "return *__out;"
   "} "
   "void print_ ## NAME(NAME to_print) { "
   varprints
   "} \n"))

;; Creates a string of CPP code which creates functionality to build functions
;; and structs which take up to n arguments:
(define (make-macros n)
  (string-append
   (apply string-append (map (lambda (n) (make-define-f n)) (range_ 1 (+ n 1))))
   (apply string-append (map (lambda (n) (make-define-struct n)) (range_ 1 (+ n 1))))))

;; Writes macros (created as specified by make-macros) to disk
(define (write-macros n)
  (call-with-output-file "macros.h"
    (lambda (p) (write-string (make-macros n) p))))

;;;;;;;;;;;;;;;;;;;;
;; String Formatting
;;;;;;;;;;;;;;;;;;;;

(define (write-lines string-list port)
  (for-each
   (lambda (string)
     (write-string-with-newline string port))
   string-list))

(define (write-string-with-newline string port)
  (write-string string port)
  (newline port))

(define (append-space string)
  (string-append string " "))

(define (append-comma string)
  (string-append string ", "))

(define (delimiter-separated-string list delimiter)
  (let* ((delimiter-appender
          (lambda (string)
            (string-append string delimiter)))
         (length-minus-one
          (- (length list) 1))
         (last
          (list-tail list length-minus-one))
         (all-but-last
          (list-head list length-minus-one))
         (delimiter-appended-all-but-last
          (map delimiter-appender all-but-last))
         (full-list
          (append delimiter-appended-all-but-last last)))
    (apply string-append full-list)))

(define (comma-separated-string list)
  (delimiter-separated-string list ", "))

(define (space-separated-string list)
  (delimiter-separated-string list " "))
