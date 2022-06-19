plugins {
    id("com.android.library");
}

android {
    compileSdk = 32;

    defaultConfig {
//        applicationId = "com.google.zxing.client.android";
        minSdk = 26;
        targetSdk = 32;
//        versionCode = 1;
//        versionName = "1.0";

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner";
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8;
        targetCompatibility = JavaVersion.VERSION_1_8;
    }
}
repositories {
    google()
    mavenCentral()
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.annotation:annotation:1.3.0")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")
}
