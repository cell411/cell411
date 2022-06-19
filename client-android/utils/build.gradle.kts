plugins {
    id("com.android.library");
}

android {
    compileSdk = 32;

    defaultConfig {
        minSdk = 26;
        targetSdk = 32;

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner";
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8;
        targetCompatibility = JavaVersion.VERSION_1_8;
    }
}

repositories {
  mavenCentral();
  google();
}
dependencies {
  implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")
    implementation("org.jetbrains:annotations:23.0.0")
    implementation(project(mapOf("path" to ":okhttp")))
    implementation(project(mapOf("path" to ":okio")))
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")
    implementation("com.google.code.findbugs:jsr305:3.0.2");
}
