(define (script-fu-hillustrative
            theImage
            baseLayer
            with_fast_tone_mapping
            desaturate
            vintage
        )	
   ; Initialize an undo, so the process can be undone with a single undo
     (gimp-image-undo-group-start theImage)


     (define blurLayer (car (gimp-layer-new-from-drawable baseLayer theImage )))
     
     (gimp-image-insert-layer theImage blurLayer 0 0) ; duplicate base layer
     (gimp-item-set-name blurLayer "Blur layer") ; rename the dupe layer

     (plug-in-gmic 1 theImage blurLayer 1 "-v - -gimp_smooth_anisotropic 20,0.16,0.63,0.6,2.35,0.8,30,2,0,1,1,0,1,24") ; apply anisotropic smoothing
     (gimp-layer-set-mode blurLayer GRAIN-EXTRACT-MODE) ; set mode to grain extract
     
     (gimp-displays-flush)
     
     (define detailLayer (car (gimp-layer-new-from-visible theImage theImage "Detail layer")))

  
     (if (= desaturate TRUE)
        (begin
             (gimp-drawable-hue-saturation blurLayer 0 0 0 -40 0) ; decrease saturation
        )
     )
     
     (if (= vintage TRUE)
        (begin
           (plug-in-gmic 1 theImage blurLayer 1 "-v - -gimp_mix_rgb 1,10,0,1,0,0,0.7,-10,0,0,10,0") ; vintage
        )
     )    
      
     (if (= with_fast_tone_mapping TRUE)
        (begin
            ; code to do if selected
     	    (plug-in-gmic 1 theImage blurLayer 1 "-v - -gimp_map_tones_fast 20,0.2,11,0")
     	)
     )

     (gimp-image-insert-layer theImage detailLayer 0 0)
     (gimp-layer-set-mode detailLayer GRAIN-MERGE-MODE) ; set layer mode to grain merge
     
     (gimp-layer-set-mode blurLayer NORMAL-MODE) ; set blur layer mode back to to normal
     (gimp-item-set-name blurLayer "Simple Local Contrast") ; rename the dupe layer
     
     (gimp-image-set-active-layer theImage blurLayer)     
     (plug-in-gmic 1 theImage blurLayer 1 "-v - -simplelocalcontrast_p 25,1,50,1,1,1,1,1,1,1,1,1") ; apply simple local contrast    

     (define graphicnovelLayer (car (gimp-layer-new-from-drawable blurLayer theImage )))
     (gimp-image-insert-layer theImage graphicnovelLayer 0 0) ; duplicate base layer
     (gimp-item-set-name graphicnovelLayer "Graphic Novel") ; rename the dupe layer
     (plug-in-gmic 1 theImage graphicnovelLayer 1 "-v - -gimp_graphic_novelfxl 1,2,6,5,20,0,1.02857,200,0,1,0.0761905,0.0857143,0,0,0,2,1,1,1,1.25714,0.371429,1.04762") ; apply Graphic Novel
     (gimp-layer-set-opacity graphicnovelLayer 50)
     
     (gimp-image-raise-item-to-top theImage detailLayer)

     ;Ensure the updated image is displayed now
     (gimp-displays-flush)

     (gimp-image-undo-group-end theImage)

) ;end define

(script-fu-register "script-fu-hillustrative"
	_"<Image>/Script-Fu/Hillustrative..."
            "This script tries emulating a photo-illustrative look à la Dave Hill, using G'MIC filters for local contrast and highlight bloom, and grain extract/merge for recovering details. After the script has finished its job, it will leave 4 layers: the original base layer, the Simple Local Contrast layer, the Graphic Novel, and the Detail layer (from bottom to top)."
            "Sébastien Guyader"
            "Sébastien Guyader"
            "December 2016"
            "*"
	SF-IMAGE		"Image"     0
	SF-DRAWABLE		"Drawable"  0
	SF-TOGGLE		"With tone mapping" TRUE
	SF-TOGGLE		"Desaturate" FALSE
	SF-TOGGLE		"Vintage tone" FALSE
)

