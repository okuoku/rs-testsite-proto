(library (components mainframe)
         (export mainframe)
         (import (yuni scheme)
                 (components cmdbar)
                 (components tlstream)
                 (testdata)
                 (proto reactutil)
                 (proto jsutil))

;;

(define dat0 (gen-testdata/left))
(define dat1 (gen-testdata/right))

(define (gen-tlstream dat)
  (define (init cb)
    (cb dat))
  (define (more ref cb)
    ;; FIXME: Optimize it later
    (let ((r (cdr (reverse dat)))
          (nex (gen-testdata ref 60)))
     (PCK 'DO-MORE: ref (length nex))
     (let ((nex (append (reverse r)
                        (cdr (gen-testdata ref 60)))))
       (set! dat nex)
       (cb dat))))
  (define (cmd x cb)
    (case (car x)
      ((init) (init cb))
      ((more) (more (cadr x) cb))
      (else "Do-nothing")))
  ((make-tlstream cmd)))

(define mainframe
  (make-react-element
    ((withStyles (js-obj 
                   "screen" (js-obj "height" "100vh"
                                    "overflow" "hidden"
                                    "display" "flex"
                                    "flexDirection" "column")
                   "upper" (js-obj "height" "36px")
                   "lower" (js-obj "overflow" "hidden"
                                   "display" "flex"
                                   "flexDirection" "row")
                   "hpad" (js-obj "width" "32px")))
     (make-react-class/raw
       "render" (wrap-this this
                           (let* ((props (js-ref this "props"))
                                  (classes (js-ref props "classes"))
                                  (tlstream0 (gen-tlstream dat0))
                                  (tlstream1 (gen-tlstream dat1)))
                             (ReactDiv 
                               (js-obj "className" (js-ref classes "screen"))
                               (ReactDiv (js-obj "className"
                                                 (js-ref classes "upper"))
                                         (cmdbar))
                               (ReactDiv (js-obj "className" 
                                                 (js-ref classes "lower"))
                                         tlstream0
                                         (ReactDiv 
                                           (js-obj "className"
                                                   (js-ref classes "hpad")))
                                         tlstream1))))))))
         
)
