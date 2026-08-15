import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.ootaris.scriptless.dev"
            resValue(type = "string", name = "app_name", value = "Scriptless Dev")
            manifestPlaceholders["launcherIcon"] = "@mipmap/scriptless_icon_launcher_dev"
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.ootaris.scriptless.staging"
            resValue(type = "string", name = "app_name", value = "Scriptless Staging")
            manifestPlaceholders["launcherIcon"] = "@mipmap/scriptless_icon_launcher_stage"
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.ootaris.scriptless"
            resValue(type = "string", name = "app_name", value = "Scriptless")
            manifestPlaceholders["launcherIcon"] = "@mipmap/scriptless_icon_launcher"
        }
    }

    buildFeatures.resValues = true
}