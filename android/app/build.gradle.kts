import java.util.Base64
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Lecture des dart-defines ────────────────────────────────────────────────
fun decodeDartDefines(): Map<String, String> {
    val encoded = (project.findProperty("dart-defines") as? String) ?: return emptyMap()
    return encoded.split(",").mapNotNull {
        try {
            String(Base64.getDecoder().decode(it), Charsets.UTF_8)
        } catch (e: Exception) { null }
    }.mapNotNull {
        val idx = it.indexOf('=')
        if (idx > 0) it.substring(0, idx) to it.substring(idx + 1) else null
    }.toMap()
}

val dartDefines = decodeDartDefines()
val appPackage  = dartDefines["APP_PACKAGE"]  ?: "com.hashtagsante.eventapp"
val appName     = dartDefines["APP_NAME"]     ?: "Event App"

// Dernier segment du package → nom du fichier APK (ex: "smr2026")
val clientId = appPackage.split(".").last()

// ── Lecture du keystore (key.properties) ─────────────────────────────────────
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.hashtagsante.eventapp"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion  // commenté : évite le crash de sdkmanager avec Java 25

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias      = keystoreProperties["keyAlias"] as String
                keyPassword   = keystoreProperties["keyPassword"] as String
                storeFile     = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = appPackage
        minSdk        = flutter.minSdkVersion
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
        manifestPlaceholders["appName"] = appName
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug") // fallback pour tests locaux
            isMinifyEnabled    = true
            isShrinkResources  = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// ── Kotlin compiler options — nouveau DSL AGP 9.0 ───────────────────────────
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

// ── Renommage automatique du fichier APK — nouveau DSL AGP 9.0 ──────────────
androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { output ->
            if (output is com.android.build.api.variant.impl.VariantOutputImpl) {
                output.outputFileName.set("${clientId}-${variant.buildType}.apk")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
