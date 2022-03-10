# on_sight

EE4002D App Component.

# Configuring the application

1. Clone repository.
2. cd into repository.
3. Ensure you are at "Master" branch.
4. Run command

```
flutter create .
```

5. Run application

```
flutter run
```

# Hotfix

Before performing any of the tasks below, ensure that you have a clean build.

```
flutter clean
flutter run
```

If the clean build does not work, then remedy with the steps below.

## Bluetooth Remedies:

Note: This was a remedy for Flutter_Blue Package. It may or may not work for Flutter_Reactive_BLE.

### iOS

1. If you are using an Apple Silicon Mac (M1, M1 Pro, M1 Max or any other device that uses an ARM architecture chip), please do the following steps first as the bluetooth package only supports iOS devices from an x86 architecture:
   1. Go to your Applications Folder
   2. Under the Utilities Folder, look for Terminal
   3. Right click on the terminal and click on get info
   4. Tick the "Open using Rosetta" box
   5. Open the Terminal App and run this file: sudo arch -x86_64 gem install ffi
   6. Go to the iOS Folder in Flutter --> Runner --> info.plist
   7. Add the following to the file:
   ```
   <key>NSBluetoothAlwaysUsageDescription</key>
   <string>Our app uses bluetooth to find, connect and transfer data between different devices</string>
   ```

### Android

1. Go to the Android File in Flutter --> app-->src-->build.gradle
2. change the minSdkVersion to 19
3. go to the Tools menu bar, click on Flutter and select "Open for Editing in Android Studio" (Note: in Windows, selection is "Open Android Module in Android Studio")
4. go to Gradle scripts, and select the android.flutter_blue gradle file
5. under protobuf->protoc->artifact, change it to "com.google.protobuf:protoc:3.17.3" Only the numbers need to be changed to 3.17.3
6. under dependencies, make the same changes "com.google.protobuf:protoc:3.17.3"

# Other required dependencies

1. DynamoDB

   ### Requirements

   1. Have JRE installed.
   2. Download DynamoDB locally [here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html).
   3. Unzip the files.

   ### To run Database

   1. Run db instance locally.

   ```
   java -D"java.library.path=./DynamoDBLocal_lib" -jar DynamoDBLocal.jar -sharedDb
   ```

   ### To test for connection

   1. Run command

   ```
   aws dynamodb list-tables --endpoint-url http://localhost:8000
   ```

   ### Learning

   1. Read more [here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.html).

2. Mosquitto
   ### Installation guide
   1. Tested on Ubuntu 20.04.
   2. Read more [here](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-ubuntu-18-04).
   ### To boot up Mosquitto
   2. Run
   ```
   mosquitto
   ```
   3. To see published messages
   ```
   mosquitto_sub -h localhost -t "<insert topic>" -u "<insert username>" -P "<insert password>"
   ```
3. (For MQTT) Redirects the TCP connection to port 1883.

```
adb reverse tcp:1883 tcp:1883
```

4. (For DynamoDB) Redirects the TCP connection to port 8000.

```
adb reverse tcp:8000 tcp:8000
```

# Notes

Bluetooth points to take note of:

1. iOS uses UUID and Android uses MACaddress. For security reasons, they are always randomised.
2. For Android:
   1. They are randomised unless it is labelled explicitly on the sending side to be shared
   2. Whatever changes that are made are only for the local device
3. For iOS
   1. the UUIDs are randomised
