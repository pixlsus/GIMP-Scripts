; This script contains the command syntax for G'MIC git post v1.79
; refer to the original post for scripts for v1.79 & older
; https://discuss.pixls.us/t/a-masashi-wakui-look-with-gimp/2771/6

(define (script-fu-wakui
            theImage
            baseLayer
        )	
   ; Initialize an undo, so the process can be undone with a single undo
     (gimp-image-undo-group-start theImage)


     (define bluedarksLayer (car (gimp-layer-new-from-drawable baseLayer theImage )))
     (gimp-image-insert-layer theImage bluedarksLayer 0 0) ; duplicate base layer
     (gimp-item-set-name bluedarksLayer "Blue shadows layer") ; rename the dupe layer

     (plug-in-gmic-qt 1 theImage bluedarksLayer 1 0 "-v - -fx_mix_rgb 1,0,0,1,0,0,0.60,0,0,1,2,2") ; apply RGB mixer to shadows
     
     (define warmmidsLayer (car (gimp-layer-new-from-visible theImage theImage "Warm midtones layer")))
     (gimp-image-insert-layer theImage warmmidsLayer 0 0)
     (plug-in-gmic-qt 1 theImage warmmidsLayer 1 0 "-v - -fx_mix_rgb 0.88,72,0,0.79,32,0,1,0,0,2,2,2") ; apply RGB mixer to midtones

     (define wakuiLayer (car (gimp-layer-new-from-visible theImage theImage "Wakui style layer")))
     (gimp-image-insert-layer theImage wakuiLayer 0 0)

     (gimp-image-remove-layer theImage bluedarksLayer)
     (gimp-image-remove-layer theImage warmmidsLayer)
     
     ;Ensure the updated image is displayed now
     (gimp-displays-flush)

     (gimp-image-undo-group-end theImage)

) ;end define

(script-fu-register "script-fu-wakui"
	_"<Image>/Script-Fu/Wakui..."
            "This script tries to emulate the style of color toning as found in Masashi MAkui's work. It uses the RGB mixer in G'MIC."
            "Sébastien Guyader"
            "Sébastien Guyader"
            "December 2016"
            "*"
	SF-IMAGE		"Image"     0
	SF-DRAWABLE		"Drawable"  0
)

