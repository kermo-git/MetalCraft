This is my hobby project to create a MineCraft-like game for Apple devices. The following devices are supported:
* **macOS** devices (MacBook and iMac). These must have Apple silicon (e.g M1, M2 or M3), not Intel processors.
* **iOS** devices (iPhone and iPad)

The name comes from the fact that it uses Metal API to render 3D graphics. User interface is created using SwiftUI.

Setup instructions (you need a macOS computer):
1) Clone the repo
2) Download XCode from App Store if you don't have it
3) Open `MetalCraft.xcodeproj` in XCode
4) After the project is opened in XCode, look for target option on top of the screen, it should read *MetalCraft (macOS)* or *MetalCraft (iOS)*. Use this to select which version of the game you want to run. For iOS version, you don't need a real device, XCode can run the game in a simulator.
6) Next to target option, there is an option to choose which device to use, e.g *MetalCraft (iOS) > iPhone 15*. For iOS version, you can choose which type of iPhone or iPad simulator you want to use.
7) To run the game on an actual iOS device, connect it to your computer using a cable. Then you should see it in the list of devices. If you don't see it, restarting XCode or computer will help.
8) Click ▶️ button to run the game.
9) Play around with the code and run again 😊.
