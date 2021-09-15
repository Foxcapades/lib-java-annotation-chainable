import org.jetbrains.dokka.gradle.DokkaTask

plugins {
  kotlin("jvm") version "1.5.30"
  id("org.jetbrains.dokka") version "1.5.0"
  `java-library`
  `maven-publish`
  signing
}

group = "io.foxcapades.lib.annotations"
version = "1.0.0"

repositories {
  mavenCentral()
}

dependencies {
  implementation(kotlin("stdlib:1.5.30"))
}

java {
  sourceCompatibility = JavaVersion.VERSION_1_8
  targetCompatibility = JavaVersion.VERSION_1_8

  withSourcesJar()
  withJavadocJar()
}

publishing {
  repositories {
    maven {
      name = "nexus"
      url  = uri("https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/")

      credentials {
        username = project.findProperty("nexus.user") as String?
        password = project.findProperty("nexus.pass") as String?
      }
    }
  }

  publications {
    create<MavenPublication>("maven") {
      from(components["java"])

      pom {
        name.set("Chainable Method Indicator Annotation")
        description.set("Provides a documenting annotation that indicates the annotated method returns the instance of the method's parent class for method chaining on builder pattern types.")
        inceptionYear.set("2021")

        url.set("https://github.com/Foxcapades/lib-java-annotation-chainable")

        developers {
          developer {
            id.set("epharper")
            name.set("Elizabeth Paige harper")
            email.set("foxcapade@gmail.com")
            url.set("https://github.com/Foxcapades")
          }
        }

        licenses {
          license {
            name.set("MIT")
          }
        }

        scm {
          connection.set("scm:git:git://github.com/Foxcapades/lib-java-annotation-chainable.git")
          developerConnection.set("scm:git:ssh://github.com/Foxcapades/lib-java-annotation-chainable.git")
          url.set("https://github.com/Foxcapades/lib-java-annotation-chainable")
        }
      }
    }
  }
}

signing {
  useGpgCmd()

  sign(configurations.archives.get())
  sign(publishing.publications["maven"])
}

tasks.withType<DokkaTask>().configureEach {
  val self = this
  dokkaSourceSets.configureEach {
    when (self.name) {
      "dokkaJavadoc" -> outputDirectory.set(file("${rootProject.projectDir}/docs/javadoc"))
      "dokkaHtml"    -> outputDirectory.set(file("${rootProject.projectDir}/docs/dokka"))
    }
    reportUndocumented.set(true)
    platform.set(org.jetbrains.dokka.Platform.jvm)
    jdkVersion.set(16)
  }
}

