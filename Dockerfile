FROM eclipse-temurin:21-jdk-jammy@sha256:801b7e1a9c4befaf82bf9a2a58025ef43a7694bbc84779187ad0524d84742772 AS builder

WORKDIR /workspace

COPY gradlew gradlew
COPY gradle gradle
COPY settings.gradle.kts build.gradle.kts ./
COPY src src

RUN chmod +x ./gradlew && ./gradlew bootJar -x test --no-daemon

FROM eclipse-temurin:21-jre-jammy@sha256:199aebeb3adcde4910695cdebfe782ada38dadb6cc8013159b58d3724451befd

WORKDIR /app

RUN useradd --system --create-home --uid 10001 spring

COPY --from=builder /workspace/build/libs/*.jar app.jar

USER spring

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
