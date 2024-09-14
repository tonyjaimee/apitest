# FROM syntax indicates type of docker image we will use.
# You should specify the latest maven version and jdk version. In this case, we use maven 3.9.6 and java 21 (java version must match the version in POM.xml)
# https://hub.docker.com/layers/library/maven/3.9.6-eclipse-temurin-21-alpine/images/sha256-0d5d7b952ecb945b52318e22526b91f52b9b9f979b8c83d6718ed3e1bbfde037
FROM maven:3.9.6-eclipse-temurin-21-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#COPY settings.xml /usr/share/maven/ref/
COPY pom.xml /tmp/pom.xml
COPY . /usr/src/app

#This is to provide maven_runner.sh with executable permission
RUN ["chmod", "+x", "/usr/src/app/maven_runner.sh"]
RUN mvn -B -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml prepare-package -DskipTests

#Execute shell script from the docker file! This shell script will invoke karate parallel runner class
CMD ["sh","/usr/src/app/maven_runner.sh"]