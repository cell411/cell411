plugins {
  id("com.android.library");
}
android {
  compileSdk = 31;

  defaultConfig {
    minSdk = 26;
    targetSdk = 31;
    multiDexEnabled = true;
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
  implementation("androidx.annotation:annotation:1.4.0-beta01");
  implementation("com.google.code.findbugs:jsr305:3.0.2");
  implementation(project(mapOf("path" to ":okhttp")));
  implementation(project(mapOf("path" to ":okio")))
    implementation(project(mapOf("path" to ":utils")))
    ;
}

