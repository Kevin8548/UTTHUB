plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
<<<<<<< HEAD
    namespace = "com.example.utthub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
=======
    namespace = "com.example.utt_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"
>>>>>>> bda2726 (1.0 | First version)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
<<<<<<< HEAD
=======
        isCoreLibraryDesugaringEnabled = true
>>>>>>> bda2726 (1.0 | First version)
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
<<<<<<< HEAD
        applicationId = "com.example.utthub"
=======
        applicationId = "com.example.utt_app"
>>>>>>> bda2726 (1.0 | First version)
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
<<<<<<< HEAD
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
=======
>>>>>>> bda2726 (1.0 | First version)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

<<<<<<< HEAD
flutter {
    source = "../.."
}
=======
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
>>>>>>> bda2726 (1.0 | First version)
