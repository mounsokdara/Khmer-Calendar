import com.android.build.gradle.internal.api.ApkVariantOutputImpl

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mounsokdara.khmercalendar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mounsokdara.khmercalendar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        jniLibs {
            // Store the native libraries (libflutter.so, libapp.so, ...) compressed
            // inside the APK instead of raw. Same code, ~half the download size;
            // Android extracts them at install time.
            useLegacyPackaging = true
        }

    // F-Droid: do not embed the Google "Dependency metadata" signing block in the APK
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
    }

    signingConfigs {
        create("release") {
            // Credentials come from environment variables (GitHub Actions secrets or local shell). Never hardcode.
            val ks = System.getenv("ANDROID_KEYSTORE")
            if (ks != null && file(ks).exists()) {
                storeFile = file(ks)
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: "com.mounsokdara.khmercalendar"
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            val rel = signingConfigs.findByName("release")
            signingConfig = when {
                rel?.storeFile?.exists() == true -> rel
                // F-Droid builds without our keystore and signs the APK itself (its build sets FDROID_BUILD).
                System.getenv("FDROID_BUILD") != null -> signingConfigs.getByName("debug")
                else -> throw GradleException("Release keystore missing: refusing to sign a release build with the debug key")
            }
        }
    }
}

// Version code: the same number for every package. It always comes from version.txt (via pubspec.yaml),
// whatever the CPU build type, and never from a CI run number.
// Version name: <versionName>_<BuildType>, e.g. 1.0.5_Arm64 (Arm32, Arm64, X64, Arm32_64, X86_X64, X86, Universal).
val abiNames = mapOf("armeabi-v7a" to "Arm32", "arm64-v8a" to "Arm64", "x86_64" to "X64", "x86" to "X86")
val targetPlatformNames = mapOf(
    setOf("android-arm") to "Arm32",
    setOf("android-arm64") to "Arm64",
    setOf("android-x64") to "X64",
    setOf("android-arm", "android-arm64") to "Arm32_64",
    setOf("android-x86", "android-x64") to "X86_X64",
    setOf("android-x86") to "X86",
)
// What `flutter build apk --target-platform ...` asked for (absent = the default set = universal).
val builtTargets: Set<String>? = (project.findProperty("target-platform") as String?)
    ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }?.toSet()
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val abi = output.filters.find { it.filterType == "ABI" }?.identifier
        // Split build: the ABI of this APK. Fat build: the targets that were requested (none -> universal).
        val type = if (abi != null) abiNames[abi] else (builtTargets?.let { targetPlatformNames[it] } ?: "Universal")
        if (type != null) {
            (output as ApkVariantOutputImpl).versionNameOverride = "${variant.versionName}_$type"
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

// F-Droid: no Google libraries. geolocator_android declares Play Services (the app forces the plain
// Android LocationManager, see lib/location.dart) and Flutter's embedding references Play Core
// (only used for Play Store deferred components, which this app does not use).
configurations.configureEach {
    exclude(group = "com.google.android.gms")
    exclude(group = "com.google.android.play")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.startup:startup-runtime:1.2.0")
}
