# Elite Quiz App

```shell Get the packages
flutter pub get
```

#### To get the current SHA keys of the app.

- Run the app at least once in android (real or emulator).
- After that go to android folder and run the gradlew command.

```shell
cd android
./gradlew :app:signingReport
```

- You will see different variants of SHA keys. debug, release, profile etc.
- Now, which one is being used depends on which signingConfig we have set in
  android/app/build.gradle, you can find more about this in
  app [documentation](https://wrteamdev.github.io/Elite_Quiz_Doc/#:~:text=SHA%20keys%20and%20Keystore%20Basics).
- Copy the correct variants both SHA keys and add in your firebase project.

## If Running the app for IoS, do this before

```shell
cd ios
pod install
cd ..
```

```shell Run the app
flutter run
```

```shell Build App Bundle
flutter build appbundle --release
open build/app/outputs/bundle/release/
```

```shell Build Apk
flutter build apk --split-per-abi
```

### Full project Clean up. Warning: after this you will have to start over the setup.

```shell
rm -rf \
.dart_tool \
.flutter-plugins \
.flutter-plugins-dependencies \
.idea \
.metadata \
android/.gradle \
android/app/google-services.json \
build \
ios/.symlinks \
ios/Podfile.lock \
ios/Pods \
ios/Runner/GoogleService-Info.plist \
ios/build \
ios/firebase_app_id_file.json \
lib/firebase_options.dart \
pubspec.lock
```

#### To build the release version of the app (for Play Store)

Note: Steps with images are given
in [documentation](https://wrteamdev.github.io/Elite_Quiz_Doc/#:~:text=SHA%20keys%20and%20Keystore%20Basics)

- you will need to first create a new keystore for the app.
- And sign the app with it, also add the SHA keys (of keystore) in firebase.
- After that check if login works fine.
- then you can create a release version of the app bundle to submit.
- Make sure you are using correct app version (you can change it from pubspec.yaml then run flutter
  pub get)

```shell
flutter build appbundle --release
```

- This you can publish to the Play Store Release.