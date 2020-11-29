### Extract image sequence, starting from 4min16, length 1 sec., jpg quality 3 (1-32)
`ffmpeg -ss 00:04:16 -t 1 -i output.mp4 -qscale:v 3 mp4_%03d.jpg`

### Convert input.vob to output.mp4 using de-interlacing (yadif/yadif_cuda), converting the audio to 256k AAC
`ffmpeg -i input.VOB -vf yadif -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k output.mp4`

### Convert Source.mkv to out.mp4, copying the audio
`ffmpeg -y -i Source.mkv -map 0:v -c:v libx264 -map 0:a -c:a copy out.mp4`

### Convert input.mp4 to output.mp4 with H.264 video at 720p resolution and with the same audio codec
`ffmpeg -y -vsync 0 -hwaccel cuda -hwaccel_output_format cuda -i input.mp4 –resize 1280x720 -c:a copy -c:v h264_nvenc -b:v 1M output.mp4`

### Extract audio (mka is most universal container, see ffmpeg site), probe audio type with 'ffprobe'
`ffmpeg -i VTS_04_1.VOB -vn -acodec copy output-audio.mka`

### Combine images & audio to new video file
`ffmpeg -r 25 -i frames/frame_%04d.png -i "Bonobo - Kong.mp3" -c:v libx264 -c:a copy -crf 20 -r 25 -shortest -y video-from-frames.mp`

### Get framerate (for use in scripts etc)
`ffmpeg -i VTS_04_1.VOB 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`

### Convert to DNxHR (_lb, _sq, _hq, _hqx, _444)
`ffmpeg -i "inputvideo.mp4" -c:v dnxhd  -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le "outputvideo.mxf"`

### Convert VHS/DVD to H264, correcting aspect for Double8 8mm video format, also applying deinterlacing
`ffmpeg -i VTS_01_4.VOB -vf yadif,scale=784x576,setdar=dar=1.361 -map 0:v -c:v libx264 -preset slow -crf 20 -map 0:a -c:a copy out.mkv`

### Convert VHS/DVD to H264, correcting aspect for Super 8mm video format, also applying deinterlacing
`ffmpeg -i VTS_01_4.VOB -vf yadif,scale=830x576,setdar=dar=1.441 -map 0:v -c:v libx264 -preset slow -crf 17 -map 0:a -c:a copy out.mkv`
