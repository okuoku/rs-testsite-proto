(library (projconfig)
         (export BASEURL
                 ;; Tentative
                 SET-REPOSNAME!
                 REPOSNAME)
         (import (yuni scheme))


;; Tentative
(define xx-reposname "BOGUS")
(define (SET-REPOSNAME! n)
  (set! xx-reposname n))
(define (REPOSNAME) xx-reposname)

;; API Config
(define (BASEURL) "http://127.0.0.1:9999")
         
)
