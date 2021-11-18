## PulseAudio config trick to add virtual microphones (virtual cables)

1.  Add the file _default.pa_ to your **[home]/.config/pulse** folder

> At login it will create 2 virtual speakers, called VirtualSpeaker1 & -2.  It also creates a virtual source and a remap source, called VirtualMic1 & -2. Each virtual speaker is connected to one of these VirtualMic's.

![pulse-settings1](https://user-images.githubusercontent.com/20968832/142500413-28ed9c72-9e68-425e-bc76-8708bf185709.jpeg)

![pulse-settings2](https://user-images.githubusercontent.com/20968832/142500415-4c4b414b-98b3-4e9f-8fd9-92e1938805e1.jpeg)

2. Then, use an app like OBS to select a monitoring VirtualSpeaker

![obs1](https://user-images.githubusercontent.com/20968832/142500409-2b71ebbe-5747-4122-bd2c-9fd78de766c5.jpeg)

3. Now you can select a VirtualMic in your application of choice

NOTE: I dont know the exact differences between a module-virtual-source and a module-remap-source, but sometimes when i get strange delays in the audio signal, switching to the other one may help.
