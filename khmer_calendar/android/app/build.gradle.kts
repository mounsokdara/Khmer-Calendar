plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "kh.chhankitek.khmer_calendar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "kh.chhankitek.calendar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val ks = System.getenv("ANDROID_KEYSTORE")
                ?: "../../scripts/khmer-release.keystore"
            val file = file(ks)
            if (file.exists()) {
                storeFile = file
                storePassword = "khmercal"
                keyAlias = "khmer"
                keyPassword = "khmercal"
            }
        }
    }

    buildTypes {
        release {
            val rel = signingConfigs.findByName("release")
            signingConfig = if (rel?.storeFile?.exists() == true) rel else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
