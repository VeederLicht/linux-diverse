## EXTRACT

### Extract image sequence, starting from 4min16, length 1 sec., jpg quality 3 (1-32)
`ffmpeg -ss 00:04:16 -t 1 -i input.mp4 -qscale:v 3 out_%05d.jpg`

### Extract image sequence, using cuda, deinterlace (yadif is more consistent then bwdif),rescale & set display aspect ratio
`ffmpeg -y -init_hw_device cuda=gtx:0 -i input.mp4 -filter_hw_device gtx -vf yadif,scale=784x576,setdar=dar=1.361 -qscale:v 1 out_%05d.jpg`

### Extract image sequence, ..., +filters removegrain/grayscale/normalize/yuv420p, export to webp (efficient!!)
`ffmpeg -y -i input.mp4 -vf yadif,scale=784x576,setdar=dar=1.361,removegrain=4:4:4:4,unsharp=5:5:0.5,eq=saturation=0,normalize=blackpt=black:whitept=white:smoothing=0,format=yuv420p -q:v 90 out_%05d.webp`

### Extract audio (mka is most universal container, see ffmpeg site), probe audio type with 'ffprobe'
`ffmpeg -i input.mp4 -vn -acodec copy output-audio.mka`

### Denoise pour audio ('middle-pass', 200-3000Hz)
`ffmpeg -i input.mp4 ... -af highpass=f=200,lowpass=f=3000 -c:a aac -b:a 96k output.mka`

### Denoise images (1.5 seems to be the maximum reasonable sharpening strength)
`ffmpeg -i input.png -vf unsharp=3:3:1.5,bm3d=sigma=8:bstep=12:mstep=8:group=1:estim=basic,atadenoise test1_bm3d_2.png

<br>
<br>

## CONVERT

### To apply letterbox/pillarbox, scaling to 1280x720
`ffmpeg -i input -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1:color=black" output.mp4`
https://superuser.com/questions/547296/resizing-videos-with-ffmpeg-avconv-to-fit-into-static-sized-player
https://superuser.com/questions/891145/ffmpeg-upscale-and-letterbox-a-video

### Convert input.vob to output.mp4 using de-interlacing (yadif/yadif_cuda), converting the audio to 256k AAC
`ffmpeg -i input.VOB -vf yadif -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k output.mp4`

### Convert Source.mkv to out.mp4, copying the audio
`ffmpeg -y -i Source.mkv -map 0:v -c:v libx264 -map 0:a -c:a copy out.mp4`

### Convert input.mp4 to output.mp4 with H.265 video (standard audio settings)
`ffmpeg -y -init_hw_device cuda=gtx:0 -i VTS_01_4.VOB -filter_hw_device gtx -vf yadif,scale=784x576,setdar=dar=1.361 -c:v hevc_nvenc output.mp4`
#### Using NVIDIA, denoising+sharpening, constant quality, high profile, slow preset
`ffmpeg -i input.mp4 -init_hw_device cuda=gtx:0 -filter_hw_device gtx -vf removegrain=2:2:2:2,unsharp=5:5:0.7:3:3:0.4 -c:v hevc_nvenc -preset slow -rc:v vbr_hq -cq:v 28 -c:a copy output.mp4`

### Scale using CUDA
`-vf ...,hwupload_cuda,scale_cuda=w=-2:h=1080,hwdownload,...`

### Combine images & audio to new video file
`ffmpeg -r 25 -i frames/frame_%04d.png -i "Bonobo - Kong.mp3" -c:v libx264 -c:a copy -crf 20 -r 25 -shortest -y video-from-frames.mp`

### Get framerate (for use in scripts etc)
`ffmpeg -i VTS_04_1.VOB 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`

### Convert to DNxHR (_lb, _sq, _hq, _hqx, _444)
`ffmpeg -i input.mts -vf format=yuv422p -c:v dnxhd -b:v 90M -c:a pcm_s16le output.mxf`

### Convert VHS/DVD to H264, correcting aspect for Double8 8mm video format, also applying deinterlacing
`ffmpeg -i VTS_01_4.VOB -vf yadif,scale=784x576,setdar=dar=1.361 -map 0:v -c:v libx264 -preset slow -crf 20 -map 0:a -c:a copy out.mkv`

### Convert VHS/DVD to H264, correcting aspect for Super 8mm video format, also applying deinterlacing
`ffmpeg -i VTS_01_4.VOB -vf yadif,scale=830x576,setdar=dar=1.441 -map 0:v -c:v libx264 -preset slow -crf 17 -map 0:a -c:a copy out.mkv`

<br>
<br>

## INFO

### Count number of frames
```
ffprobe -v fatal -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 input.mp4
```

<br>
<br>

## USING FFMPEG AS MIDDLEWARE
It appears that applying ffmpeg-filters *before* colorization processes will influence the resulting colors. Also, currently many AI restoration tools can only handle sub 900K pixel images relyably.

Solution:

1. Extract images (do interlace!, interlaced images color pourly):
```
ffmpeg -y -i input.mp4 -vf yadif,format=yuv420p -q:v 90 out_%05d.jpg.webp
```

2. naar DeepAI / BOPBTL

3. Apply other effects:
```
ffmpeg -y -i ai_out.jpg -vf \
                                 scale=784x576 \
                                 ,setdar=dar=1.361 \
                                 ,removegrain=4:4:4:4 \
                                 ,unsharp=11:11:0.4:5:5:0.0 \
                                 ,normalize=blackpt=black:whitept=white:smoothing=0 \
                                 ,format=yuv420p \
                                 -q:v 90 mp4_0011-vfilters.webp
```

## TIPS

  * MKV container is probably the most versatile container. Contains practically any type of audio+video codec
  * MKA like above
  * Editable formats for non-linear video editors are ProRes, DNXHD and DNXHQ
