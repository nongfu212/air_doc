## Building Spherical Panoramas using DroneBlocks and AirSim

Here's a [really awesome video](https://www.youtube.com/watch?v=mR-CgeX0Zqg) by Dennis Baldwin showing how he has connected
[DroneBlocks](https://www.droneblocks.io/) to AirSim. In this demo he programs a flight to capture a
series of images that can then be stitched together to create a virtual 360 panorama of the
mountain landscape scene.

[![droneblocks](images/droneblocks.png)](https://www.youtube.com/watch?v=mR-CgeX0Zqg)

After the images are captured Dennis uses [PTGui](https://www.ptgui.com/) to stitch the photos into
a 360 panorama:

![panorama](images/panorama.png)

Then he uses [krpano](https://krpano.com/home/) to publish that as a a website.

See the [resulting website](http://droneblocks.s3.amazonaws.com/airsim-panorama/tour.html) where you
can move the camera around with your mouse to view the full 360 spherical panorama.

Drones are often used to do this exact thing in the real world, so it is super cool to see that you
can now simulate the entire process using AirSim and DroneBlocks.

Very cool.