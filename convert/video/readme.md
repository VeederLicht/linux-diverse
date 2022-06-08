## EXTRACT

#### E01. Extract image sequence, starting from 4min16, length 1 sec., jpg quality 3 (1-32)
```
ffmpeg -ss 00:04:16 -t 1 -i input.mp4 -qscale:v 3 out_%05d.jpg
```

#### E02. Extract image sequence, using cuda, deinterlace (yadif is more consistent then bwdif),rescale & set display aspect ratio
```
ffmpeg -y -init_hw_device cuda=gtx:0 -i input.mp4 -filter_hw_device gtx -vf yadif,scale=784x576,setdar=dar=1.361 -qscale:v 1 out_%05d.jpg
```

#### E03. Extract image sequence, ..., +filters removegrain/grayscale/normalize/yuv420p, export to webp (efficient!!)
```
ffmpeg -y -i input.mp4 -vf yadif,scale=784x576,setdar=dar=1.361,removegrain=4:4:4:4,unsharp=5:5:0.5,eq=saturation=0,normalize=blackpt=black:whitept=white:smoothing=0,format=yuv420p -q:v 90 out_%05d.webp
```

#### E04. ... to JPEG-2000 frames
```
-c:v libopenjpeg -q:v 2 out.jp2
```

#### E05. Extract audio (mka is most universal container, see ffmpeg site), probe audio type with 'ffprobe'
```
ffmpeg -i input.mp4 -vn -acodec copy output-audio.mka
```

#### E06. Denoise pour audio ('middle-pass', 200-3000Hz)
```
ffmpeg -i input.mp4 ... -af highpass=f=200,lowpass=f=3000 -c:a aac -b:a 96k output.mka
```

#### E07a. Denoise images (1.5 seems to be the maximum reasonable sharpening strength)
```
ffmpeg -i in.jpg -vf format=yuv420p,scale=1920:-2:sws_flags=gauss,setsar=sar=1/1,uspp=3:4,bm3d=sigma=4,unsharp=3:3:1 -vcodec libwebp -lossless 0 -q:v 50 -preset picture -an out.webp
```

#### E07a. Same, but oneliner for batch processing 
```
for fin in *.jpg; do ffmpeg -i $fin -vf format=yuv420p,scale=1920:-2:sws_flags=gauss,setsar=sar=1/1,uspp=3:4,bm3d=sigma=4,unsharp=3:3:1 -vcodec libwebp -lossless 0 -q:v 50 -preset picture -an $fin.webp; done
```

<br>
<br>

## CONVERT

### 2-pass high quality

#### C01. AV1 (superb but slow!), high quality 2-pass settings for batch script
```
Q=50 && EXT="mov" && time for i in  *.${EXT}; do
    nice ffmpeg -y -i "$i" -c:v libaom-av1 -strict -2 \
         -b:v 0 -crf $Q \
         -aq-mode 2 -an \
         -sc_threshold 0 \
         -row-mt 1  -tile-columns 2 -tile-rows 2 -threads 12  \
         -cpu-used 8 \
         -auto-alt-ref 1 -lag-in-frames 25 -g 999 \
         -pass 1 -f webm \
         "$(basename "$i" .${EXT})"-av1.temp
    nice ffmpeg -y -i "$i" -c:v libaom-av1 -strict -2 \
         -b:v 0 -crf $Q -aq-mode 2  \
         -sc_threshold 0 \
         -row-mt 1  -tile-columns 2 -tile-rows 2 -threads 8 \
         -cpu-used 1 \
         -auto-alt-ref 1 -lag-in-frames 25 -g 999 \
         -c:a libopus -b:a 96k \
         -pass 2 -threads 12 \
         "$(basename "$i" .${EXT})"-av1-q${Q}-cpu-used-1.webm
done
```
see: https://www.draketo.de/software/ffmpeg-compression-vp9-av1.html
also: https://www.streamingmedia.com/Articles/Editorial/Featured-Articles/AV1-Has-Arrived-Comparing-Codecs-from-AOMedia-Visionular-and-Intel-Netflix-142941.aspx?utm_source=related_articles&utm_medium=gutenberg&utm_campaign=editors_selection

#### C02. Same for VP9
```
Q=56 && EXT="mov" && time for i in  *.${EXT}; do
    ffmpeg -i input.mp4 -c:v libvpx-vp9 -b:v 0 -crf 40 -pass 1 -an -f null /dev/null && \
    ffmpeg -i input.mp4 -c:v libvpx-vp9 -b:v 0 -crf 40 -pass 2 -c:a libopus -b:a 96k "$(basename "$i" .${EXT})"-(vp9-2pass_crf${Q}).webm
done
```


#### C03. NVENC encoding, high quality!
```
ffmpeg.exe -i in.mov  -c:v h264_nvenc -rc constqp -qp 25 -b:v 0K -b:a 128k -preset slow -tune hq -profile:v high -metadata copyright="..." -metadata comment="..." -metadata title="..." -metadata year="..." out4.mp4
```


### Effects

#### C03. To apply letterbox/pillarbox, scaling to 1280x720
```
ffmpeg -i input -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1:color=black" output.mp4
```
https://superuser.com/questions/547296/resizing-videos-with-ffmpeg-avconv-to-fit-into-static-sized-player
https://superuser.com/questions/891145/ffmpeg-upscale-and-letterbox-a-video

#### C04. Convert input.vob to output.mp4 using de-interlacing (yadif/yadif_cuda), converting the audio to 256k AAC
```
ffmpeg -i input.VOB -vf yadif -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k output.mp4
```

#### C05. Convert Source.mkv to out.mp4, copying the audio
```
ffmpeg -y -i Source.mkv -map 0:v -c:v libx264 -map 0:a -c:a copy out.mp4
```

#### C06. Scale using CUDA
```
-vf ...,hwupload_cuda,scale_cuda=w=-2:h=1080,hwdownload,...
```

#### C07. Combine images & audio to new video file
```
ffmpeg -r 25 -i frames/frame_%04d.png -i "Bonobo - Kong.mp3" -c:v libx264 -c:a copy -crf 20 -r 25 -shortest -y video-from-frames.mp
```

#### C08. H265 encoding with fixed bitrate output, VHS with heavy smoothing
```
-c:v hevc_nvenc -preset slow -cbr true -b:v 1.5M -c:a aac -b:a 196k
```

### Pre/postprocess

#### P01. ... to DNxHR (_lb, _sq, _hq, _hqx, _444)
```
ffmpeg -i input.mts -vf format=yuv422p,... -c:v dnxhd -b:v 90M -c:a pcm_s16le output.mxf
```

#### P02. ...to all-intra H265 DNxHR alternative (YUV444 capable! but not widely supported):
```
ffmpeg -i in.mov "format=yuv420p,setsar=sar=1/1,bm3d=sigma=12,atadenoise,unsharp=3:3:0.4,unsharp=5:5:0.2" -c:v hevc_nvenc -preset llhq -intra -qp:v 15 -movflags use_metadata_tags -c:a aac -b:a 384k out.mp4
```

#### P03. ...using deinterlacing, scaling (this example 4:3 aspect), and deblocking (uspp is the best by far, see also 'convertall.sh')
```
-vf format=yuv420p,yadif,uspp=2:2,scale=ih/3*4:ih:sws_flags=gauss,setsar=sar=1/1
```

#### P04. ...deinterlace using cuda
```
-init_hw_device cuda=gtx:0 -filter_hw_device gtx -vf hwupload_cuda,yadif_cuda,hwdownload,...
```

#### P05. Edge preserving blur for blocky footage (negative smartblur actually sharpens)
```
-vf scale=-2:1080:sws_flags=gauss,yaepblur,smartblur=ls=-1
```

#### P06. Preprocess output, relying on H264 deblocking
```
-c:v h264_nvenc -preset:v slow -2pass true -profile:v high -rc vbr_hq -c:a aac -b:a 256k OUTPUT.mp4
```

#### P07. Postprocess output, merge 2 streams
```
ffmpeg -i INPUT.mp4 -i INPUT.mp3 -map 0:v -c:v libx264 -preset slow -crf 17 -map 0:a -c:a copy out.mkv
```

#### MERGE STREAMS (v=video, a=audio, s=subtitles):
            ffmpeg -i input1.mp4 -i input2.mp4  -c:v copy -c:a copy -b:a 96k -map 0:0 -map 1:s output.mp4

<br>

## WEBCAM

### Windows (dshow)

```
ffmpeg -f dshow -video_size 640x480  -i video="USB Camera":audio="Microfoon (2- USB Audio CODEC )" -vf format=yuv420p,scale=128:-2:sws_flags=gauss,crop=128:72,atadenoise,setsar=sar=1/1 -c:v libx264 -preset fast -qp:v 30 -af "highpass=f=200,lowpass=f=3000,afftdn=nt=w:om=o" -c:a aac -b:a 48k out.mp4 -y
```

**met compressie en H265**

```
ffmpeg -f dshow -video_size 640x480  -i video="USB Camera":audio="Microfoon (2- USB Audio CODEC )" -vf format=yuv420p,scale=128:-2:sws_flags=gauss,crop=128:72,atadenoise,setsar=sar=1/1 -c:v libx265 -qp:v 25 -af "highpass=f=200,lowpass=f=3000,afftdn=nt=w:om=o,compand=attacks=0:points=-80/-900|-45/-15|-27/-9|-5/-5|20/20" -c:a aac -b:a 32k out.mp4 -y
```

**webm vp9 (zeer goed!)**

```
ffmpeg -f dshow -video_size 640x480  -i video="USB Camera":audio="Microfoon (2- USB Audio CODEC )" -vf format=yuv420p,scale=128:-2:sws_flags=gauss,crop=128:72,atadenoise,setsar=sar=1/1 -c:v libvpx-vp9 -crf:v 35 -af "highpass=f=200,lowpass=f=3000,afftdn=nt=w:om=o"  -c:a libopus -b:a 32k out.webm -y
```

### Linux (v4l2)

In Linux lijkt het  lastiger om de streams te synchroniseren, maar met onderstaand commando wordt de gecombineerde stream naar een ander ffmpeg proces gepiped:

```
ffmpeg -fflags nobuffer -f v4l2 -i /dev/video0 -itsoffset 0.25 -f alsa -i hw:0 -c:v copy -c:a copy -f nut pipe:1 | ffmpeg -i pipe:0 -vf format=yuv420p,crop=iw:iw/16*9,scale=640:-2:sws_flags=gauss,removegrain=2:2:2:2,atadenoise,setsar=sar=1/1,smartblur=ls=-1,eq=contrast=1.1:brightness=0:saturation=1:gamma=1 -c:v libx265 -qp:v 30 -r 25 -af 'highpass=f=150,lowpass=f=3000,afftdn=nt=w:om=o,compand=attacks=0:points=-55/-100|-40/-20|-25/-15|-5/-5|20/20,crystalizer' -c:a aac -b:a 64k -ar 32000 out.mp4 -y
```

> *-fflags nobuffer* zou latency verminderen
> *-f v4l2 -i /dev/video0* linux, gebruik video stream 0
> *-itsoffset 0.25 -f alsa -i hw:0* voeg 0.25s latency toe aan de audiostream 0
> *-c:v copy -c:a copy* gebruik de streams zoals ze zijn, niet converteren
> *-f nut* ffmpeg raw stream format, lage overhead
> *pipe:1 | ffmpeg -i pipe:0* voer eerder genoemde streams in nieuwe ffmpeg (misschien niet nodig?)
> ...
> *compand=points=...* elke sectie tussen '|' stelt de eerstgenoemde geluidssterkte bij naar die achter de '/', dus sterker of zachter

En een super-lowres versie:

```
ffmpeg -fflags nobuffer -f v4l2 -i /dev/video0 -itsoffset 0.25 -f alsa -i hw:0 -c:v copy -c:a copy -f nut pipe:1 | ffmpeg -i pipe:0 -vf format=yuv420p,crop=iw:iw/16*9,scale=128:-2:sws_flags=gauss,removegrain=2:2:2:2,atadenoise,setsar=sar=1/1,smartblur=ls=-1,eq=contrast=1.1:brightness=0:saturation=1:gamma=1 -c:v libx265 -qp:v 30 -r 25 -af 'highpass=f=150,lowpass=f=3000,afftdn=nt=w:om=o,compand=attacks=0:points=-55/-100|-40/-20|-25/-15|-5/-5|20/20,crystalizer' -c:a aac -b:a 32k -ar 22050 -ac 1 out.mp4 -y
```

<br>
<br>

## AV1
> equivalent to libx264 crf 25



#### HIGH-AV1
            ffmpeg -i test2.mp4 -vf format=yuv420p,scale=-2:1080:sws_flags=lanczos,setsar=sar=1/1,unsharp=3:3:0.3 -c:v libsvtav1 -b:v 0 -qp 35 -preset 7 -c:a libopus -b:a 96k output.webm


#### MEDIUM-AV1:
            ffmpeg -i input.mp4 -vf format=yuv420p,scale=-2:540:sws_flags=lanczos,setsar=sar=1/1,unsharp=3:3:0.3 -c:v libsvtav1 -b:v 0 -qp 35 -preset 7 -c:a libopus -b:a 96k output.webm

Deze laatste is de beste. -qp 40 is de ideale balans tussen vloeiend beeld zonder blokken en compressie. Al vanaf 270p is de video prima bruikbaar.


#### SMALL-AV1:
            ffmpeg -i input.mp4 -vf format=yuv420p,scale=-2:270:sws_flags=lanczos,setsar=sar=1/1,unsharp=3:3:0.3 -c:v libsvtav1 -b:v 0 -qp 35 -preset 7 -af "highpass=f=150,lowpass=f=3500" -ar 24000 -c:a libopus -b:a 64k output.webm


#### TINY-AV1:
            ffmpeg -i input.mp4 -vf format=yuv420p,scale=-2:135:sws_flags=gauss,setsar=sar=1/1,unsharp=3:3:0.3 -c:v libsvtav1 -b:v 0 -qp 35 -preset 7 -af "highpass=f=150,lowpass=f=3500" -ar 24000 -ac 1 -c:a libopus -b:a 32k output.webm


```

## GENERAL TIPS

  * MKV container is probably the most versatile container. Contains practically any type of audio+video codec
  * MKA like above
  * Editable formats for non-linear video editors are ProRes, DNXHD and DNXHQ


### FFMPEG INFO

#### I01. Get framerate (for use in scripts etc)
```
ffmpeg -i VTS_04_1.VOB 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"
```

#### I02. Count number of frames
```
ffprobe -v fatal -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 input.mp4
```

#### I03. List FFMPEG supported filters / codecs / options ...
```
ffmpeg -filters | grep ...
ffmpeg -codecs | grep ...
ffmpeg -h encoder=h264_nvenc
```
