(library (projconfig)
         (export 
           PROJHEAD?
           BASEURL)
         (import (yuni scheme))

;; API Config
(define (BASEURL) "http://127.0.0.1:9999")

;; Project Config

; Target branches
(define projmainhead "refs/heads/master")
(define projsubhead "refs/tags/0.8")
(define projheads*
  (cons projmainhead 
        (cons projsubhead
              ;; FIXME: More heads here
              '())))

; Library
(define (PROJHEAD? x) 
  (member x projheads*))
(define (PROJMAINHEAD? x) (equal? x projmainhead))
(define (PROJSUBHEAD? x) (equal? x projsubhead))
         
)
