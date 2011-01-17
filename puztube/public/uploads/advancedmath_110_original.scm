#lang scheme
(require srfi/1)

(define (to-base b l)
  (apply + (map (lambda (digit power)
                  (* digit (expt b power)))
                (reverse l)
                (build-list (length l) (lambda (x) x)))))

(list 'to-base
      (equal? (to-base 2 '(1 1 0)) 6))

(define (to-bits b n)
  (define (aux n)
    (if (zero? n)
        '()
        (cons (modulo n b)
              (aux (quotient n b)))))
  (let ([tmp (aux n)])
    (if (empty? tmp)
        '(0)
        (reverse tmp))))

(define *MAXTESTN* (expt 2 10))
(define (comp-from-base b n)
  (define (find testn)
    (if (> testn *MAXTESTN*)
        (error 'from-base "~s ~s" b n)
        (if (= (to-base b (to-bits 2 testn)) n)
            (to-bits 2 testn)
            (find (add1 testn)))))
  (find 0))

(define (from-base b n)
  (if (and (real? b) (>= b 2))
      (to-bits b n)
      (comp-from-base b n)))

(list 'from-base
      (equal? (from-base 2 6) '(1 1 0))
      (equal? (from-base -2 1) '(1)))

(define (in-base b f left right)
  (from-base b (f (to-base b left) (to-base b right))))

;-1-1i or -1+1i
(define (add a b) (in-base -1+i + a b))

(list 'add
      (equal? (add '(1) '(0)) '(1))
      (equal? (add '(1) '(1)) '(1 1 0 0))
      (equal? (add '(1 0) '(1)) '(1 1))
      (equal? (add '(1) '(1 0)) '(1 1))
      (equal? (add '(1 0) '(1 0)) '(1 1 0 0 0))
      (equal? (add '(1 0) '(1 1)) '(1 1 0 0 1))
      (equal? (add '(1 1) '(1 1 1)) '(0)))

(define (mul a b) (in-base -2 * a b))

(list 'mul
      (equal? (mul '(1) '(0)) '(0))
      (equal? (mul '(1) '(1)) '(1))
      (equal? (mul '(1 0) '(1)) '(1 0))
      (equal? (mul '(1 0) '(1 0)) '(1 0 0))
      (equal? (mul '(1 1) '(1 0)) '(1 1 0))
      (equal? (mul '(1 1) '(1 1)) '(1))
      (equal? (mul '(1 1 1) '(1 1 1)) '(1 1 0 0 1)))

(define (has-no-consecutive-one l)
  (cond
    [(empty? l) true]
    [(empty? (rest l)) true]
    [(and (= 1 (first l)) (= 1 (second l))) false]
    [else (has-no-consecutive-one (rest l))]))

(define ns
  (filter has-no-consecutive-one
          (build-list 100 (lambda (n) (to-bits 2 n)))))

(define (sub a b)
  (let ([left (list-index
               (lambda (bits)
                 (equal? bits (rest (reverse a))))
               ns)]
        [right (list-index
                (lambda (bits)
                  (equal? bits (rest (reverse b))))
                ns)])
    (reverse (cons 1 (list-ref ns (- left right))))))

(list 'sub
      (equal? (sub '(0 1 1) '(1 1)) '(1 1))
      (equal? (sub '(0 0 1 1) '(1 1))	'(0 1 1))
      (equal? (sub '(0 0 1 1) '(0 1 1)) '(1 1))
      (equal? (sub '(1 0 1 1) '(1 1)) '(0 0 1 1))
      (equal? (sub '(1 0 0 1 1) '(0 1 1)) '(1 0 1 1))
      (equal? (sub '(0 1 0 1 1) '(1 1)) '(1 0 0 1 1))
      (equal? (sub '(0 1 0 1 1) '(0 1 1)) '(0 0 0 1 1)))

;; unknown
(define (div a b) a)

(list 'div
      (equal? (div '(0) '(1)) '(0))
      (equal? (div '(1) '(1)) '(1))
      (equal? (div '(1) '(1 0)) '(1 0))
      (equal? (div '(1 0 0) '(1 0)) '(1 0 0 1))
      (equal? (div '(1 0 1 0) '(1 0 0 1)) '(1 0 0))
      (equal? (div '(1 0 0 1 0) '(1 0 0)) '(1 0 0))
      (equal? (div '(1 0 0 1 0) '(1 0 0 1)) '(1 0 0 1)))

(define (pow a b) (in-base 2 expt a b))

(list 'pow
      (equal? (pow '(0) '(1)) '(0))
      (equal? (pow '(1) '(0)) '(1))
      (equal? (pow '(1) '(1)) '(1))
      (equal? (pow '(1 0) '(1)) '(1 0))
      (equal? (pow '(1) '(1 0))	'(1))
      (equal? (pow '(1 0) '(1 0)) '(1 0 0))
      (equal? (pow '(1 1) '(1 0)) '(1 0 0 1)))

(define (eval expr)
  (cond
    [(number? expr)
     (eval-num expr)]
    [(list? expr)
     (eval-app expr)]
    [(symbol? expr)
     (eval-op expr)]))

(define (eval-num expr) (to-bits 10 expr))

(define (eval-app expr)
  (if (= (length expr) 3)
      ((eval (second expr))
       (eval (first expr))
       (eval (third expr)))
      (error 'eval-app "not three")))

(define (eval-op expr)
  (case expr
    [(+) add]
    [(−) sub]
    [(×) mul]
    [(÷) div]
    [(^) pow]
    [else (error 'eval-op "no op ~s" expr)])
  )

#;(eval
 '(((((11111 × 111) + (110 ^ (1010 ÷ 10010))) × ((1101 × (1011 + 1010)) + (11101 × 10))) − (((1011 − 0011) ^ 101) + (((11011 × 1110) + 1) × (10 ^ 101)))) + (((11110 + 1100) ^ 1011) ÷ 1010)))

;; some parens must be added to these to make turn stuff like 1+1+1 into (1+1)+1
#;(eval
   '(((((1010 × 10100 × (1010 + 1011)) ÷ (11 × 110)) + ((((11101 × 1111 × 1111) + 100) × 10001)÷(11100 + 1110)))× 1111) − (11101 ×(10111 + (10 ^ 101)))) + (1111 + 110))

#;(eval
   ((((((11 ^ 100) + 1010) × 1001) + (10 ^ 110)) − ((11111 ×((1010 ^ 10) + 1001)) + 1000))×(100 ^ 100)) + ((((101 ^ 11) + 10)× 11111 × 11111 × 11110 × 101)÷(11111 × 10110 ×(1000 + 1001 + 1000))))

#;(eval
   (11101×10110) + (((1001 + (10101×1000) + ((((1100 + 100)×(101 + 100 + 100)) + 1010)×11101))×1001) − (((((1001 + 1000 + 1000)×(1011 + 1010))÷10001) + (01011 − 10011))×101)))