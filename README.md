# wearable_sensors

A plugin to provide sensor access on WearOS devices.

Provides access to:

- Gyroscope
- Magnetometer
- Accelerometer
- Heart Rate
- Galvanic Skin Response

Galvanic Skin Response not officially supported, workaround used in this project works for on Wear OS 5 on Google Pixel Watch 3.

Provided methods:

- `createSensorStream(String channelName)` returns stream of specified data type
- `getAllSensors()` prints list of all available sensors found on device
