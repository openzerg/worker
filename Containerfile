FROM oven/bun:alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
COPY worker/package.json worker/bun.lock* ./
RUN bun install
COPY worker/src/ src/
COPY worker/tsconfig.json ./
RUN bun build --compile src/main.ts --outfile worker

FROM docker.io/library/debian:trixie-slim
WORKDIR /app
COPY --from=builder /app/worker /app/worker
COPY worker/entrypoint.sh /entrypoint.sh
RUN chmod +x /app/worker /entrypoint.sh
RUN apt-get update && apt-get install -y --no-install-recommends bash && rm -rf /var/lib/apt/lists/*
ENV PORT=25001
ENV WORKSPACE_ROOT=/data/workspace
ENV NIX_PKGS=[]
EXPOSE 25001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./worker"]
