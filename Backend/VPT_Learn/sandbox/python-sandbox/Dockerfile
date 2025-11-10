FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

USER nobody

# VOLUME /code
# # Используем sh -c для перенаправления вывода
# CMD ["sh", "-c", "python3 /code/code.py > /code/output.txt 2>&1"]