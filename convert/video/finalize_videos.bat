@ECHO OFF

for %%f in (*.mxf) do (
   	echo      
   	echo      ........................
   	echo      ........START...........
   	echo
	C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i "%%f" -vf "format=yuv420p,setsar=sar=1/1,bm3d=sigma=12,atadenoise,unsharp=3:3:0.4,unsharp=5:5:0.2" -af crystalizer -c:v h264_nvenc -preset llhq -profile:v high -coder cavlc -cq:v 24 -movflags use_metadata_tags -c:a aac -b:a 256k "%%f-(highquality_h264).mp4" -y
   	echo      ...................
	C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i "%%f-(highquality_h264).mp4" -vf "scale=iw/2:-2:sws_flags=area" -c:v h264_nvenc -preset llhq -profile:v high -coder cavlc -cq:v 26 -c:a aac -b:a 192k "%%f-(lowquality_h264).mp4" -y 
   	echo      .......................
   	echo      ..........END..........
)


# low quality webm alternative
# C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i temp_out.webm -vf "scale=960:-2:sws_flags=area" -c:v libvpx-vp9 -crf 35 -b:v 0 "%%f_LQ(vp9).webm" -y
