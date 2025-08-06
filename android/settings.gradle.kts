// Keep this part as-is for plugins
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()                  // ✅ Required for Android Gradle Plugin
        mavenCentral()
        gradlePluginPortal()      // ✅ Required for Kotlin + JetBrains plugins
    }
}

// ✅ ADD THIS BLOCK for Mapbox AAR files
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
  repositories {
    google()
    mavenCentral()

    // ✅ Flutter Engine artifacts
    maven {
      url = uri("https://storage.googleapis.com/download.flutter.io")
    }

    // ✅ Mapbox
    maven {
      url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
      authentication {
        create<BasicAuthentication>("basic")
      }
      credentials {
        username = "mapbox"
        password = providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN").get()
      }
    }
  }
}


plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
