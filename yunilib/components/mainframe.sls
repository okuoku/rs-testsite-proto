(library (components mainframe)
         (export mainframe)
         (import (yuni scheme)
                 (components cmdbar)
                 (components tlstream)
                 (testdata)
                 (proto reactutil)
                 (proto jsutil))

;;

(define dat0 (js-obj "entries" (list->js-array (gen-testdata/left))))
(define dat1 (js-obj "entries" (list->js-array (gen-testdata/right))))

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
                                  (classes (js-ref props "classes")))
                             (ReactDiv 
                               (js-obj "className" (js-ref classes "screen"))
                               (ReactDiv (js-obj "className"
                                                 (js-ref classes "upper"))
                                         (cmdbar))
                               (ReactDiv (js-obj "className" 
                                                 (js-ref classes "lower"))
                                         (tlstream dat0)
                                         (ReactDiv 
                                           (js-obj "className"
                                                   (js-ref classes "hpad")))
                                         (tlstream dat1)))))))))
         
)
