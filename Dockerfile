# Nexus Repository with the GitHub OAuth plugin preinstalled.
#
#   docker build -t nexus3-github-oauth .
#   docker build --build-arg NEXUS_VERSION=3.98.0 -t nexus3-github-oauth .
#
# Nexus 3.98 starts through the Spring Boot JarLauncher, so the plugin cannot be
# dropped into a deploy directory. scripts/install-nexus-plugin.sh embeds it into
# the Nexus boot jar; here that is done in a throwaway stage and only the patched
# jar is copied into the final image.

ARG NEXUS_VERSION=3.98.0

FROM sonatype/nexus3:${NEXUS_VERSION} AS nexus

FROM maven:3-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml ./
RUN mvn -B -Denforcer.skip=true dependency:go-offline
COPY src ./src
RUN mvn -B -Denforcer.skip=true -DskipTests package

FROM builder AS patcher
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=nexus /opt/sonatype/nexus/bin/sonatype-nexus-repository-*.jar /nexus/bin/
COPY scripts/install-nexus-plugin.sh /usr/local/bin/
RUN install-nexus-plugin.sh \
      --plugin "$(ls /build/target/nexus3-github-oauth-plugin-*.jar | grep -v original-)" \
      --nexus-home /nexus \
 && rm /nexus/bin/*.backup.*

FROM sonatype/nexus3:${NEXUS_VERSION}
COPY --from=patcher --chown=nexus:nexus /nexus/bin/sonatype-nexus-repository-*.jar /opt/sonatype/nexus/bin/
