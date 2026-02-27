@echo off
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set ANDROID_HOME=C:\Program Files (x86)\Android\android-sdk
set ANDROID_SDK_ROOT=C:\Program Files (x86)\Android\android-sdk
echo y | "C:\Program Files (x86)\Android\android-sdk\cmdline-tools\12.0\bin\sdkmanager.bat" "platforms;android-36" "build-tools;28.0.3"
