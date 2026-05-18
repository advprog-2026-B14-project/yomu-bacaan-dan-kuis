FROM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /workspace

COPY gradlew gradlew
COPY gradle gradle
COPY settings.gradle.kts build.gradle.kts ./
COPY src src

RUN chmod +x ./gradlew && ./gradlew bootJar -x test --no-daemon

FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

RUN useradd --system --create-home --uid 10001 spring

COPY --from=builder /workspace/build/libs/*.jar app.jar

USER spring

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
