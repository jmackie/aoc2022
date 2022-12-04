#!/usr/bin/env racket

#lang racket

(require racket/base)

(define (line->ranges ln)
  (map (lambda (s) (map string->number (string-split s "-"))) (string-split ln ",")))

(define (fully-contained? x y)
  (or (and (<= (car x) (car y)) (>= (cadr x) (cadr y)))
      (and (<= (car y) (car x)) (>= (cadr y) (cadr x)))))

(define (overlaps? x y)
  (define (mk-set start to)
    (list->set (range start (+ to 1))))
  (define x-set (mk-set (car x) (cadr x)))
  (define y-set (mk-set (car y) (cadr y)))
  (not (set-empty? (set-intersect x-set y-set))))

(define (part-one input-file)
  (foldr (lambda (line sum)
           (define section-ranges (line->ranges line))
           (define contained (fully-contained? (car section-ranges) (cadr section-ranges)))
           (if contained (+ sum 1) sum))
         0
         (file->lines input-file)))

(define (part-two input-file)
  (foldr (lambda (line sum)
           (define section-ranges (line->ranges line))
           (define overlaps (overlaps? (car section-ranges) (cadr section-ranges)))
           (if overlaps (+ sum 1) sum))
         0
         (file->lines input-file)))

(define (main input-file)
  (define part-one-answer (part-one input-file))
  (unless (= part-one-answer 595)
    (error "wrong answer to part one"))
  (printf "part one: ~a\n" part-one-answer)

  (define part-two-answer (part-two input-file))
  (unless (= part-two-answer 952)
    (error "wrong answer to part two"))
  (printf "part two: ~a\n" part-two-answer))

(define input-file (vector-ref (current-command-line-arguments) 0))

(main input-file)
