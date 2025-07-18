The simGetImage python API causes the visuals to freeze while each image is captured, which is hard to look at, but there is another way to capture AirSim video using the new Unreal [PixelStreamer](https://docs.unrealengine.com/en-US/Platforms/PixelStreaming/PixelStreamingIntro/index.html).  If you simply follow the instructions on that page and enable Pixel Streaming feature in your AirSim Unreal environment then you can get the following result.

See [demo video](https://1drv.ms/v/s!AoS-ymEfLuCLre8AfmDP6wIpVRQYZQ).
![image](https://raw.githubusercontent.com/wiki/microsoft/AirSim/images/pixel_streaming.png)

Notice that the video capture is very smooth and does not disrupt AirSim visuals in any way.

The question then is how to redirect the web browser output into something you can use for AI training?  Unreal is using the WebRTC streaming standard, so there should be plenty of open-source ways to crack that stream and turn it into whatever you want... WebRTC is natively supported by Chrome, so it works nicely there.

This pixel streaming is built on the NVidia GPU video encoding stack, so you may need to install an updated NVidia driver to make sure you have that piece too, but you don't need the Video Codec SDK, just the driver is enough.  The Video Codec SDK is probably what Unreal is using under the covers, and could be another way to crack the stream rather than publishing it as WebRTC.

The WebRTC support could be really handy if you want to setup "AirSim server boxes" that deliver video to other folks who are consuming those streams for training AI models and so on.