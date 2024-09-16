# FROM syntax indicates type of docker image we will use.
# You should specify the latest maven version and jdk version. In this case, we use maven 3.9.6 and java 21 (java version must match the version in POM.xml)
# https://hub.docker.com/layers/library/maven/3.9.6-eclipse-temurin-21-alpine/images/sha256-0d5d7b952ecb945b52318e22526b91f52b9b9f979b8c83d6718ed3e1bbfde037
FROM openjdk:21-jdk
# openjdk:21-jdk

# Install maven
ARG MAVEN_VERSION=3.9.8
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
&& curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
&& tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
&& rm -f /tmp/apache-maven.tar.gz \
&& ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME=/usr/share/maven

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY pom.xml /tmp/pom.xml
# Copy an entire project into /usr/src/app
COPY . /usr/src/app

#This is to provide maven_runner.sh with executable permission
RUN ["chmod", "+x", "/usr/src/app/maven_runner.sh"]
RUN ulimit -c -l

# Intruct Maven to download all dependencies in advance
RUN mvn -B -f /tmp/pom.xml prepare-package -DskipTests

# This CMD - command part will be executed upon Docker Run command
CMD ["sh","/usr/src/app/maven_runner.sh"]