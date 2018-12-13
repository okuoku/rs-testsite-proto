(library (testdata)
         (export )
         (import (yuni scheme)
                 (datafetch testing))
         
(define (gen-one/ref ref)
  (let* ((x (testdata-ref ref))
         (ident (js-ref x "ident"))
         (author (js-ref x "author"))
         (message (js-ref x "message"))
         (date (js-ref x "date"))
         (dateobj (parse-date date))
         (year (date-year dateobj))
         (month (date-month dateobj))
         (day (date-day dateobj)))
    (list 'rev
          (substring ident 0 10) ;; FIXME: Perhaps needs to be longer?
          (cons 'author author)
          (cons 'message message)
          (cons 'date date)
          (cons 'datetag (list year month day)))))

(define (gen-one x)
  (if (pair? x)
    (list 'more (cdr x))
    (gen-one/ref x)))

(define (gen-spine start len)
  ;; Generate spine
  (let loop ((next start)
             (cnt 0)
             (cur '()))
    (let ((nn (testdata-refnext next)))
     (if nn
       (if (= len cnt)
         (reverse (cons (cons 'more next) (cons next cur)))
         (loop nn (+ 1 cnt) (cons next cur)))
       (reverse cur)))))

(define (gen-testdata ref len)
  (ensure-testdata!)
  (let ((l (gen-spine ref len)))
   (map gen-one l)))

(define testdata-available #f)
(define (ensure-testdata!)
  (unless testdata-available
    (prepare-testdata)
    (set! testdata-available #t)))
         
)
