plugins {
    id("com.android.library")
}
android {
  compileSdk = 31;


  defaultConfig {
    minSdk = 26;
    targetSdk = 31;
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8;
    targetCompatibility = JavaVersion.VERSION_1_8;
  }


}

repositories {
  google();
  mavenCentral();
}

dependencies {
    implementation(project(mapOf("path" to ":okhttp")));
    implementation(project(mapOf("path" to ":parse")));
    implementation(project(mapOf("path" to ":okio")));
    implementation("androidx.core:core:1.8.0");
    implementation("androidx.appcompat:appcompat-resources:1.4.2");
    implementation("androidx.appcompat:appcompat:1.4.2");
    implementation("androidx.exifinterface:exifinterface:1.3.3");
    implementation("androidx.annotation:annotation:1.4.0-rc01");
    implementation("com.google.code.findbugs:jsr305:3.0.2")
    implementation(project(mapOf("path" to ":utils")))
    implementation("com.google.android.material:material:1.6.1")
    ;
    testImplementation("org.junit.jupiter:junit-jupiter:5.8.2");
}
