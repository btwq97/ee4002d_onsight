# on_sight

EE4002D App Component

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

In order to implement bluetooth into the application, flutter_blue 0.8.0 (https://pub.dev/packages/flutter_blue/example) version was used. 

Please take note of the following AFTER you have installed the package on flutter
1) For iOS: Please take note of the following steps: 
   1a: If you are using an Apple Silicon Mac (M1, M1 Pro, M1 Max or any other device that uses an ARM architecture chip), please do the following steps first as the bluetooth package only supports iOS devices from an x86 architecture: 
    1a.1: Go to your Applications Folder
    1a.2: Under the Utilities Folder, look for Terminal
    1a.3: Right click on the terminal and click on get info 
    1a.4: Tick the "Open using Rosetta" box
    1a.5: Open the Terminal App and run this file: sudo arch -x86_64 gem install ffi 
   1b: Go to the iOS Folder in Flutter --> Runner --> info.plist 
   1c: Add the following to the file:
        <key>NSBluetoothAlwaysUsageDescription</key>
        <string>Our app uses bluetooth to find, connect and transfer data between different devices</string>
   

2) For Android, please take the following steps: 
    2a: Go to the Android File in Flutter --> app-->src-->build.gradle
    2b: change the minSdkVersion to 19 
    2c: go to the Tools menu bar, click on Flutter and select "Open for Editing in Android Studio"
    2d: go to Gradle scripts, and select the android.flutter_blue gradle file 
    2e: under protobuf->protoc->artifact, change it to "com.google.protobuf:protoc:3.17.3" Only the numbers need to be changed to 3.17.3
    2f: under dependencies, make the same changes "com.google.protobuf:protoc:3.17.3"
   