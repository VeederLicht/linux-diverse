# Linux Tools


## enfuse

`enfuse <OPTIONS> <INPUT> -o <OUTPUT>`

NOTE: does NOT copy EXIF data


## gmic

`gmic <INPUT> -blend <TYPE> -o <OUTPUT>`


## imagemagick

`convert <INPUT> -filter <TYPE point/spline/quadratic> -evaluate-sequence <TYPE mean> -sharpen 10 <OUTPUT>`


To equalize the light distribution in an image:

`redist -s gaussian 60,60,60 <INPUT> <OUTPUT>`

## xbrzscale

`xbrzscale <FACTOR 2-5> <INPUT> <OUTPUT.png>`

NOTE: does NOT copy EXIF data


## align_image_stack

`align_image_stack [OPTIONS] input_files -a <OUTPUT>`

NOTE: see options here <https://wiki.panotools.org/Align_image_stack>
