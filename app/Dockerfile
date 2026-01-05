# syntax=docker/dockerfile:1

FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests clean package

FROM eclipse-temurin:21-jre-jammy
ENV JAVA_OPTS=""
WORKDIR /app
RUN groupadd -r spring && useradd -r -g spring spring && chown -R spring:spring /app
COPY --from=builder /workspace/target/*.jar /app/app.jar
USER spring
EXPOSE 8080
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]
