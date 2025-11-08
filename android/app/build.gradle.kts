plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ Google Services plugin for Firebase
    id("com.google.gms.google-services")

    // ✅ Flutter plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.terra_scope_apk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ✅ Fix Java warnings (use strings instead of JavaVersion enums)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.terra_scope_apk"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
}
