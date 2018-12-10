(library (testdata)
         (export gen-testdata/left
                 gen-testdata/right
                 )
         (import (yuni scheme)
                 (datafetch testing))
         
(define (gen-one ref)
  (let* ((x (testdata-ref ref))
         (ident (js-ref x "ident"))
         (author (js-ref x "author"))
         (message (js-ref x "message")))
    (js-obj "ident" (substring ident 0 10)
            "author" author
            "message" message)))

(define (gen-spine start)
  ;; Generate spine
  (let loop ((next start)
             (cur '()))
    (let ((nn (testdata-refnext next)))
     (if nn
       (loop nn (cons next cur))
       (reverse cur)))))

(define (gen-testdata/left)
  (ensure-testdata!)
  (let ((l (gen-spine (testdata-head))))
   (PCK (list 'LOGLENGTH-LEFT: (length l)))
   (map gen-one l)))

(define (gen-testdata/right)
  (ensure-testdata!)
  (let ((l (gen-spine (testdata-subhead))))
   (PCK (list 'LOGLENGTH-RIGHT: (length l)))
   (map gen-one l)))

(define testdata-available #f)
(define (ensure-testdata!)
  (unless testdata-available
    (prepare-testdata)
    (set! testdata-available #t)))
         
)
