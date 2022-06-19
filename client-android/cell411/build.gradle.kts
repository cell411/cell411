plugins {
  id("com.android.application");
}

android {
  signingConfigs {


    getByName("debug") {
      storeFile = file("/home/parse/src/cell411/keys/cell411_keystore.jks");
      storePassword = "cell411";
      keyAlias = "Cell 411";
      keyPassword = "cell411";
    };
  }

  compileSdk = 31;

  defaultConfig {
    minSdk = 26;
    targetSdk = 31;
    versionCode = 2200101;
    versionName = "22001001";
    targetSdk = 31;
    applicationId = "com.safearx.cell411";
    namespace = "com.safearx.cell411";
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8;
    targetCompatibility = JavaVersion.VERSION_1_8;
  }
  buildFeatures {
    viewBinding = false;
  }
  dependenciesInfo {
    includeInApk = true;
    includeInBundle = true;
  }
  buildTypes {
    getByName("release") {
      isMinifyEnabled = false;
      multiDexEnabled = false;
    }
    getByName("debug") {
      isMinifyEnabled = false;
      multiDexEnabled = false;
    }
  }
}
repositories {
  google();
  mavenCentral();
  gradlePluginPortal();
}
dependencies {
  implementation("androidx.preference:preference:1.2.0");
  implementation("androidx.multidex:multidex:2.0.1");
  implementation("androidx.core:core:1.8.0");
  implementation("androidx.exifinterface:exifinterface:1.3.3");
  implementation("androidx.annotation:annotation:1.4.0-rc01");
  implementation("com.github.clans:fab:1.6.4");
  implementation("com.google.android.material:material:1.6.1");
  implementation("net.butterflytv.utils:rtmp-client:3.1.0");
  implementation("androidx.work:work-runtime:2.7.1");
  implementation("androidx.gridlayout:gridlayout:1.0.0");
  implementation("com.google.code.findbugs:jsr305:3.0.2");
  implementation(project(mapOf("path" to ":lib411")));
  implementation(project(mapOf("path" to ":parse")));
  implementation(project(mapOf("path" to ":zxing")));
  implementation(project(mapOf("path" to ":okhttp")));
  implementation(project(mapOf("path" to ":okio")))
    implementation(project(mapOf("path" to ":utils")))
    ;
}
