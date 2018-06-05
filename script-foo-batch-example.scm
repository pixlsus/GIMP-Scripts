   (script-fu-register                       ;Here we start registering our script in the
                                              ;Gimp's procedural database (so it will appear
                                              ;in the Help>>Procedure Browser) and any other
                                              ;script will be able to run it
                                           ;Next you have to set a few required parameters:
         "script-fu-wavelets-batch"        ;you give a name to your script, anything
                                           ;you want, but better if it begins with "script-fu".
                                           ;It will be used along the script
         "Batch wavelet sharpen"           ;the name of the script shown in the submenu
                                           ;(this script is about applying a sharpen plugin
                                           ;to a group of images, hence the name)
         "Batch process to sharpen images\
           using Wavelet sharpen plugin."  ;a description of the script shown as a tooltip
                                           ;(when you mouse over the submenu name)
         "Javier Bartol"                   ;author
         "CC-BY-SA-3.0"                    ;copyright
         "April 02, 2018"                  ;creation date
         "*"                               ;types of images the script is intended to work
                                           ;with (in this case, any type, but it could be
                                           ;RGB, RGBA, GRAY, GRAYA, INDEXED or INDEXEDA)

                                                      ;Now you need to give the kind of data
                                                      ;each function parameter accepts:
                                                      ;look at the parameters defined in the
                                                      ;main function, and set them
                                                      ;in THE SAME ORDER
          SF-STRING    "Images"     "~/Images/*.tif"  ;the first parameter has to be a
                                                      ;string of characters (SF-STRING)
                                                      ;when running the script a dialog will show, and
                                                      ;this first parameter will be labeled as "Images"
                                                      ;and it will have a default content "~/Images/*.tif"
                                                      ;(this will be the path to the files, and the type of
                                                      ;images processed)
          SF-VALUE     "Amount"     "0"               ;the second parameter relates to the
                                                      ;information needed by the wavelet
                                                      ;sharpen plugin. It has to be a number (SF-VALUE),
                                                      ;and the default value is "0"
                                                      ;(this will be the amount of sharpening applied)
          SF-VALUE     "Radius"     "0.6"             ;the third parameter has to be a number,
                                                      ;being "0.6" the default value (it will be the radius
                                                      ;of sharpening)
          SF-TOGGLE    "Luminance"   1                ;the last parameter must answer a YES/NO
                                                      ;question: it will ask if you will sharpen luminance
                                                      ;channel only (well, in fact, you will only see a label
                                                      ;saying "Luminance", and you will have to guess it is
                                                      ;asking if you want to sharpen luminance only)
                                                      ;default value is YES, or "1"
    )

    (script-fu-menu-register "script-fu-wavelets-batch" "<Image>/Filters/Enhance")
               ;Now you are registering the script in the Gimp menus, using the name you gave
               ;it, so you will find your script in Filters>>Enhance>>Batch wavelet sharpen
               ;(apparently <Image> is the root of every menu)



    (define (script-fu-wavelets-batch ask-fileglob ask-amount ask-radius ask-luminance)
              ;Declaration of the main function (the part of the script that does the work)
              ;you tell Gimp the name of your script (script-fu-wavelets-batch), and which
              ;parameters has to ask the user when launching it. Those parameters are just
              ;variables, and it's better if they have meaningful names to you.
              ;Here I add "ask-" to each variable to remind me Gimp will ask for their values
    (let*                                  ;Here it is: the engine of the script
        ((thefiles (cadr (file-glob ask-fileglob 0))))  ;Let's go from the inner to the outer part
                                                        ;remember that "ask-fileglob" is the first parameter of
                                                        ;your function, and is defined as a string of characters,
                                                        ;with a default value "~/Images/*.tif"
                                                        ;"file-glob" will search the path given by "ask-fileglob"
                                                        ;and will return a number followed by a list of strings of
                                                        ;characters. Each string of characters will be the full
                                                        ;path and filename of each image
                                                        ;so we will get: a number, the full path/filename of the
                                                        ;first image, the full path/filename of the second image,
                                                        ;and so on
                                                        ;with "cadr" we will remove the number from the list (read
                                                        ;https://www.gimp.org/tutorials/Basic_Scheme/, chapter 3.1),
                                                        ;although I'm not pretty sure why one has to use "cadr"
                                                        ;instead of "cdr"
                                                        ;so, the variable "thefiles" will hold a list returned by
                                                        ;"file-glob", removing the first member of the list (the number)
                                                        ;the trailing "0" means that the filenames will be coded in UTF-8

        (while (not (null? thefiles))
                               ;While the list inside "thefiles" is not empty, the script will
                               ;perform the actions inside this loop
          (let*
            ((thefilename (car thefiles)) 
                               ;the variable "thefilename" will hold the first item (car)
                               ;from the "thefiles" list
             (image (car (gimp-file-load RUN-NONINTERACTIVE thefilename thefilename)))
                               ;then the image with the path present in "thefilename" is loaded
             (drawable (car (gimp-image-get-active-layer image)))
                               ;as a last step, the active layer is made the modifiable (drawable)
                               ;part of the image (this has to do with Gimp internals, and may be
                               ;used in advanced scripts, but here is the same as the full image)
            )
            (gimp-image-undo-disable image)
                               ;the undo cache is disabled (this is not really necessary in this simple script)
            (plug-in-wavelet-sharpen RUN-NONINTERACTIVE image drawable ask-amount ask-radius ask-luminance)
                               ;the plugin Wavelet sharpen is launched
                               ;to know which parameters the plugin needs, open the Procedure
                               ;Database and it will be listed as "plug-in-wavelet-sharpen"
                               ;"RUN-NONINTERACTIVE" is set so the plugin doesn't ask for user
                               ;input on each image
                               ;"image" is the image to work with
                               ;"drawable" is the editable part of the image to work with
                               ;(in our case, it's the full image)
                               ;"ask-amount" is the second parameter the script asks in the dialog
                               ;It's a number, and it will be the amount of sharpening the plugin will apply
                               ;"ask-radius" is the third parameter of the function. It's a number (as
                               ;defined at the beggining, when registering the script), and will be the
                               ;radius used by the plugin
                               ;"ask-luminance" is the last parameter of the function. It will be a tick box,
                               ;and will be ticked by default, meaning the plugin will sharpen only the
                               ;luminance channel
            (gimp-image-undo-enable image)
                               ;the undo cache is enabled again (this is not really necessary and you can
                               ;remove both disabling and enabling of undo cache)
            (gimp-file-save RUN-NONINTERACTIVE image drawable thefilename thefilename)
                              ;saves/overwrites the image stored in "thefilename". BE CAREFUL WITH THIS!
                              ;You may lose your original images!
                              ;If you want to save files with different names, maybe you will find a solution in
                              ; http://www.gimptalk.com/index.php?/topic/34672-script-fu-how-to-increment-filenames
                              ;and http://it-nonwhizzos.blogspot.com.es/2014/10/gimp-script-scheme-to-scale-multiple.html
            (gimp-image-delete image)
                              ;close the image
          )
          (set! thefiles (cdr thefiles))
                              ;modifies the content of "thefiles", giving it the same list as before, but removing
                              ;the first item (the previously first image of the list)
        )                     ;here the loop is closed and returns back to checking if "thefiles" is not an empty list
    )
)
