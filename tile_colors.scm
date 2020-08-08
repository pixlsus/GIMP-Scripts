; tile_colors.scm
; version 1.0
; last modified/tested by Gord Duff
; 04/19/2020 on GIMP-2.8.14
;
;==============================================================
;
; Installation:
; This script should be placed in the user or system-wide script folder.
;
;    Windows 10
;    C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;    or
;    C:\Users\YOUR-NAME\.gimp-2.8\scripts 
;    
;    Linux
;    /home/yourname/.gimp-2.8/scripts  
;    or
;    Linux system-wide
;    /usr/share/gimp/2.0/scripts
;
;==============================================================
;
; Description
;
; Using the currently opened image, changes the hue as many times
; as the user specifies and appends those colored images together
; into one resultant image. 
;
; This is good for producing different colored game sprites,
; of the same shape.
;
; Not expected to be used with large images
;
;==============================================================

(define (my-tile_colors img drawable num)

	(let*
	  (
            ; get the width and height of the current image
	    (width (car (gimp-image-width img)) )
	    (height (car (gimp-image-height img)) )

            ; copy contents of image to the clipboard
	    (dummy1 (gimp-edit-copy drawable) )

            ; create new image to paste all the rotated images to
	    (new-img (car (gimp-image-new (* width num) height RGB))  ) 

            ; create a layer for the new image
	    (new-layer (car (gimp-layer-new  new-img width height RGB-IMAGE "a0" 100 NORMAL-MODE)) ) 

            ; new layer goes in the new image
	    (dummy2 (gimp-image-insert-layer new-img new-layer 0 0) )

            ; get the drawable for the new image/layer. this will be used to paste
	    (new-drawable (car (gimp-image-get-active-drawable new-img)) ) 

            ; perform the first paste from clipboarded image
	    (floating-sel-layer (car (gimp-edit-paste new-drawable TRUE))        )

	    (ii 0)
	    (t 0)
	  )

            ; repeat user specified amount of times: paste the image, translate it to the next position,
            ; change it by the next hue, finally make it an actual layer (not just a pasted "floating selection")
	    (while (< ii (+ num 1))
		(set! floating-sel-layer  (car (gimp-edit-paste new-drawable TRUE))   ) 
		(set! t  (- (* ii (/ 360 num))  180)  )
		(gimp-layer-translate floating-sel-layer (* width ii) 0)
		(gimp-hue-saturation floating-sel-layer 0 t 0 0)
		(gimp-floating-sel-to-layer floating-sel-layer)
	    (set! ii (+ ii 1))
	    )

            ; flatten the new image to a single layer
	    (gimp-image-flatten new-img)
            (gimp-display-new new-img)
	)

)


;
; Register script with script-fu and put it in the image menu
;
(script-fu-register "my-tile_colors"
		    "Tile Colors"
		    "Append differently hued images into one single image"
		    "Gord Duff"
		    "Gord Duff"
		    "July 2020"
		    ""
		    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Current Layer" 0
		    SF-VALUE "Num"  "4"
                    )

(script-fu-menu-register "my-tile_colors" "<Image>/Image")
