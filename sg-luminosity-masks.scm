; Create Luminosity Masks for an image
; Originally authored by Patrick David <patdavid@gmail.com>
; re-coded by Saul Goode to honor selection and layer offsets
; Will isolate light, mid, and dark tones in an image as channel masks
; Adapted from tutorial by Tony Kuyper (originally for PS)
; http://goodlight.us/writing/luminositymasks/luminositymasks-1.html 

; 2016-02-22 - Pat David
; Adapted for GIMP 2.9.x by updating some deprecated pdb calls to
; their new versions.

; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

(define (script-fu-sg-luminosity-masks image drawable)
  (gimp-image-undo-group-start image)
  (let ((orig-sel (car (gimp-selection-save image)))
        (L (car (gimp-selection-save image)))
        (LL #f)
        (LLL #f)
        (D #f)
        (DD #f)
        (DDD #f)
        (M #f)
        (MM #f)
        (MMM #f)
        (masks '())
        (name (car (gimp-item-get-name drawable))) )
    (set! masks (cons L masks))
    (gimp-item-set-name L (string-append "L-" name))
    (gimp-selection-none image)
    ; paste uses luminosity desaturation method
    (let ((buffer (car (gimp-edit-named-copy drawable "temp"))))
      (gimp-floating-sel-anchor (car (gimp-edit-named-paste L buffer TRUE)))
      (gimp-buffer-delete buffer) )
    (set! D (car (gimp-channel-copy L)))
    (gimp-image-insert-channel image D 0 1)
    (gimp-item-set-name D (string-append "D-" name))
    (gimp-invert D)
    (set! masks (cons D masks))

    (set! DD (car (gimp-channel-copy D)))
    (gimp-image-insert-channel image DD 0 2)
    (gimp-item-set-name DD (string-append "DD-" name))
    (gimp-channel-combine-masks DD L CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons DD masks))

    (set! DDD (car (gimp-channel-copy DD)))
    (gimp-image-insert-channel image DDD 0 3)
    (gimp-item-set-name DDD (string-append "DDD-" name))
    (gimp-channel-combine-masks DDD L CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons DDD masks))

    (set! LL (car (gimp-channel-copy L)))
    (gimp-image-insert-channel image LL 0 1)
    (gimp-item-set-name LL (string-append "LL-" name))
    (gimp-channel-combine-masks LL D CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons LL masks))
    
    (set! LLL (car (gimp-channel-copy LL)))
    (gimp-image-insert-channel image LLL 0 2)
    (gimp-item-set-name LLL (string-append "LLL-" name))
    (gimp-channel-combine-masks LLL D CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons LLL masks))
    
    (set! M (car (gimp-channel-copy L)))
    (gimp-image-insert-channel image M 0 3)
    (gimp-item-set-name M (string-append "M-" name))
    (gimp-channel-combine-masks M D CHANNEL-OP-INTERSECT 0 0)
    (set! masks (cons M masks))

    (set! MM (car (gimp-channel-copy LL)))
    (gimp-image-insert-channel image MM 0 3)
    (gimp-item-set-name MM (string-append "MM-" name))
    (gimp-invert MM)
    (gimp-channel-combine-masks MM DD CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons MM masks))

    (set! MMM (car (gimp-channel-copy LLL)))
    (gimp-image-insert-channel image MMM 0 3)
    (gimp-invert MMM)
    (gimp-item-set-name MMM (string-append "MMM-" name))
    (gimp-channel-combine-masks MMM DDD CHANNEL-OP-SUBTRACT 0 0)
    (set! masks (cons MMM masks))
    
    ;(gimp-selection-load orig-sel)
    (gimp-image-select-item image CHANNEL-OP-REPLACE orig-sel)
    (if (or (= (car (gimp-selection-is-empty image)) TRUE)
            (= (car (gimp-drawable-mask-intersect drawable)) FALSE) )
      (gimp-selection-all image) )
    ;(gimp-rect-select image
    ;                  (car (gimp-drawable-offsets drawable))
    ;                  (cadr (gimp-drawable-offsets drawable))
    ;                  (car (gimp-drawable-width drawable))
    ;                  (car (gimp-drawable-height drawable))
    ;                  CHANNEL-OP-INTERSECT 0 0 )
    (gimp-image-select-rectangle image 
                                 CHANNEL-OP-INTERSECT
                                 (car (gimp-drawable-offsets drawable))
                                 (cadr (gimp-drawable-offsets drawable))
                                 (car (gimp-drawable-width drawable))
                                 (car (gimp-drawable-height drawable)) )

    (gimp-selection-invert image)
    (unless (= (car (gimp-selection-is-empty image)) TRUE)
      (map (lambda (x) (gimp-edit-fill x WHITE-FILL)
                       (gimp-invert x) )
           masks ))
    ;(gimp-selection-load orig-sel)
    (gimp-image-select-item image CHANNEL-OP-REPLACE orig-sel)
    (gimp-image-remove-channel image orig-sel)
    )
  (gimp-image-set-active-layer image drawable)
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
  )
(script-fu-register "script-fu-sg-luminosity-masks"
                    "Luminosity Masks (saulgoode)"
                    "Create Luminosity Masks of Layer"
                    "saul goode"
                    "saul goode"
                    "Nov 2013"
                    "RGB*, GRAY*"
      SF-IMAGE "Image" 0
      SF-DRAWABLE "Drawable" 0
)

(script-fu-menu-register "script-fu-sg-luminosity-masks" "<Image>/Filters/Generic")

