(library (appmain)
         (export main)
         (import (yuni scheme) 
                 (components mainframe)
                 (proto reactutil)
                 (proto react-mui)
                 (proto jsutil))

;; Globals
(define d (yuni/js-import "d"))
;; Delayed initialized components
(define Mainapp #f)

(define (pp obj)
  (js-call (yuni/js-import "pp") obj))

(define (init-classes!) 
  (PCK 'INIT)
  (define count 0)
  (define theCounter (js-obj "count" count))
  (define (count++)
    (set! count (+ count 1))
    (js-set! theCounter "count" count)
    theCounter)

  (define counter-object
    (make-react-class
      "render" (wrap-this this
                          (Button
                            (js-obj "color" "primary"
                                    "onClick" 
                                    (js-ref this "handleClick"))
                            (number->string
                              (js-ref (js-ref this "state")
                                      "count"))))

      "handleClick" (wrap-this this
                               (count++)
                               (PCK 'COUNT count)
                               (js-invoke this "setState" theCounter))
      "getInitialState" (js-closure (lambda () theCounter))))
  (define (main-app)
    (make-react-class
      "render" (wrap-this _ 
                          (ReactDiv
                            #f
                            (ReactFragment
                              #f
                              (CssBaseline)
                              (AppBar (js-obj "position" "static")
                                      (Toolbar (js-obj "variant" "dense")
                                               (Typography #f "Title")))
                              (counter-object theCounter))))))

  (set! Mainapp (main-app)))

(define (main)
  (init-classes!)
  ;(js-invoke d "render" (Mainapp) (yuni/js-import "document-root"))
  (js-invoke d "render" (mainframe) (yuni/js-import "document-root")))

(PCK 'LOAD)
)
