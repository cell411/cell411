plugins {
  id ("com.android.application");
};

android {
  compileSdk = 31;

  defaultConfig {
    applicationId = "cell411.streamer";
    minSdk = 26;
    targetSdk = 31;
    versionCode = 1;
    versionName = "1.0";

  }


  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8;
    targetCompatibility = JavaVersion.VERSION_1_8;
  }



}

repositories {
  gradlePluginPortal();
  google();
  mavenCentral();
}

dependencies {
  implementation("androidx.appcompat:appcompat:1.4.2");
  implementation("com.google.android.material:material:1.6.1");
  implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation(project(mapOf("path" to ":utils")))
    ;
  testImplementation("junit:junit:4.13.2");
  implementation("net.butterflytv.utils:rtmp-client:3.1.0");
  implementation("com.google.code.findbugs:jsr305:3.0.2");
  implementation("androidx.annotation:annotation:1.4.0-rc01");
  androidTestImplementation("androidx.test.ext:junit:1.1.3");
  implementation(project(mapOf("path" to ":lib411")));
}
