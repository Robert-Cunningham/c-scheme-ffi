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

;; Load MIT Scheme extension for using the shell
(load-option 'synchronous-subprocess)

;; Load macro-generating Scheme code
(load "macros")

(define includes '())
(define functions '())
(define structs '())

(define (parse-number str) (string->number (string-head str (- (string-length str) 1))))
(define parsers
  (list
   (list "int"      parse-number)
   (list "uint64_t" parse-number)))

(define c-process "./backend")

;;;;;;
;; API
;;;;;;

(define (include name)
  (let ((code (string-append "#include \"" name "\"")))
    (set! includes (append includes (list code)))
    code))

(define-syntax define-c-function
  (syntax-rules ()
    ((_ schemename cname input-types output-type)
     (define schemename
       (create-function cname input-types output-type)))))

(define-syntax define-c-struct
  (syntax-rules ()
    ((_ schemename cname names-and-types parser)
     (define schemename
       (create-struct cname names-and-types parser)))))

;;;;;;;;;;
;; Helpers
;;;;;;;;;;

(define (get-parser output-type) (cadr (assoc output-type parsers)))

(define (create-function name input-types output-type)
  ;; Add function to named-functions list, specify argument numbers and types.
  (define n (number->string (length input-types)))
  (let ((code
         (string-append
          "DEFINE_F" n "("
          (append-comma name)
          (append-comma output-type)
          (comma-separated-string input-types) ")")))
    (set! functions (append functions (list code))))
  (define (run-func . args)
    ;;(assert (= (length input-types) (length args)))
    ((get-parser output-type) (send-args name args c-process)))
  run-func)

(define (create-struct name names-and-types parser)
  (define n (number->string (/ (length names-and-types) 2)))
  (define code
    (string-append
     "DEFINE_STRUCT" n "("
     name ", "
     (comma-separated-string names-and-types)
     ")"))
  (set! structs (append structs (list code)))
  (set! parsers (append parsers (list (list name parser))))
  list)

(define (write-c-files)
  (call-with-output-file "includes.h"
    (lambda (p)
      (write-lines includes p)))
  (call-with-output-file "functions.h"
    (lambda (p)
      (write-lines functions p)))
  (call-with-output-file "structs.h"
    (lambda (p)
      (write-lines structs p)))
  (write-macros 10)
  (display "Wrote C files."))

(define (compile-c)
  (run-shell-command "make"))

(define (send-args name args process)
  (define (parse-argument arg)
    (if (list? arg)
        (space-separated-string (map parse-argument arg))
        (string arg)))
  (let ((command
         (string-append
          (append-space process)
          (append-space name)
          (parse-argument args))))
    (call-with-output-string
     (lambda (port)
       (run-shell-command command
                          'output port)))))
