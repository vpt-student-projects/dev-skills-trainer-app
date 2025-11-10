# java-sandbox/Dockerfile
FROM eclipse-temurin:17-jre-jammy
RUN mkdir -p /code && \
    chown nobody /code
USER nobody
WORKDIR /code
CMD ["java", "-jar", "app.jar", ">", "/code/output.txt", "2>&1"]