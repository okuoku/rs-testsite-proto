(library (datafetch testing)
         (export prepare-testdata
                 ref-terminal?
                 testdata-ref
                 testdata-refnext)
         (import (yuni scheme)
                 (projconfig)
                 (datafetch fetcher))

;;

(define CONFIGOBJ #f)
(define REPOSNAME #f)
(define MASTERBRANCHES (js-obj))
(define REFCOUNT 0)
(define REPOSITORY-REFS (js-obj))
(define REPOSITORY-LINKS (js-obj))
(define has-masterref? #f)

(define REF-TERMINAL-OBJ #t)

(define (ref-terminal? ref)
  (let ((e (equal? REF-TERMINAL-OBJ ref)))
   (when e
     (PCK 'TERMINAL-REF: ref))
   e))

(define (ref-terminal) REF-TERMINAL-OBJ)

(define (%refnamefilt x)
  (let ((r (js-ref MASTERBRANCHES x)))
   (if (js-undefined? r) x r)))

(define (testdata-refresolve nam)
  (prepare-testdata)
  (let ((r (js-ref MASTERBRANCHES nam)))
   (PCK 'REFRESOLVE: nam '=> r)
   (if (js-undefined? r) #f r)))

(define (testdata-ref x) (ref-read x))
(define (testdata-refnext0 x)
  (let ((r (js-ref REPOSITORY-LINKS x)))
   (if (js-undefined? r)
     #f r)))
(define (testdata-refnext x) 
  (or (testdata-refnext0 x)
      (begin
        (fill-refs/mainhistory-cache! x)
        (testdata-refnext0 x)))) 

(define (REQ-history ref count)
  (let* ((r0 (do-fetch (string-append (BASEURL) "/read/mainhistory")
                      (list (cons 'repos REPOSNAME) 
                            (cons 'from ref)
                            (cons 'count count))))
         (res0 (js-ref r0 "result"))
         (r (do-simplepost (string-append (BASEURL) "/read/fetchrevs")
                           res0
                           (list (cons 'repos REPOSNAME))))
         (res (js-ref r "result")))
    (let ((l (js-array->list res)))
     l)))

(define (CALC-heads)
  (set! has-masterref? #t)  
  (let* ((r (do-fetch (string-append (BASEURL) "/read/heads")
                      (list (cons 'repos REPOSNAME))))
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
         (PCK (list 'INVALID-LINK-UPDATE r from '=> to)))
       (js-set! REPOSITORY-LINKS from to)))))

(define (fill-refs/mainhistory-cache! ref) ;; Cache upto 100 refs
  (define has-more? #f)
  (define hit-known? #f)
  (define first-hit? #f)
  (PCK (list 'ENTER: ref))
  (let* ((l (REQ-history ref 100))
         (len (length l)))
    (PCK (list 'HISTORY-LEN: len))
    (when (= (+ 1 100) len)
      (set! has-more? #t))
    (let loop ((cur (car l))
               (q (cdr l)))
      ;; Process cur
      (let ((ident (js-ref cur "ident")))
       (let ((i (and (not (string=? ident ref)) (ref-read0 ident))))
        (cond
          (i (unless first-hit?
               (set! hit-known? #t)))
          (else
            (ref-register! ident cur)))
        (set! first-hit? #t))
       (cond
         ((null? q)
          (unless has-more?
            (PCK (list 'TERM: ident))
            (ref-link! ident (ref-terminal)))
          'do-nothing)
         ((not hit-known?)
          (ref-link! ident (js-ref (car q) "ident"))
          (loop (car q) (cdr q)))
         (else
           (ref-link! ident (js-ref (car q) "ident"))
           (PCK (list 'MERGED: ident))
           'do-nothing))))))

(define (prepare-testdata)
  (set! REPOSNAME "ruby")
  (unless has-masterref?
    (CALC-heads)))

)
