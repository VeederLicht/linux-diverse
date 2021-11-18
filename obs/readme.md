## PulseAudio config trick to add virtual microphones

1.  Add the file _default.pa_ to your **[home]/.config/pulse** folder

> At login it will create 2 virtual speakers, called VirtualSpeaker1 & -2.  It also creates a virtual source and a remap source, called VirtualMic1 & -2. Each virtual speaker is connected to one of these VirtualMic's.

2. Then, use an app like OBS to select a monitoring VirtualSpeaker

3. Now you can select a VirtualMic in your application of choice

NOTE: I dont know the exact differences between a module-virtual-source and a module-remap-source, but sometimes when i get strange delays in the audio signal, switching to the other one may help.



