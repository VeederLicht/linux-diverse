## Intel Arc GPU not working with ffmpeg

Encoder exits with fault:

```
[av1_qsv @ 0x55645bb88340] Error during set display handle
: device failed (-17)
```

Also see: https://github.com/intel/cartwheel-ffmpeg/issues/233#issuecomment-2036610870

Solved for Arch based distro's by installing the **onevpl-intel-gpu** package.
