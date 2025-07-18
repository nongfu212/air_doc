AirSim communicates with PX4 based drone (either HIL or SITL) using [MavLink](https://github.com/mavlink/mavlink).  For Pixhawk hardware this is usually done using your local serial port.  The MavLinkCom library is used by AirSim and this library is flexible, allowing you to configure different types of connections so that you simply monitor, or even intercept and change mavlink messages.  The [MavLinkCom Readme](https://github.com/Microsoft/AirSim/tree/master/MavLinkCom) provides lots of details about how that can be done, but the following are some simple steps you can perform.

THe MavLinkCom library includes a test app called [MavLinkTest](https://github.com/Microsoft/AirSim/tree/master/MavLinkCom/MavLinkTest) which can act as a proxy relay for mavlink messages. This app can communicate with Pixhawk over serial port like this:
````
MavLinkTest -serial:*,115200 -proxy:127.0.0.1:14560
````
On Linux replace * with '/dev/serial/ttyACM0' or whatever the device name is there.  This will connect the serial point and send/receive all mavlink messages from there over the localhost UDP port 14560.  This means you can now connect AirSim to that UDP port, by turning off the serial port in ~/Documents/AirSim/settings.json by setting "UseSerial" to false and "UdpPort": 14560.  

MavLinkTest is also an interactive command interpretter, you can type "?" to see the list of possible commands.  So, forexample, when AirSim is up and running, you can type "arm" to arm the drone and "takeoff 10" to take off and fly to 10 meters.

AirSim uses this MavLinkCom library to proxy messages to other UDP ports for QGroundControl (14550) and LogViewer (14388). Since these are UDP channels, you can also do this across multiple machines.

So then if you look at how MavLinkTest works the mavlink proxy trick boils down to this code:
````
auto droneConnection = MavLinkConnection::connectSerial("drone", "/dev/ttyACM0", 115200, "sh /etc/init.d/rc.usb\n");
auto proxyConnection = MavLinkConnection::connectRemoteUdp("qgc", "127.0.0.1", "127.0.0.1", 14560);
droneConnection->join(proxyConnection);
````
On Windows `\dev\ttyACM0` serial port device name can be replaced with the appropriate COM port name like `COM6`.

Pretty simple.  This means you can write your own code that does this, but instead of using join, you can do what join does yourself, which is simply "subscribe" to all messages from the droneConnection, and then use "sendMessage" to forward those messages to the proxyConnection.  You can do the opposite also, "subscribe" to all messages from AirSim over the proxyConnection, and send those to the droneConnection.    So then, of course, you can also choose to add, remove or modify those messages as they go, giving you full control over what AirSim and Pixhawk see in the mavlink stream.

You will also see that MavLinkConnection has a simple method called [ignoreMessage](https://github.com/Microsoft/AirSim/blob/master/MavLinkCom/include/MavLinkConnection.hpp#L122) which tells the connection to drop certain message types on the floor.  This is a simple "filter".