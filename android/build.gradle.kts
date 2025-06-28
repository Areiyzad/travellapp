// Project-level build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 🔧 Kotlin plugin (used by app-level build.gradle.kts)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // 🔧 Firebase services plugin
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Customize build directory (used by Flutter)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Clean task to delete the entire build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
