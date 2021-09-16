#!/usr/bin/env bash

if [[ ! "${CI}" ]]; then
  echo "Cannot execute this script outside of a GitHub Action." 1>&2
  exit 1
fi

function envCheck() {
  name=${1:?}

  if [ -z "${!name}" ]; then
    echo "Missing required environment variable ${name}" 1>&2
    exit 1
  fi
}

function gitTag() {
  echo "${GITHUB_REF}" | cut -d/ -f3 | cut -c2-
}

function verifyGitHubEnv() {
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo "#"
  echo "# Verifying GitHub build environment"
  echo "#"
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo
  envCheck NEXUS_USER
  envCheck NEXUS_PASS
  envCheck GPG_KEY
  envCheck GITHUB_REF
  echo "Ok"
  echo
}

function patchVersion() {
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo "#"
  echo "# Patching build version"
  echo "#"
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo
  sed -i "s#version \+=.\+#version = \"$(gitTag)\"#" build.gradle.kts
  echo "Done"
  echo
}

function prepGitHubGPG() {
  gpg --batch --import <(echo -e "${GPG_KEY}")
}

function makeProperties() {
  echo "nexus.user=${NEXUS_USER}"     >  gradle.properties
  echo "nexus.pass=${NEXUS_PASS}"     >> gradle.properties
  echo "signing.gnupg.executable=gpg" >> gradle.properties

  keyID=$(gpg --list-secret-keys --keyid-format LONG | grep sec | sed -e 's#sec \+.\+/\([^ ]\+\).\+#\1#')

  if [[ ! "${keyID}" ]]; then
    echo "Missing required GPG key ID" 1>&2
    exit 1
  fi

  echo "signing.gnupg.keyName=${keyID:?}" >> gradle.properties
}

function cleanup() {
  rm gradle.properties
}

function gitHubRelease() {
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo "#"
  echo "# Publishing artifacts"
  echo "#"
  echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  echo
  ./gradlew publish
}

function docs() {
  ./gradlew dokkaHtml dokkaJavadoc
}

case $1 in
  "github-release")
    verifyGitHubEnv
    patchVersion
    prepGitHubGPG
    makeProperties
    gitHubRelease
    cleanup
    ;;
  "doc")
    doc
    ;;
  "*")
    echo "Unrecognized command $1"
    exit 1
esac