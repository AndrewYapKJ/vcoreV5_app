allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://developer.huawei.com/repo/") }
    }

}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    project.evaluationDependsOn(":app")
    
    // Apply namespace to library modules to fix AGConnectRemoteConfig gradle config
    plugins.withId("com.android.library") {
        extensions.getByType<com.android.build.gradle.LibraryExtension>().apply {
            if (namespace == null) {
                namespace = "com.gis.vcorev5.${project.name.replace("-", "")}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
