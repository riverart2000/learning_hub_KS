plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.File
import java.io.FileInputStream
import org.gradle.api.file.DuplicatesStrategy
import org.gradle.api.tasks.Copy

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

@Suppress("DEPRECATION")
buildDir = rootProject.projectDir.parentFile.resolve("build/app")

android {
    namespace = "com.plainos.kashmirshaivism"
    compileSdk = 36  // Required by plugins (audioplayers, image_picker, etc.)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.plainos.kashmirshaivism"
        
        // Explicit SDK versions for Google Play requirements
        minSdk = flutter.minSdkVersion      // Android 5.0 (Lollipop) - Good baseline
        targetSdk = 35   // Android 15 - Required for Play Store (updated requirement)
        
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        
        // Enable multidex for large apps
        multiDexEnabled = true
    }

    // Signing configurations
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config (NOT debug!)
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Fallback to debug for testing ONLY
                println("WARNING: Using debug signing - create key.properties for production!")
                signingConfigs.getByName("debug")
            }
            
            // Enable code obfuscation and shrinking
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard configuration files
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
    }
    
    // Disable splits to avoid APK location issues
    // splits {
    //     abi {
    //         isEnable = true
    //         reset()
    //         include("armeabi-v7a", "arm64-v8a", "x86_64")
    //         isUniversalApk = true
    //     }
    // }
}

flutter {
    source = "../.."
}

dependencies {
    // Add MultiDex support if needed
    implementation("androidx.multidex:multidex:2.0.1")
}

// Mirror release APKs into Flutter's expected output directory so the Flutter tooling finds them in CI.
val syncFlutterApk by tasks.registering(Copy::class) {
    val releaseApkDir = layout.buildDirectory.dir("outputs/apk/release")
    val flutterApkDir = rootProject.projectDir.parentFile.resolve("build/app/outputs/flutter-apk")

    duplicatesStrategy = DuplicatesStrategy.INCLUDE
    includeEmptyDirs = false

    from(releaseApkDir) {
        include("*.apk")
    }

    into(flutterApkDir)

    doFirst {
        flutterApkDir.mkdirs()
        flutterApkDir.listFiles()?.filter { it.extension == "apk" }?.forEach(File::delete)
    }
}

gradle.projectsEvaluated {
    tasks.matching { it.name == "assembleRelease" }.configureEach {
        finalizedBy(syncFlutterApk)
    }
}


