FROM oven/bun:alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install
COPY src/ src/
COPY tsconfig.json ./
RUN bun build --compile src/main.ts --outfile worker

FROM docker.io/library/alpine:latest
RUN apk add --no-cache ca-certificates libstdc++ bash
WORKDIR /app
COPY --from=builder /app/worker /app/worker
RUN chmod +x /app/worker
ENV PORT=25001
ENV WORKSPACE_ROOT=/data/workspace
ENV NIX_PKGS=[]
EXPOSE 25001
ENTRYPOINT ["/app/worker"]
