plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
  
}

android {
    namespace = "com.gis.vcorev5"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14033849"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gis.vcorev5"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Fix agconnect_remote_config manifest issues
        manifestPlaceholders["agconnectRemoteConfigPackage"] = "com.huawei.agconnectremoteconfig"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Handle agconnect_remote_config manifest package attribute issue
            manifestPlaceholders["agconnectRemoteConfigPackage"] = "com.huawei.agconnectremoteconfig"
        }
    }
    
    packagingOptions {
        // Ignore duplicate licenses and manifests
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE"
            )
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // ... (other dependencies)
    implementation("com.huawei.agconnect:agconnect-remoteconfig:1.9.0.300") // Use the latest version
    implementation("com.huawei.agconnect:agconnect-core:1.9.0.300") // Use the latest version
}