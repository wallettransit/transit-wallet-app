Place the app icon image file here with the exact filename app_icon.png

Steps to install the provided image as the app icon:

1. Save the image you provided in the repository at:
   assets/images/app_icon.png

2. From the workspace root, run (PowerShell):
   flutter pub get
   flutter pub run flutter_launcher_icons:main

   This will generate Android and iOS launcher icons from assets/images/app_icon.png

3. Rebuild the app:
   flutter clean
   flutter build apk --release

Notes:
- The project already includes a flutter_launcher_icons configuration in pubspec.yaml
  that points to assets/images/app_icon.png. The generator requires that file to exist.
- If you prefer a manual replacement, put platform-specific icon files under
  android/app/src/main/res/mipmap-*/ and iOS/Runner/Assets.xcassets/AppIcon.appiconset/
  using Xcode or your preferred tooling.
