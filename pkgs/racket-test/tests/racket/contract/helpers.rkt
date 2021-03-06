#lang racket
(require rackunit
         racket/contract/private/arrow-common
         
         (for-template racket/contract/private/arrow-val-first)
         racket/contract/private/application-arity-checking
         racket/contract/private/arr-i-parse
         racket/contract/private/merge-cache)

(check-equal? (matches-arity-exactly? (λ () 1) 0 0 '() '()) #t)
(check-equal? (matches-arity-exactly? (λ () 1) 1 1 '() '()) #f)
(check-equal? (matches-arity-exactly? (λ () 1) 0 1 '() '()) #f)
(check-equal? (matches-arity-exactly? (λ () 1) 0 #f '() '()) #f)
(check-equal? (matches-arity-exactly? (λ (x y) x) 2 2 '() '()) #t)
(check-equal? (matches-arity-exactly? (λ (x y) x) 1 1 '() '()) #f)
(check-equal? (matches-arity-exactly? (λ (x y) x) 2 3 '() '()) #f)
(check-equal? (matches-arity-exactly? (λ (x y) x) 3 #f '() '()) #f)

(check-equal? (matches-arity-exactly? (case-lambda [() 1] [(x) 2])
                                      0 1 '() '())
              #t)
(check-equal? (matches-arity-exactly? (case-lambda [() 1] [(x) 2])
                                      0 2 '() '())
              #f)
(check-equal? (matches-arity-exactly? (case-lambda [() 1] [(x y) 2])
                                      0 2 '() '())
              #f)
(check-equal? (matches-arity-exactly? (case-lambda [() 1] [(x y) 2])
                                      0 1 '() '())
              #f)
(check-equal? (matches-arity-exactly? (case-lambda [() 1] [(x y) 2])
                                      0 #f '() '())
              #f)

(check-equal? (matches-arity-exactly? (lambda (x . y) x)
                                      1 #f '() '())
              #t)
(check-equal? (matches-arity-exactly? (lambda (x . y) x)
                                      0 #f '() '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y) y)
                                      1 1 '(#:y) '())
              #t)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z z) y)
	                              1 1 '(#:y #:z) '())
              #t)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z z) y)
	                              1 1 '(#:y) '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z z) y)
	                              1 1 '(#:z) '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z z) y)
	                              1 1 '() '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z z) y)
	                              1 1 '() '(#:x))
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z [z 1]) y)
	                              1 1 '(#:y) '(#:z))
              #t)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z [z 1]) y)
	                              1 1 '(#:y) '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z [z 1]) y)
	                              1 1 '() '(#:z))
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z [z 1]) y)
	                              1 1 '(#:y #:z) '())
              #f)
(check-equal? (matches-arity-exactly? (lambda (x #:y y #:z [z 1]) y)
	                              1 1 '() '(#:y #:z))
              #f)


(check-equal? (->-valid-app-shapes #'(-> integer? integer?))
              (valid-app-shapes '(1) '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? boolean? integer?))
              (valid-app-shapes '(2) '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? #:x any/c integer?))
              (valid-app-shapes '(1) '(#:x) '()))
(check-equal? (->-valid-app-shapes #'(-> integer? (... ...) any))
              (valid-app-shapes 0 '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? integer? (... ...) any))
              (valid-app-shapes 1 '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? integer? (... ...) integer? any))
              (valid-app-shapes 2 '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? integer? (... ...) integer? boolean? char? any))
              (valid-app-shapes 4 '() '()))
(check-equal? (->-valid-app-shapes #'(-> integer? boolean? char? (... ...) integer? char? any))
              (valid-app-shapes 4 '() '()))

(check-equal? (->*-valid-app-shapes #'(->* (integer? #:x any/c #:y any/c) integer?))
              (valid-app-shapes '(1) '(#:x #:y) '()))
(check-equal? (->*-valid-app-shapes #'(->* () (integer? #:x any/c #:y any/c) integer?))
              (valid-app-shapes '(0 1) '() '(#:x #:y)))
(check-equal? (->*-valid-app-shapes #'(->* (any/c) (any/c) #:rest any/c integer?))
              (valid-app-shapes '(1 2 . 3) '() '()))

(check-equal? (->i-valid-app-shapes #'(->i () () [r any/c]))
              (valid-app-shapes '(0) '() '()))
(check-equal? (->*-valid-app-shapes #'(->i ([p integer?] #:x [x any/c] #:y [y any/c]) [r any/c]))
              (valid-app-shapes '(1) '(#:x #:y) '()))
(check-equal? (->*-valid-app-shapes #'(->i () ([p integer?] #:x [x any/c] #:y [y any/c]) [r any/c]))
              (valid-app-shapes '(0 1) '() '(#:x #:y)))
(check-equal? (->*-valid-app-shapes #'(->i ([m any/c]) ([o any/c]) #:rest [r any/c] [r any/c]))
              (valid-app-shapes '(1 2 . 3) '() '()))

(check-true  (valid-argument-list? #'(f x) (valid-app-shapes '(1 2 . 3) '() '())))
(check-true  (valid-argument-list? #'(f x y) (valid-app-shapes '(1 2 . 3) '() '())))
(check-true  (valid-argument-list? #'(f x y a b c d) (valid-app-shapes '(1 2 . 3) '() '())))
(check-false (valid-argument-list? #'(f) (valid-app-shapes '(1 2 . 3) '() '()) #f))
(check-true  (valid-argument-list? #'(f #:x x) (valid-app-shapes '(0) '(#:x) '())))
(check-true  (valid-argument-list? #'(f #:x x) (valid-app-shapes '(0) '() '(#:x))))
(check-true  (valid-argument-list? #'(f) (valid-app-shapes '(0) '() '(#:x))))
(check-false (valid-argument-list? #'(f) (valid-app-shapes '(0) '(#:x) '()) #f))
(check-false (valid-argument-list? #'(f #:y y) (valid-app-shapes '(0) '(#:x) '()) #f))
(check-false (valid-argument-list? #'(f #:x) (valid-app-shapes '(0) '(#:x) '()) #f))

(define/merge-cache (f x y z w)
  (list x y z w))

(check-equal? (f 1 2 3 4) (list 1 2 3 4))
(check-equal? (f 1 2 3 4) (list 1 2 3 4))
(check-equal? (f 1 2 3 0) (list 1 2 3 0))
(check-equal? (f 1 2 3 0) (list 1 2 3 0))
(check-equal? (f 1 2 0 4) (list 1 2 0 4))
(check-equal? (f 1 0 3 4) (list 1 0 3 4))
(check-equal? (f 1 0 3 4) (list 1 0 3 4))
(check-equal? (f 0 2 3 4) (list 0 2 3 4))
(check-equal? (f 0 2 3 4) (list 0 2 3 4))
