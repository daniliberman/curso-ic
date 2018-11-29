#! /bin/bash

export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_191`
./gradlew -DapiName=curso-ic buildImage
