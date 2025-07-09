plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_heart_app_new"
    compileSdk = 35 // ✅ رفعناها لأعلى SDK مستخدم بين الباكيجات
    ndkVersion = "27.0.12077973" // ✅ النسخة المطلوبة من كل الإضافات

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_heart_app_new"
        minSdk = 26 // ✅ مكتبة tflite_flutter تتطلب 26 على الأقل
        targetSdk = 35 // ✅ لجعلها متوافقة مع باقي الباكيجات
        versionCode = 1
        versionName = "1.0.0"
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
