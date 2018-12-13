(library (datafetch testing)
         (export prepare-testdata
                 testdata-ref
                 testdata-refnext)
         (import (yuni scheme)
                 (projconfig)
                 (datafetch fetcher))

;;

(define MASTERBRANCHES (js-obj))
(define REFCOUNT 0)
(define REPOSITORY-REFS (js-obj))
(define REPOSITORY-LINKS (js-obj))
(define has-masterref? #f)

(define (%refnamefilt x)
  (let ((r (js-ref MASTERBRANCHES x)))
   (if (js-undefined? r) x r)))

(define (testdata-refresolve nam)
  (prepare-testdata)
  (let ((r (js-ref MASTERBRANCHES nam)))
   (PCK 'REFRESOLVE: nam '=> r)
   (if (js-undefined? r) #f r)))

(define (testdata-ref x) (ref-read x))
(define (testdata-refnext x) 
  (ref-read x) ;; Bogus read to warmup the cache
  (let ((r (js-ref REPOSITORY-LINKS x)))
   (if (js-undefined? r) #f r)))

(define (REQ-history ref)
  (let* ((r (do-fetch (string-append (BASEURL) "/mainhistory")
                      (list (cons 'from ref)
                            (cons 'count 100))))
         (res (js-ref r "result")))
    (let ((l (js-array->list res)))
     l)))

(define (CALC-heads)
  (set! has-masterref? #t)  
  (let* ((r (do-fetch (string-append (BASEURL) "/heads")))
         (res (js-ref r "result")))
    (let ((l (js-array->list res)))
     (for-each (lambda (e)
                 (let ((name (js-ref e "name"))
                       (ref (js-ref e "ref")))
                   (PCK (list 'NAME: name 'REF: ref))
                   (js-set! MASTERBRANCHES name ref)))
               l))))

(define (ref-register! refname obj)
  (js-set! REPOSITORY-REFS refname obj))

(define (ref-read0 refname)
  (let ((r (js-ref REPOSITORY-REFS refname)))
   (if (js-undefined? r)
     #f
     r)))

(define (ref-read refname)
  (or (ref-read0 refname)
      (begin
        (fill-refs/mainhistory-cache! refname)
        (ref-read0 refname))))

(define (ref-link! from to)
  (let ((r (js-ref REPOSITORY-LINKS from)))
   (if (js-undefined? r)
     (js-set! REPOSITORY-LINKS from to)
     (begin
       (unless (string=? to r)
         (PCK (list 'INVALID-LINK r from '=> to)))
       (js-set! REPOSITORY-LINKS from to)))))

(define (fill-refs/mainhistory-cache! ref) ;; Cache upto 100 refs
  (define hit-known? #f)
  (PCK (list 'ENTER: ref))
  (let* ((l (REQ-history ref))
         (len (length l)))
    (PCK (list 'HISTORY-LEN: len))
    (let loop ((cur (car l))
               (q (cdr l)))
      ;; Process cur
      (let ((ident (js-ref cur "ident")))
       (let ((i (and (not (string=? ident ref)) (ref-read0 ident))))
        (cond
          (i (set! hit-known? #t))
          (else
            (ref-register! ident cur))))
       (cond
         ((null? q)
          (PCK (list 'TERM: ident))
          'do-nothing)
         ((not hit-known?)
          (ref-link! ident (js-ref (car q) "ident"))
          (loop (car q) (cdr q)))
         (else
           (ref-link! ident (js-ref (car q) "ident"))
           (PCK (list 'MERGED: ident))
           'do-nothing))))))

(define (prepare-testdata)
  (unless has-masterref?
    (CALC-heads)))

)
