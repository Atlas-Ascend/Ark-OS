plugins {
    id("com.android.application")
}

android {
    namespace = "global.ghostatlas.ark.assistant"
    compileSdk = 36

    defaultConfig {
        applicationId = "global.ghostatlas.ark.assistant"
        minSdk = 29
        targetSdk = 36
        versionCode = 4
        versionName = "0.3.1"

        buildConfigField("String", "RUNTIME_BASE_URL", "\"https://ghost-atlas-runtime-gateway.onrender.com\"")
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
