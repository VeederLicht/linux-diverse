## Extract image sequence, starting from 4min16, length 1 sec., jpg quality 3 (1-32)
`ffmpeg -ss 00:04:16 -t 1 -i output.mp4 -qscale:v 3 mp4_%03d.jpg`

## Convert input.vob to output.mp4 using de-interlacing (yadif), converting the audio to 256k AAC
`ffmpeg -i input.VOB -vf yadif -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k output.mp4`

## Convert Source.mkv to out.mp4, copying the audio
`ffmpeg -y -i Source.mkv -map 0:v -c:v libx264 -map 0:a -c:a copy out.mp4`


## Convert input.mp4 to output.mp4 with H.264 video at 720p resolution and with the same audio codec
`ffmpeg -y -vsync 0 -hwaccel cuda -hwaccel_output_format cuda -i input.mp4 –resize 1280x720 -c:a copy -c:v h264_nvenc -b:v 1M output.mp4`
