pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
    }
    resolutionStrategy {
        eachPlugin {
            if(requested.id.namespace == "com.android") {
                useModule("com.android.tools.build:gradle:${requested.version}")
            }
        }
    }
}
include("cell411");
include(":parse");
include(":okhttp");
include(":stream");
include(":lib411");
include(":okio");
include(":zxing");
include(":utils")
