#!/bin/bash
docker stop curso
docker rm curso

export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_191`
docker run --link sql-server:sql-server --link some-redis:some-redis --name curso -e JAVA_OPTS="-Dspring.profiles.active=ic" -p 8080:8080 -d curso-ic:0.0.1-SNAPSHOT
