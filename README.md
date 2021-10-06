# flutter_native_opencv
Using OpenCV natively in C++ in a Flutter app with Dart FFI. Tested with Flutter ~~1.20.2~~ 2.5.2.

Read the full article here: https://medium.com/flutter-community/integrating-c-library-in-a-flutter-app-using-dart-ffi-38a15e16bc14

If we follow the above link and the original Github repo directly, `flutter` complains about errors during build.
Problem is that `ffi` changed its interface, so some of the UTF8 string conversion things were not working. The code in this mirror repo has been fixed to conform to the new `ffi` interface. This allows us to use a newer version of `ffi` (`^1.0.0` now), which also seems to have solved the other dependency problems.

# How to build & run
1. Download OpenCV for Android and iOS: https://opencv.org/releases/ (tested with opencv-4.5.3)
2. Copy or create symlinks:
   - `opencv2.framework` to `native_opencv/ios`
   - `OpenCV-android-sdk/sdk/native/jni/include` to `native_opencv`
   - Contents of `OpenCV-android-sdk/sdk/native/libs/**` to `native_opencv/android/src/main/jniLibs/**`
3. If necessary, downgrade the NDK from v23 to v22 (more about this can be found [here](https://stackoverflow.com/questions/66922162/no-toolchains-found-in-the-ndk-toolchains-folder-for-abi-with-prefix-arm-linux))
