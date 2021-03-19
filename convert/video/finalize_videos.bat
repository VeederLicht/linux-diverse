@ECHO OFF

for %%f in (*.mxf) do (
   	echo      
   	echo      ........................
   	echo      ........START...........
   	echo
	C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i "%%f" -vf "format=yuv420p,setsar=sar=1/1,bm3d=sigma=12,atadenoise,unsharp=3:3:0.4,unsharp=5:5:0.2" -af crystalizer  -c:v h264_nvenc -movflags use_metadata_tags -preset slow -profile:v high -coder cavlc -qp:v 24 -c:a aac -b:a 256k "%%f-(highquality_h264).mp4" -y
   	echo      ...................
	C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i "%%f-(highquality_h264).mp4"  -vf "scale=1280:-2:sws_flags=area" -c:v h264_nvenc -movflags use_metadata_tags -preset slow -profile:v high -coder cavlc -qp:v 32 -c:a aac -b:a 192k "%%f-(lowquality_h264).mp4" -y 
   	echo      .......................
   	echo      ..........END..........
)

# All-intra DNxHR alternative (YUV444 capable! but not widely supported):
# C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i "20210312-bmi_interview.mxf" -pix_fmt yuv420p -c:v hevc_nvenc -movflags use_metadata_tags -preset llhq -intra -qp:v 15 -c:a aac -b:a 384k "out.mp4"

# low quality webm alternative
# C:\Users\richa\Videos\ffmpeg\bin\ffmpeg.exe -i temp_out.webm -vf "scale=960:-2:sws_flags=area" -c:v libvpx-vp9 -crf 35 -b:v 0 "%%f_LQ(vp9).webm" -y
