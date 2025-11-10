# c-sandbox/Dockerfile
FROM alpine:3.22
RUN apk add --no-cache gcc g++ musl-dev && \
    mkdir -p /code && \
    chown nobody:nobody /code
USER nobody
WORKDIR /code
CMD ["sh", "-c", "gcc /code/*.c -o /code/output && /code/output > /code/output.txt 2>&1"]