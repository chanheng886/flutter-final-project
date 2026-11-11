# ==========================================
# Stage 1: Build Spring Boot Application
# ==========================================
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy Maven configuration
COPY backend/pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY backend/src ./src

# Build application
RUN mvn clean package -DskipTests

# Select the executable Spring Boot JAR
RUN JAR=$(find target -maxdepth 1 -name "*.jar" ! -name "*.original" | head -n 1) \
    && cp "$JAR" /app/app.jar


# ==========================================
# Stage 2: Run Application
# ==========================================
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Install Tesseract OCR and Khmer language support
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-khm \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/share/tesseract-ocr/5 \
    && (ln -s /usr/share/tesseract-ocr/4.00/tessdata /usr/share/tesseract-ocr/5/tessdata 2>/dev/null || true) \
    && (ln -s /usr/share/tessdata /usr/share/tesseract-ocr/5/tessdata 2>/dev/null || true)

# Configure Tesseract
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

# Create upload directory
RUN mkdir -p /app/uploads

# Copy application JAR
COPY --from=build /app/app.jar app.jar

# Expose application port
EXPOSE 8080

# Start Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]