(library (datafetch fetcher)
         (export do-fetch do-simplepost)
         (import (yuni scheme))

;;

(define %simplefetch (yuni/js-import "simplefetch"))
(define %simplepost (yuni/js-import "simplepost-json"))

(define (do-simplepost0 url obj)
  (let ((r (yuni/js-invoke/async1 %simplepost url obj)))
   (PCK (list 'SIMPLEPOST: r))
   (vector-ref r 0)))

(define (do-simplepost url obj . query?) ;; => js-obj / number(status code) / #f(fatal)
  (define has-query? #f)
  (define (strfy x)
    (cond
      ((string? x) x)
      ((symbol? x) (symbol->string x))
      ((number? x) (number->string x))
      (else
        (error "???" x))))
  (define (itr) ;; FIXME: Needs some retrylogic
    (PCK (list 'FETCH: STR))
    (do-simplepost0 STR obj))
  (define STR url)
  (for-each (lambda (e)
              (let ((a (strfy (car e)))
                    (d (strfy (cdr e))))
                (set! STR (string-append STR (if has-query? "&" "?")))
                (set! STR (string-append STR a "=" d))
                (set! has-query? #t)))
            (if (null? query?) '() (car query?)))
  (itr))
         
(define (do-simplefetch url)
  (let ((r (yuni/js-invoke/async1 %simplefetch url)))
   (PCK (list 'SIMPLEFETCH: r))
   (vector-ref r 0)))

(define (do-fetch url . query?) ;; => js-obj / number(status code) / #f(fatal)
  (define has-query? #f)
  (define (strfy x)
    (cond
      ((string? x) x)
      ((symbol? x) (symbol->string x))
      ((number? x) (number->string x))
      (else
        (error "???" x))))
  (define (itr) ;; FIXME: Needs some retrylogic
    (PCK (list 'FETCH: STR))
    (do-simplefetch STR))
  (define STR url)
  (for-each (lambda (e)
              (let ((a (strfy (car e)))
                    (d (strfy (cdr e))))
                (set! STR (string-append STR (if has-query? "&" "?")))
                (set! STR (string-append STR a "=" d))
                (set! has-query? #t)))
            (if (null? query?) '() (car query?)))
  (itr))

)
