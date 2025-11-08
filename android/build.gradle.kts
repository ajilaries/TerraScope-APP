plugins {
    // ✅ Make Google Services plugin available for app-module
    id("com.google.gms.google-services") version "4.4.4" apply false
}
allprojects{
    tasks.withType<JavaCompile>{
        sourceCompatibility=JavaVersion.VERSION_11
        targerCompatibility=JavaVersion.VERSION_11
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
