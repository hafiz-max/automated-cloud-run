# Stage 1: Build binary statically
FROM gcc:latest AS builder
WORKDIR /app
COPY main.c .
RUN gcc -o web_server main.c -static

# Stage 2: Minimal runtime image
FROM scratch
COPY --from=builder /app/web_server /web_server
EXPOSE 8080
CMD ["/web_server"]