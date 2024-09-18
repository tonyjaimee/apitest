# FROM syntax indicates type of docker image we will use.
FROM openjdk:21-jdk

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