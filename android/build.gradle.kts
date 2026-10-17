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

subprojects {
    val configureCompileSdk = {
        extensions.findByName("android")?.let { ext ->
            val setCompileSdk = ext.javaClass.methods.firstOrNull { method ->
                method.name == "setCompileSdk" && method.parameterCount == 1
            }
            setCompileSdk?.invoke(ext, 36)
        }
    }
    if (state.executed) {
        configureCompileSdk()
    } else {
        afterEvaluate { configureCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
