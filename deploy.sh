#!/bin/bash
docker stop curso
docker rm curso
docker run --link sql_server:sql_server --name curso -e JAVA_OPTS="-Dspring.profiles.active=ic" -p 8080:8080 -d curso-ic:0.0.1-SNAPSHOT
