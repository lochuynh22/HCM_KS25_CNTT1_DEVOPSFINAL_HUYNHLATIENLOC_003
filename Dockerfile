# syntax=docker/dockerfile:1
# =============================================================================
#  Dockerfile - FILE KHUNG (multi-stage build cho Spring Boot 4 / Java 21 / Gradle)
#  Sinh viên hoàn chỉnh các ô ______ theo yêu cầu Phần 2 của đề thi.
# =============================================================================

# ---------- Stage 1: build - biên dịch & đóng gói bằng Gradle + JDK 21 ----------
# Spring Boot 4 yêu cầu Gradle >= 8.14
FROM gradle:8.14-jdk21-alpine AS build
WORKDIR /workspace

# Copy cấu hình Gradle trước để tận dụng cache
COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon

# Copy source và build JAR
COPY src ./src
RUN gradle bootJar -x test --no-daemon

# ---------- Stage 2: runtime ----------
FROM eclipse-temurin:21-jre-alpine AS runtime

# Nhận phiên bản lúc build
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75"

WORKDIR /app

# Tạo user thường để chạy ứng dụng
RUN addgroup -S spring && adduser -S spring -G spring

# Copy JAR từ stage build
COPY --from=build /workspace/build/libs/app.jar /app/app.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
